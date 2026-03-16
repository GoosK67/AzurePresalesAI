import os, uuid
from typing import List
from azure.core.exceptions import ResourceNotFoundError
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import (SearchIndex, SimpleField, SearchFieldDataType, SearchableField)
from azure.core.credentials import AzureKeyCredential


INDEX_SCHEMA = SearchIndex(
    name=os.environ.get('SEARCH_INDEX', 'rfp-index'),
    fields=[
        SimpleField(name="id", type=SearchFieldDataType.String, key=True),
        SearchableField(name="rfpName", type=SearchFieldDataType.String),
        SimpleField(name="pageStart", type=SearchFieldDataType.Int32),
        SimpleField(name="pageEnd", type=SearchFieldDataType.Int32),
        SearchableField(name="areas", type=SearchFieldDataType.Collection(SearchFieldDataType.String)),
        SearchableField(name="subareas", type=SearchFieldDataType.Collection(SearchFieldDataType.String)),
        SimpleField(name="confidence", type=SearchFieldDataType.Double),
        SearchableField(name="text", type=SearchFieldDataType.String),
        SimpleField(name="timestamp", type=SearchFieldDataType.DateTimeOffset)
    ]
)

def get_clients():
    endpoint = os.environ['SEARCH_ENDPOINT']
    key = os.environ['SEARCH_API_KEY']
    index_name = os.environ.get('SEARCH_INDEX', 'rfp-index')

    idx_client = SearchIndexClient(endpoint=endpoint, credential=AzureKeyCredential(key))
    doc_client = SearchClient(endpoint=endpoint, index_name=index_name, credential=AzureKeyCredential(key))
    return idx_client, doc_client, index_name


def ensure_index():
    idx_client, _, index_name = get_clients()
    try:
        idx_client.get_index(index_name)
    except ResourceNotFoundError:
        idx_client.create_index(INDEX_SCHEMA)


def upload_documents(rfp_name: str, chunk_results: List[dict]):
    _, doc_client, _ = get_clients()
    docs = []
    for r in chunk_results:
        docs.append({
            "id": str(uuid.uuid4()),
            "rfpName": rfp_name,
            "pageStart": r["page_start"],
            "pageEnd": r["page_end"],
            "areas": r.get("areas", []),
            "subareas": r.get("subareas", []),
            "confidence": r.get("confidence", 0.0),
            "text": r.get("text", ""),
            "timestamp": r.get("timestamp")
        })
    if docs:
        doc_client.upload_documents(documents=docs)
