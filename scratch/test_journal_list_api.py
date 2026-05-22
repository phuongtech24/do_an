import argparse
import json
import sys
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
    parser = argparse.ArgumentParser(description="Smoke test: Journal list API (ReConnect MindHealth).")
    parser.add_argument("--base-url", default="http://localhost:8081/api", help="Example: http://localhost:8081/api")
    parser.add_argument("--username", required=True, help="Patient username/email")
    parser.add_argument("--password", required=True, help="Patient password")
    args = parser.parse_args()

    base = args.base_url.rstrip("/")

    # 1) Login -> token + patientId
    login_url = f"{base}/auth/login"
    status, text = _request("POST", login_url, body={"username": args.username, "password": args.password})
    if status != 200:
        print(f"[FAIL] HTTP {status} login: {text}")
        return 1

    try:
        payload = json.loads(text)
    except Exception:
        print(f"[FAIL] Cannot parse login JSON: {text}")
        return 1

    if payload.get("status") != 200 or not payload.get("data"):
        print(f"[FAIL] Login failed: {payload}")
        return 1

    token = payload["data"].get("token")
    user = payload["data"].get("user") or {}
    patient_id = user.get("id")
    if not token or not patient_id:
        print(f"[FAIL] Missing token/patientId in login response: {payload}")
        return 1

    print(f"[OK] Login: patientId={patient_id}")

    # 2) Get journals list
    list_url = f"{base}/journal/thought-records?{urllib.parse.urlencode({'patientId': patient_id})}"
    status, text = _request("GET", list_url, headers={"Authorization": f"Bearer {token}"})
    if status != 200:
        print(f"[FAIL] HTTP {status} list journals: {text}")
        return 1

    try:
        payload = json.loads(text)
    except Exception:
        print(f"[FAIL] Cannot parse list JSON: {text}")
        return 1

    if payload.get("status") != 200:
        print(f"[FAIL] API error on list journals: {payload}")
        return 1

    data = payload.get("data") or []
    print(f"[OK] Journals count: {len(data)}")
    if data:
        first = data[0]
        print("[SAMPLE] First journal:")
        print(json.dumps(first, ensure_ascii=False, indent=2)[:2000])

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

