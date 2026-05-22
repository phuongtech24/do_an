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
    parser = argparse.ArgumentParser(description="Smoke test: Risk Index APIs.")
    parser.add_argument("--base-url", default="http://localhost:8081/api")
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--run-one", action="store_true", help="Run risk for this logged-in patient only.")
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

    if args.run_one:
        url = f"{base}/risk/run-one?{urllib.parse.urlencode({'patientId': patient_id})}"
        status, text = _request("POST", url, headers={"Authorization": f"Bearer {token}"})
        payload = json.loads(text)
        print(json.dumps(payload, ensure_ascii=False, indent=2)[:2000])
        return 0

    url = f"{base}/risk/run-now"
    status, text = _request("POST", url, headers={"Authorization": f"Bearer {token}"})
    payload = json.loads(text)
    print(json.dumps(payload, ensure_ascii=False, indent=2)[:2000])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

