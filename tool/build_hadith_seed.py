import json
import urllib.request
from collections import defaultdict
from pathlib import Path


def get(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": "AlNoor/1.0"})
    with urllib.request.urlopen(req, timeout=120) as response:
        return json.loads(response.read().decode("utf-8"))


def main() -> None:
    eng = get(
        "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/eng-nawawi.min.json"
    )
    ara = get(
        "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-nawawi.min.json"
    )
    ara_by = {h["hadithnumber"]: h for h in ara["hadiths"]}
    merged = []
    for h in eng["hadiths"]:
        a = ara_by.get(h["hadithnumber"], {})
        merged.append(
            {
                "id": f"nawawi:{h['hadithnumber']}",
                "collection": "nawawi",
                "collectionName": "Forty Hadith of an-Nawawi",
                "number": h["hadithnumber"],
                "arabicNumber": h.get("arabicnumber", h["hadithnumber"]),
                "arabic": a.get("text", ""),
                "english": h.get("text", ""),
                "grades": h.get("grades") or [],
                "reference": h.get("reference") or {},
                "section": {},
            }
        )

    eng_b = get(
        "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/eng-bukhari.min.json"
    )
    ara_b = get(
        "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-bukhari.min.json"
    )
    ara_bb = {h["hadithnumber"]: h for h in ara_b["hadiths"]}

    keywords = {
        "prayer": ["prayer", "salat", "pray"],
        "fasting": ["fast", "ramadan"],
        "faith": ["faith", "belief"],
        "character": ["character", "manners", "neighbor", "truthful"],
        "patience": ["patience", "patient"],
        "gratitude": ["thank", "gratitude"],
        "repentance": ["repent", "forgiveness", "forgive"],
        "knowledge": ["knowledge", "learn"],
    }
    picked = set()
    seed = []
    for h in eng_b["hadiths"]:
        text = (h.get("text") or "").lower()
        if len(text) < 40:
            continue
        hit = None
        for cat, kws in keywords.items():
            if any(k in text for k in kws):
                hit = cat
                break
        if not hit:
            continue
        n = h["hadithnumber"]
        if n in picked:
            continue
        picked.add(n)
        a = ara_bb.get(n, {})
        seed.append(
            {
                "id": f"bukhari:{n}",
                "collection": "bukhari",
                "collectionName": "Sahih al-Bukhari",
                "number": n,
                "arabicNumber": h.get("arabicnumber", n),
                "arabic": a.get("text", ""),
                "english": h.get("text", ""),
                "grades": [],
                "reference": h.get("reference") or {},
                "section": {},
                "seedCategory": hit,
            }
        )

    by = defaultdict(list)
    for item in seed:
        by[item["seedCategory"]].append(item)
    balanced = []
    for items in by.values():
        balanced.extend(items[:12])

    out = {
        "_meta": {
            "source": "https://github.com/fawazahmed0/hadith-api",
            "license": "Unlicense",
            "attribution": (
                "Hadith texts from fawazahmed0/hadith-api (Unlicense). "
                "Collection names preserved. Grades shown only when provided by that dataset."
            ),
            "bundled": ["nawawi", "bukhari-seed"],
        },
        "hadiths": merged + balanced,
    }
    path = Path("assets/hadith")
    path.mkdir(parents=True, exist_ok=True)
    target = path / "library_seed.json"
    target.write_text(json.dumps(out, ensure_ascii=False), encoding="utf-8")
    print("bytes", target.stat().st_size)
    print("total", len(out["hadiths"]))
    print("cats", {k: min(12, len(v)) for k, v in by.items()})


if __name__ == "__main__":
    main()
