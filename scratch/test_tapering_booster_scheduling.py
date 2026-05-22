import argparse
import json
import urllib.error
import urllib.parse
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
    parser = argparse.ArgumentParser(description="Smoke test: run tapering/booster scheduling + list my appointments.")
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

    # run scheduling (creates appointments if eligible)
    status, text = _request("POST", f"{base}/booster/scheduling/run", headers=headers)
    payload = json.loads(text)
    print("[RUN] scheduling:", json.dumps(payload, ensure_ascii=False)[:600])

    # list my appointments
    status, text = _request("GET", f"{base}/booster/appointments/my?{urllib.parse.urlencode({'patientId': patient_id})}", headers=headers)
    payload = json.loads(text)
    print("[MY] appointments:", json.dumps(payload, ensure_ascii=False, indent=2)[:1500])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

