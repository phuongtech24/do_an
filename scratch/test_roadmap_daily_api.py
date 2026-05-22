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
    parser = argparse.ArgumentParser(description="Smoke test: Roadmap Daily Quests API.")
    parser.add_argument("--base-url", default="http://localhost:8081/api")
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--complete-first", action="store_true", help="Complete first AVAILABLE quest.")
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

    # daily quests
    url = f"{base}/roadmap/daily?{urllib.parse.urlencode({'patientId': patient_id})}"
    status, text = _request("GET", url, headers={"Authorization": f"Bearer {token}"})
    if status != 200:
        print(f"[FAIL] daily HTTP {status}: {text}")
        return 1
    payload = json.loads(text)
    if payload.get("status") != 200:
        print(f"[FAIL] daily API error: {payload}")
        return 1

    quests = payload.get("data") or []
    print(f"[OK] daily quests count={len(quests)}")
    if quests:
        print(json.dumps(quests[0], ensure_ascii=False, indent=2)[:1500])

    if args.complete_first:
        first_available = next((q for q in quests if q.get("status") == "AVAILABLE"), None)
        if not first_available:
            print("[WARN] No AVAILABLE quest to complete (maybe LOCKED before 06:00).")
            return 0

        quest_id = first_available["id"]
        complete_url = f"{base}/roadmap/quests/{quest_id}/complete?{urllib.parse.urlencode({'patientId': patient_id})}"
        status, text = _request(
            "POST",
            complete_url,
            headers={"Authorization": f"Bearer {token}"},
            body={"masteryScore": 7, "pleasureScore": 6},
        )
        payload = json.loads(text)
        if payload.get("status") != 200:
            print(f"[FAIL] complete API error: {payload}")
            return 1
        print("[OK] completed quest:")
        print(json.dumps(payload.get("data"), ensure_ascii=False, indent=2)[:1500])

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

