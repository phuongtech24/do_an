import argparse
import json
import mimetypes
import os
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


def _multipart_request(url: str, *, field_name: str, file_path: str, headers: dict | None = None, timeout: int = 60):
    boundary = "----reconnectmindhealthboundary"
    mime, _ = mimetypes.guess_type(file_path)
    mime = mime or "image/jpeg"
    filename = os.path.basename(file_path)

    with open(file_path, "rb") as f:
        file_bytes = f.read()

    parts = []
    parts.append(f"--{boundary}\r\n".encode("utf-8"))
    parts.append(
        (
            f'Content-Disposition: form-data; name="{field_name}"; filename="{filename}"\r\n'
            f"Content-Type: {mime}\r\n\r\n"
        ).encode("utf-8")
    )
    parts.append(file_bytes)
    parts.append(b"\r\n")
    parts.append(f"--{boundary}--\r\n".encode("utf-8"))

    data = b"".join(parts)
    req = urllib.request.Request(url=url, data=data, method="POST")
    req.add_header("Content-Type", f"multipart/form-data; boundary={boundary}")
    req.add_header("Content-Length", str(len(data)))
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
    parser = argparse.ArgumentParser(description="Smoke test: Quest proof verify (Gemini Vision) + complete quest.")
    parser.add_argument("--base-url", default="http://localhost:8081/api")
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--image", required=True, help="Path to proof image file (jpg/png).")
    parser.add_argument("--quest-id", default="", help="Optional patientQuestId. If empty, uses first AVAILABLE quest.")
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

    quest_id = args.quest_id.strip()
    if not quest_id:
        url = f"{base}/roadmap/daily?{urllib.parse.urlencode({'patientId': patient_id})}"
        status, text = _request("GET", url, headers={"Authorization": f"Bearer {token}"})
        payload = json.loads(text)
        if payload.get("status") != 200:
            print(f"[FAIL] daily API error: {payload}")
            return 1
        quests = payload.get("data") or []
        first_available = next((q for q in quests if q.get("status") == "AVAILABLE"), None)
        if not first_available:
            print("[WARN] No AVAILABLE quest to test (maybe LOCKED before 06:00). Provide --quest-id.")
            return 0
        quest_id = first_available["id"]

    # verify proof
    verify_url = f"{base}/roadmap/quests/{quest_id}/proof/verify?{urllib.parse.urlencode({'patientId': patient_id})}"
    status, text = _multipart_request(
        verify_url,
        field_name="file",
        file_path=args.image,
        headers={"Authorization": f"Bearer {token}"},
        timeout=90,
    )
    if status != 200:
        print(f"[FAIL] verify HTTP {status}: {text}")
        return 1
    payload = json.loads(text)
    if payload.get("status") != 200:
        print(f"[FAIL] verify API error: {payload}")
        return 1

    data = payload.get("data") or {}
    print("[OK] verify result:")
    print(json.dumps(data, ensure_ascii=False, indent=2)[:1500])

    if not data.get("accepted"):
        print("[STOP] proof not accepted; not completing quest.")
        return 0

    proof_url = data.get("proofImageUrl")
    if not proof_url:
        print("[FAIL] missing proofImageUrl in response.")
        return 1

    # complete quest
    complete_url = f"{base}/roadmap/quests/{quest_id}/complete?{urllib.parse.urlencode({'patientId': patient_id})}"
    status, text = _request(
        "POST",
        complete_url,
        headers={"Authorization": f"Bearer {token}"},
        body={"masteryScore": 7, "pleasureScore": 6, "proofImageUrl": proof_url},
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

