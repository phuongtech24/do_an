import argparse
import json
import urllib.error
import urllib.request


def _request(method: str, url: str, *, body: dict | None = None, timeout: int = 20):
    data = None
    if body is not None:
        data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url=url, data=data, method=method.upper())
    req.add_header("Content-Type", "application/json; charset=utf-8")

    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read()
            return resp.status, raw.decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        raw = e.read()
        return e.code, raw.decode("utf-8", errors="replace")


def main():
    parser = argparse.ArgumentParser(description="Smoke test: Guided Discovery (AI) API.")
    parser.add_argument("--base-url", default="http://localhost:8081/api")
    args = parser.parse_args()

    base = args.base_url.rstrip("/")
    url = f"{base}/ai/guided-discovery"
    payload = {
        "situation": "Mình chuẩn bị thuyết trình nhưng sợ bị chê cười.",
        "automaticThought": "Mình chắc chắn sẽ làm hỏng và mọi người sẽ coi thường mình.",
        "emotion": "Lo âu",
        "moodScore": 30,
    }

    status, text = _request("POST", url, body=payload)
    print("status:", status)
    try:
        print(json.dumps(json.loads(text), ensure_ascii=False, indent=2)[:2000])
    except Exception:
        print(text[:2000])


if __name__ == "__main__":
    main()

