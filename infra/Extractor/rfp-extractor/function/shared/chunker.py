from typing import List, Dict

# Simple token-agnostic chunker by character budget while respecting page boundaries

def chunk_pages(pages: List[Dict], max_chars: int = 4000):
    """
    pages: list of {"page": int, "text": str}
    returns list of {"page_start": int, "page_end": int, "text": str}
    """
    chunks = []
    buf = []
    size = 0
    start = None

    for p in pages:
        t = p.get("text", "")
        if start is None:
            start = p.get("page", 1)
        if size + len(t) > max_chars and buf:
            chunks.append({
                "page_start": start,
                "page_end": buf[-1]["page"],
                "text": "\n".join(x["text"] for x in buf)
            })
            buf, size, start = [], 0, p.get("page", start)
        buf.append({"page": p.get("page", 1), "text": t})
        size += len(t)

    if buf:
        chunks.append({
            "page_start": start,
            "page_end": buf[-1]["page"],
            "text": "\n".join(x["text"] for x in buf)
        })
    return chunks
