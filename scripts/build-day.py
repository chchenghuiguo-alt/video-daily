#!/usr/bin/env python3
"""上传方工具：把收集目录（news.json + media/）转成仓库里的当天文件夹。
用法: python3 scripts/build-day.py <collect_dir> <YYYY-MM-DD> --episode N [--selected 001,003]
只写文件、manifest.status=pending；提交/改 ready/打 tag 见 AGENTS.md。
"""
import argparse, json, hashlib, pathlib, subprocess, datetime as dt, sys
TZ = dt.timezone(dt.timedelta(hours=8))
ap = argparse.ArgumentParser()
ap.add_argument("collect_dir"); ap.add_argument("date"); ap.add_argument("--episode", type=int, required=True)
ap.add_argument("--selected", default=""); ap.add_argument("--max-long", type=int, default=1080); ap.add_argument("--crf", type=int, default=23)
a = ap.parse_args()
src = pathlib.Path(a.collect_dir); news = json.load(open(src / "news.json", encoding="utf-8"))
root = pathlib.Path(__file__).resolve().parent.parent
day = root / a.date[:4] / a.date
day.mkdir(parents=True, exist_ok=True)
sel = set(filter(None, a.selected.split(",")))
now = dt.datetime.now(TZ).isoformat(timespec="seconds")

def probe(f):
    j = json.loads(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "stream=codec_type,codec_name,width,height,r_frame_rate:format=duration",
                                   "-of", "json", str(f)], capture_output=True, text=True, check=True).stdout)
    v = next(s for s in j["streams"] if s["codec_type"] == "video")
    n, d = v.get("r_frame_rate", "0/1").split("/")
    return dict(w=v["width"], h=v["height"], codec=v["codec_name"], fps=round(int(n) / int(d), 2) if int(d) else None,
                has_audio=any(s["codec_type"] == "audio" for s in j["streams"]), duration=round(float(j["format"].get("duration", 0)), 2))

def sha(f): return hashlib.sha256(f.read_bytes()).hexdigest()
scale = f"scale='if(gt(iw,ih),min({a.max_long},iw),-2)':'if(gt(iw,ih),-2,min({a.max_long},ih))'"
items = []
for it in news["items"]:
    d = day / it["id"]; (d / "images").mkdir(parents=True, exist_ok=True); (d / "videos").mkdir(parents=True, exist_ok=True)
    media = []; vi = ii = 0
    for m in it["media"]:
        f = src / m["file"]
        if m["type"] == "video":
            vi += 1; out = d / "videos" / f"{vi:02d}.mp4"
            subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(f), "-vf", scale + ",format=yuv420p", "-c:v", "libx264", "-preset", "medium",
                            "-crf", str(a.crf), "-c:a", "aac", "-b:a", "128k", "-movflags", "+faststart", str(out)], check=True)
            p = probe(out); media.append(dict(file=f"videos/{vi:02d}.mp4", type="video", **p, transcoded=True, bytes=out.stat().st_size, sha256=sha(out), orig_name=f.name))
            if m.get("thumb"):
                ii += 1; t = d / "images" / f"{ii:02d}.jpg"
                subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(src / m["thumb"]), "-vf", "scale='min(1920,iw)':-2", "-q:v", "3", str(t)], check=True)
                p = probe(t); media.append(dict(file=f"images/{ii:02d}.jpg", type="image", w=p["w"], h=p["h"], duration=None, transcoded=True, bytes=t.stat().st_size, sha256=sha(t), orig_name=pathlib.Path(m["thumb"]).name))
        else:
            ii += 1; t = d / "images" / f"{ii:02d}.jpg"
            subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(f), "-vf", "scale='min(1920,iw)':-2", "-q:v", "3", str(t)], check=True)
            p = probe(t); media.append(dict(file=f"images/{ii:02d}.jpg", type="image", w=p["w"], h=p["h"], duration=None, transcoded=True, bytes=t.stat().st_size, sha256=sha(t), orig_name=f.name))
    for sub in ("images", "videos"):
        if not any((d / sub).iterdir()): (d / sub / ".gitkeep").write_text("")
    selected = (it["id"] in sel) if sel else None
    acct = it.get("account") or it["source"]
    meta = dict(schema_version=2, id=it["id"], date=a.date, title=it["title"], summary=it["summary"], category=it.get("category", ""), company=it.get("company", ""),
                source=it["source"], source_url=it["url"], published_at=it.get("published_at"), collected_at=now, engagement=it.get("engagement", {}),
                selected=selected, verify_status="unverified" if it.get("verification") else "partly_verified", verification=it.get("verification", []),
                credit=f"来源：X @{acct}", license_note="素材版权归原作者；剪辑时须在画面标注来源，非官方/搬运素材有版权风险", media=media)
    json.dump(meta, open(d / "meta.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    ver = "\n".join(f"- {v}" for v in it.get("verification", [])) or "- 无"
    files = "\n".join(f"- `{m['file']}`：{'视频' if m['type']=='video' else '图片'} {m['w']}×{m['h']}" + (f"，{m['duration']} 秒" if m.get("duration") else "") for m in media)
    (d / "post.md").write_text(f"# {it['id']} {it['title']}\n\n## 标题\n\n{it['title']}\n\n## 摘要\n\n{it['summary']}\n\n## 待核实\n\n{ver}\n\n## 素材\n\n{files}\n\n## 来源\n\n- {it['source']}\n- 原帖：{it['url']}\n- 发布时间：{it.get('time','')}\n", encoding="utf-8")
    b = sum(m["bytes"] for m in media)
    items.append(dict(id=it["id"], title=it["title"], selected=selected, bytes=b, has_video=any(m["type"] == "video" for m in media),
                      duration=sum(m.get("duration") or 0 for m in media if m["type"] == "video") or None))
total = sum(i["bytes"] for i in items)
man = dict(schema_version=2, date=a.date, timezone="Asia/Singapore", episode=a.episode, status="pending", selection="selected" if sel else "unknown",
           items=items, order=[i for i in [x["id"] for x in items] if i in sel] if sel else [], total_bytes=total, updated_at=now,
           notes="" if sel else "用户尚未选择条目：上传了当天收集的全部条目，selected=null，order 为空。")
json.dump(man, open(day / "manifest.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
rows = "\n".join(f"| {i['id']} | {i['title']} | {'是' if i['selected'] else ('否' if i['selected'] is False else '未定')} | {'视频' if i['has_video'] else '图片'} | {i['bytes']/1e6:.1f} MB |" for i in items)
(day / "index.md").write_text(f"# {a.date} 素材清单（第 {a.episode} 期，建议）\n\n状态见 `manifest.json`。{man['notes']}\n\n| 编号 | 标题 | 选中 | 素材 | 大小 |\n|---|---|---|---|---|\n{rows}\n\n合计 {total/1e6:.1f} MB\n", encoding="utf-8")
print(json.dumps(dict(day=str(day.relative_to(root)), total_mb=round(total / 1e6, 1)), ensure_ascii=False))
