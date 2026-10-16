from pypdf import PdfReader
import re
import json

PDF = "data_sources/mcc/neet/2025/mcc_round1_2025.pdf"
OUT = "data_sources/mcc/neet/2025/mcc_round1_2025_audit.json"
START = re.compile(r"^\s*(\d+)\s+(\d+(?:\.\d+)?)\s+(.+)$")
reader = PdfReader(PDF)
rows = []
current = None

for page_no, page in enumerate(reader.pages, 1):
    for line in (page.extract_text() or "").splitlines():
        m = START.match(line)
        if m and 1 <= int(m.group(1)) <= 26608:
            if current:
                rows.append(current)
            current = {
                "serial": int(m.group(1)),
                "rank": float(m.group(2)),
                "page": page_no,
                "raw_lines": [m.group(3).strip()],
            }
        elif current and line.strip():
            current["raw_lines"].append(line.strip())

if current:
    rows.append(current)

valid_serials = [r["serial"] for r in rows]
report = {
    "source": "MCC NEET-UG Round 1 2025 official allotment list",
    "pdf_pages": len(reader.pages),
    "record_count": len(rows),
    "serials_sequential": valid_serials == list(range(1, 26609)),
    "records": rows,
}
with open(OUT, "w", encoding="utf-8") as f:
    json.dump(report, f, ensure_ascii=False, indent=2)

print("Records:", len(rows))
print("Sequential:", report["serials_sequential"])
print("First record:", rows[0] if rows else "NONE")
print("Output:", OUT)
