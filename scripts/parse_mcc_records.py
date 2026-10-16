import json
import re
from pathlib import Path

BASE = Path("data_sources/mcc/neet/2025")
SOURCE = BASE / "mcc_round1_2025_audit.json"
OUTPUT = BASE / "mcc_round1_2025_parsed_audit.json"

QUOTAS = [
    "Delhi NCR Children/Widows of Personnel of the Armed Forces (CW) DU Quota",
    "Delhi NCR Children/Widows of Personnel of the Armed Forces (CW) IP Quota",
    "Employees State Insurance Scheme Nursing Quota (ESI- IP Quota Nursing)",
    "(AMU) Self finance All India",
    "(AMU)Self finance internal",
    "Non-Resident Indian(Jamia)Quota",
    "Non-Resident Indian(AMU)Quota",
    "Deemed/Paid Seats Quota",
    "Open Seat Quota",
    "B.Sc Nursing IP CW Quota",
    "B.Sc Nursing Delhi NCR",
    "B.Sc Nursing All India",
    "Employees State Insurance Scheme(ESI)",
    "Aligarh Muslim University (AMU) Quota",
    "Internal -Puducherry UT Domicile",
    "Foreign Country Quota",
    "Delhi University Quota",
    "IP University Quota",
    "Jain Minority Quota",
    "Jamia Internal Quota",
    "Muslim Minority Quota",
    "Muslim OBC Quota",
    "Muslim Women Quota",
    "Muslim ST Quota",
    "Non-Resident Indian",
    "All India",
    "Muslim Quota",
    "Open Seat",
]

data = json.loads(SOURCE.read_text(encoding="utf-8"))
records = []
issues = []

COURSE_RE = re.compile(
    r"\s+(MBBS|BDS|B\.Sc\. Nursing)\s+(.+?)\s+Allotted(?:\s*\(.*\))?\s*$"
)
QUOTAS.sort(key=len, reverse=True)

for row in data["records"]:
    raw = " ".join(row["raw_lines"])
    match = COURSE_RE.search(raw)
    if not match:
        issues.append({"serial": row["serial"], "reason": "course/category unclear"})
        continue

    prefix = raw[:match.start()].strip()
    tail = match.group(2).split()
    quota = None
    college_raw = prefix

    for label in QUOTAS:
        if prefix.startswith(label + " "):
            quota = label
            college_raw = prefix[len(label):].strip()
            break

    if not quota:
        issues.append({"serial": row["serial"], "reason": "quota not recognized", "prefix": prefix})

    records.append({
        "serial": row["serial"],
        "rank": row["rank"],
        "page": row["page"],
        "course": match.group(1),
        "category_fields": tail,
        "quota": quota,
        "college_raw": college_raw,
        "raw": raw,
    })

report = {
    "source": data["source"],
    "pdf_pages": data["pdf_pages"],
    "input_records": len(data["records"]),
    "parsed_records": len(records),
    "issues_count": len(issues),
    "records": records,
    "issues": issues,
}
OUTPUT.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
print("Input:", len(data["records"]))
print("Parsed:", len(records))
print("Quota unrecognized:", len(issues))
print("Output:", OUTPUT)
