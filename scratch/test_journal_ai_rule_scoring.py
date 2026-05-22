import argparse
import json
import urllib.error
import urllib.parse
import urllib.request


def _request(method: str, url: str, *, headers: dict | None = None, body: dict | None = None, timeout: int = 20):
    data = None
    if body is not None:
        data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url=url, data=data, method=method.upper())
    req.add_header("Content-Type", "application/json; charset=utf-8")
    if headers:
        for k, v in headers.items():
            req.add_header(k, v)

    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read()
            text = raw.decode("utf-8", errors="replace")
            return resp.status, text
    except urllib.error.HTTPError as e:
        raw = e.read()
        text = raw.decode("utf-8", errors="replace")
        return e.code, text


def main():
    parser = argparse.ArgumentParser(description="Smoke test: rule-based AI risk scoring on Journal save.")
    parser.add_argument("--base-url", default="http://localhost:8081/api")
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument(
        "--mode",
        choices=["normal", "core_belief", "life_threat"],
        default="life_threat",
        help="Which text to send to trigger rule-based scoring.",
    )
    args = parser.parse_args()

    base = args.base_url.rstrip("/")

    # login
    status, text = _request("POST", f"{base}/auth/login", body={"username": args.email, "password": args.password})
    payload = json.loads(text)
    if payload.get("status") != 200:
        print(f"[FAIL] login: {payload}")
        return 1
    token = payload["data"]["token"]
    patient_id = payload["data"]["user"]["id"]

    if args.mode == "life_threat":
        thought = "Mình muốn tự tử. Mình thấy không còn lối thoát."
    elif args.mode == "core_belief":
        thought = "Mình vô giá trị và bất lực, không còn lối thoát."
    else:
        thought = "Hôm nay mình hơi mệt nhưng vẫn ổn."

    body = {
        "patientId": patient_id,
        "journalType": "THOUGHT_RECORD",
        "situation": "Test rule-based scoring",
        "automaticThought": thought,
        "emotion": "Buồn",
        "emotionScore": 80,
        "adaptiveResponse": "Test",
        "reRatedScore": 50,
    }

    status, text = _request(
        "POST",
        f"{base}/journal/thought-records",
        headers={"Authorization": f"Bearer {token}"},
        body=body,
    )
    try:
        payload = json.loads(text)
        print(json.dumps(payload, ensure_ascii=False, indent=2)[:2000])
    except Exception:
        print(text[:2000])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

