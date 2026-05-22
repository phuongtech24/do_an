import argparse
import json
import urllib.error
import urllib.request


def _request(method: str, url: str, *, headers: dict | None = None, body: dict | None = None, timeout: int = 30):
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
    parser = argparse.ArgumentParser(description="Smoke test: Graduation rule (2 PERIODIC PHQ-9 < 5).")
    parser.add_argument("--base-url", default="http://localhost:8081/api")
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    args = parser.parse_args()

    base = args.base_url.rstrip("/")

    # login
    status, text = _request("POST", f"{base}/auth/login", body={"username": args.email, "password": args.password})
    if status != 200:
        print(f"[FAIL] login HTTP {status}: {text}")
        return 1
    payload = json.loads(text)
    if payload.get("status") != 200:
        print(f"[FAIL] login API error: {payload}")
        return 1

    token = payload["data"]["token"]
    patient_id = payload["data"]["user"]["id"]

    headers = {"Authorization": f"Bearer {token}"}

    # Submit PERIODIC #1 (all zeros => total 0)
    body = {"patientId": patient_id, "submissionType": "PERIODIC", "answers": [0] * 9}
    status, text = _request("POST", f"{base}/assessment/phq9", headers=headers, body=body)
    payload = json.loads(text)
    if payload.get("status") != 200:
        print(f"[FAIL] submit#1 API error: {payload}")
        return 1
    print("[OK] submit#1:", json.dumps(payload.get("data"), ensure_ascii=False)[:500])

    # Submit PERIODIC #2 (again minimal)
    status, text = _request("POST", f"{base}/assessment/phq9", headers=headers, body=body)
    payload = json.loads(text)
    if payload.get("status") != 200:
        print(f"[FAIL] submit#2 API error: {payload}")
        return 1
    print("[OK] submit#2:", json.dumps(payload.get("data"), ensure_ascii=False)[:500])

    data = payload.get("data") or {}
    if data.get("graduatedNow") is True:
        print("[PASS] graduatedNow=true (taperingStage should be WEEKLY).")
        return 0

    print("[WARN] graduatedNow was not true. taperingStage=", data.get("taperingStage"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

