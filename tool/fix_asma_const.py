from pathlib import Path
p = Path(r"c:\DEV\Back to pray _update\lib\data\asma_ul_husna.dart")
t = p.read_text(encoding="utf-8")
t2 = t.replace("themeIds: const ['", "themeIds: ['")
p.write_text(t2, encoding="utf-8")
print("replaced", t.count("themeIds: const ['"), "occurrences")

g = Path(r"c:\DEV\Back to pray _update\tool\gen_asma.py")
gt = g.read_text(encoding="utf-8")
g.write_text(gt.replace("themeIds: const ['{theme}']", "themeIds: ['{theme}']"), encoding="utf-8")
