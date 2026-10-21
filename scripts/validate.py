#!/usr/bin/env python3
"""校验某天文件夹：python3 scripts/validate.py YYYY-MM-DD （需 pip install jsonschema）"""
import json, sys, pathlib, hashlib, jsonschema
root = pathlib.Path(__file__).resolve().parent.parent; date = sys.argv[1]; day = root / date[:4] / date
S = lambda n: json.load(open(root / "schema" / n, encoding="utf-8"))
man = json.load(open(day / "manifest.json", encoding="utf-8")); jsonschema.validate(man, S("manifest.schema.json"))
ids = {i["id"] for i in man["items"]}; assert set(man["order"]) <= ids, "order 中有未知 id"
for i in ids:
    m = json.load(open(day / i / "meta.json", encoding="utf-8")); jsonschema.validate(m, S("meta.schema.json"))
    assert m["id"] == i and m["date"] == date
    for x in m["media"]:
        f = day / i / x["file"]; assert hashlib.sha256(f.read_bytes()).hexdigest() == x["sha256"], f"sha256 不符: {f}"
    assert (day / i / "post.md").exists()
p = day / "_output" / "publish.json"
if p.exists(): jsonschema.validate(json.load(open(p, encoding="utf-8")), S("publish.schema.json"))
print("OK", date, len(ids), "items", round(man["total_bytes"] / 1e6, 1), "MB")
