import logging, os, io
from datetime import datetime, timezone
import azure.functions as func
from azure.storage.blob import BlobServiceClient
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.identity import DefaultAzureCredential

from ..shared.chunker import chunk_pages
from ..shared.classifier import classify_text
from ..shared.search_indexer import ensure_index, upload_documents
from ..shared.excel_exporter import export_and_upload


def _read_blob_to_bytes(blob_client):
    downloader = blob_client.download_blob()
    return downloader.readall()


def _extract_pages(bytes_data: bytes, fr_endpoint: str):
    credential = DefaultAzureCredential()
    client = DocumentAnalysisClient(endpoint=fr_endpoint, credential=credential)
    poller = client.begin_analyze_document('prebuilt-read', document=bytes_data)
    result = poller.result()

    pages = []
    for p in result.pages:
        # Collect content from lines for each page index (1-based)
        content = []
        for line in p.lines:
            content.append(line.content)
        pages.append({"page": p.page_number, "text": "\n".join(content)})
    return pages


def main(inputBlob: func.InputStream):
    logging.info('RFP Processor triggered: name=%s size=%s', inputBlob.name, inputBlob.length)

    # ENV
    fr_endpoint = os.environ['FORMRECOGNIZER_ENDPOINT']

    # Read original blob
    storage_conn = os.environ['AzureWebJobsStorage']
    bsc = BlobServiceClient.from_connection_string(storage_conn)

    # inputBlob provides name like rfp-in/<filename>
    container_name = inputBlob.name.split('/')[0]
    blob_name = '/'.join(inputBlob.name.split('/')[1:])
    blob_client = bsc.get_blob_client(container=container_name, blob=blob_name)
    data = _read_blob_to_bytes(blob_client)

    # Extract text pages
    pages = _extract_pages(data, fr_endpoint)
    if not pages:
        logging.warning('No pages extracted for %s', blob_name)
        return

    # Chunking
    chunks = chunk_pages(pages, max_chars=6000)

    # Ensure search index exists
    ensure_index()

    # Classify chunks
    classified = []
    for ch in chunks:
        res = classify_text(ch['text'])
        ch_res = {
            **ch,
            'areas': res.get('areas', []),
            'subareas': res.get('subareas', []),
            'confidence': float(res.get('confidence', 0.0)),
            'reason': res.get('reason', ''),
            'timestamp': datetime.now(timezone.utc).isoformat()
        }
        classified.append(ch_res)

    # Upload to Azure Cognitive Search
    upload_documents(blob_name, classified)

    # Export Excel
    out_name = export_and_upload(blob_name, classified)
    logging.info('Exported summary to %s', out_name)
