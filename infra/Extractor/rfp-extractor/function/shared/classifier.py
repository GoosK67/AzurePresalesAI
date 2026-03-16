import os, json
from tenacity import retry, stop_after_attempt, wait_exponential
from azure.identity import DefaultAzureCredential
from azure.ai.openai import OpenAIClient

SYSTEM_PROMPT_PATH = os.getenv("CLASSIFIER_PROMPT_PATH", os.path.join(os.path.dirname(__file__), "..", "prompts", "cegeka_classifier_prompt.txt"))

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=8))
def classify_text(text: str) -> dict:
    endpoint = os.environ["AOAI_ENDPOINT"]
    deployment = os.environ["AOAI_DEPLOYMENT"]
    credential = DefaultAzureCredential()

    client = OpenAIClient(endpoint=endpoint, credential=credential)

    with open(SYSTEM_PROMPT_PATH, 'r', encoding='utf-8') as f:
        system_prompt = f.read()

    response = client.chat_completions.create(
        model=deployment,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Classify this RFP fragment:\n\n{text}"}
        ],
        temperature=0.0,
    )
    msg = response.choices[0].message.content
    # Try parse JSON; if model returned code fences, strip
    msg = msg.strip().removeprefix('```json').removesuffix('```').strip()
    try:
        return json.loads(msg)
    except Exception:
        return {"areas": [], "subareas": [], "confidence": 0.0, "reason": "parse_error", "raw": msg}
