# Markdown Token Audit (Est.)

Mục tiêu: theo dõi các file `.md` tốn nhiều token để tránh auto-load không cần thiết. Token ở đây là **ước lượng tương đối** theo heuristic `bytes/4`.

Để tạo bảng mới (generated): chạy `python scratch/audit_md_tokens.py` → sinh `docs/TOKEN_AUDIT.generated.md`.

## Core (auto-load)
- `docs/brief.md`
- `docs/plans/master-plan.md`
- `CHANGELOG.md`
- `docs/BRD_SUMMARY.md`

## Reference (on-demand)
- `docs/BRD.md`
- `docs/SRS_IEEE_830_ReConnect.md`
- `docs/APP_SPECIFICATION_ReConnect.md`
- `docs/diagrams/MVP_DATABASE_SCHEMA.md`
- `docs/THUAT_TOAN_RISK_INDEX.md`
- `reconnect_backend/docs/*` (JWT/API/DB specs)

## Top token hogs (snapshot)

| Path | Bytes | Est. tokens | Category |
|---|---:|---:|---|
| `reconnect_backend/docs/SIMPLE_JWT_GUIDE.md` | 24165 | 6041 | Reference |
| `docs/diagrams/MVP_DATABASE_SCHEMA.md` | 17131 | 4283 | Reference |
| `docs/SRS_IEEE_830_ReConnect.md` | 13368 | 3342 | Reference |
| `.claude/agents/qa-tester.md` | 11471 | 2868 | Tooling |
| `docs/BRD.md` | 10991 | 2748 | Reference |
| `docs/KICH_BAN_LIEU_TRINH_3_GIAI_DOAN.md` | 9743 | 2436 | Reference |
| `docs/APP_SPECIFICATION_ReConnect.md` | 9070 | 2268 | Reference |
| `reconnect_backend/docs/API_DESIGN.md` | 9003 | 2251 | Reference |
| `docs/THUAT_TOAN_RISK_INDEX.md` | 8264 | 2066 | Reference |
| `reconnect_backend/docs/DATABASE_DESIGN.md` | 7663 | 1916 | Reference |
| `CHANGELOG.md` | 7615 | 1904 | Core |
| `docs/brief.md` | 2420 | 605 | Core |
| `docs/plans/master-plan.md` | 2014 | 504 | Core |

> Lưu ý: Bảng này là “snapshot” để ra quyết định tối ưu context; số token thực tế phụ thuộc tokenizer.
