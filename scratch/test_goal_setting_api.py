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
    parser = argparse.ArgumentParser(description="Smoke test: Goal Setting API (ReConnect MindHealth).")
    parser.add_argument("--base-url", default="http://localhost:8081/api", help="Example: http://localhost:8081/api")
    parser.add_argument("--username", required=True, help="Patient username/email")
    parser.add_argument("--password", required=True, help="Patient password")
    parser.add_argument("--goals", nargs="+", required=True, help='3-5 goals. Example: --goals "Sleep better" "Less anxiety" "Walk daily"')
    args = parser.parse_args()

    if not (3 <= len(args.goals) <= 5):
        print("[FAIL] Provide 3-5 goals via --goals")
        return 2

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

    # 2) Save goals
    url = f"{base}/clinical/goals"
    status, text = _request(
        "POST",
        url,
        headers={"Authorization": f"Bearer {token}"},
        body={"patientId": patient_id, "goals": args.goals},
    )
    if status != 200:
        print(f"[FAIL] HTTP {status} save goals: {text}")
        return 1

    try:
        payload = json.loads(text)
    except Exception:
        print(f"[FAIL] Cannot parse save goals JSON: {text}")
        return 1

    if payload.get("status") != 200:
        print(f"[FAIL] API error on save goals: {payload}")
        return 1

    print("[OK] Saved goals:")
    print(json.dumps(payload.get("data"), ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

