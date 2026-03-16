import io, os
from collections import defaultdict
from datetime import datetime, timezone
from typing import List
from azure.storage.blob import BlobServiceClient
from openpyxl import Workbook


def export_and_upload(rfp_name: str, chunk_results: List[dict]):
    # Group by area
    by_area = defaultdict(list)
    for r in chunk_results:
        areas = r.get('areas', ['Unclassified']) or ['Unclassified']
        for a in areas:
            by_area[a].append(r)

    wb = Workbook()
    ws0 = wb.active
    ws0.title = 'Overview'
    ws0.append(['Area', 'Items'])
    for a, lst in by_area.items():
        ws0.append([a, len(lst)])

    for a, lst in by_area.items():
        ws = wb.create_sheet(title=a[:31])
        ws.append(['Sub-Areas', 'Confidence', 'PageStart', 'PageEnd', 'Text'])
        for r in lst:
            ws.append([
                ", ".join(r.get('subareas', [])),
                r.get('confidence', 0.0),
                r.get('page_start'),
                r.get('page_end'),
                r.get('text', '')[:32000]
            ])

    # Save to bytes
    buf = io.BytesIO()
    wb.save(buf)
    buf.seek(0)

    # Upload to rfp-out
    acct = os.environ['AzureWebJobsStorage']
    # Connection string is used by BlobServiceClient.from_connection_string
    bsc = BlobServiceClient.from_connection_string(acct)

    out_container = os.environ.get('BLOB_OUT_CONTAINER', 'rfp-out')
    ts = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    out_name = f"rfp-{os.path.splitext(os.path.basename(rfp_name))[0]}-{ts}.xlsx"
    bsc.get_container_client(out_container).upload_blob(name=out_name, data=buf.getvalue(), overwrite=True)
    return out_name
