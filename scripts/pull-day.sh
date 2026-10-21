#!/usr/bin/env bash
# 拉取某天素材：bash scripts/pull-day.sh [YYYY-MM-DD] [--allow-pending]
# 默认今天（Asia/Singapore）。规范见 AGENTS.md。
set -euo pipefail
DATE=""; ALLOW_PENDING=0
for a in "$@"; do
  case "$a" in
    --allow-pending) ALLOW_PENDING=1 ;;
    *) DATE="$a" ;;
  esac
done
DATE="${DATE:-$(TZ=Asia/Singapore date +%F)}"
[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "日期格式应为 YYYY-MM-DD" >&2; exit 2; }
YEAR="${DATE:0:4}"; DAY="$YEAR/$DATE"; TAG="d$DATE"
TOP="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$TOP" ]]; then
  echo "请先在仓库内运行。首次使用：" >&2
  echo "  GIT_LFS_SKIP_SMUDGE=1 git clone --filter=blob:none --sparse https://github.com/chchenghuiguo-alt/video-daily.git" >&2
  exit 2
fi
cd "$TOP"
command -v git-lfs >/dev/null || { echo "未安装 Git LFS，请先安装并运行 git lfs install" >&2; exit 2; }
PY="$(command -v python3 || command -v python || true)"
[[ -n "$PY" ]] || { echo "需要 python3 来读取 manifest.json" >&2; exit 2; }

export GIT_LFS_SKIP_SMUDGE=1
git checkout -q main 2>/dev/null || true
git pull -q --ff-only --tags origin main
git sparse-checkout set --no-cone /README.md /AGENTS.md /CLAUDE.md /.gitattributes /scripts/ /schema/ "/$DAY/"

REF=main
if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then REF="$TAG"; fi

M="$DAY/manifest.json"
if [[ ! -f "$M" ]]; then echo "❌ $DATE 还没有素材（找不到 $M）" >&2; exit 3; fi
STATUS="$("$PY" -c 'import json,sys;print(json.load(open(sys.argv[1],encoding="utf-8")).get("status",""))' "$M")"
if [[ "$STATUS" != "ready" && $ALLOW_PENDING -eq 0 ]]; then
  echo "⏳ $DATE 的 manifest 状态是 '$STATUS'，素材还没传完。稍后再试，或加 --allow-pending" >&2; exit 4
fi
unset GIT_LFS_SKIP_SMUDGE
git lfs pull --include="$DAY/**"

# 校验 sha256
"$PY" - "$DAY" <<'PYEOF'
import json,sys,hashlib,pathlib
day=pathlib.Path(sys.argv[1]); bad=0
for meta in sorted(day.glob("[0-9][0-9][0-9]/meta.json")):
    m=json.load(open(meta,encoding="utf-8"))
    for x in m.get("media",[]):
        f=meta.parent/x["file"]
        if not f.exists(): print("缺失:",f); bad+=1; continue
        h=hashlib.sha256(f.read_bytes()).hexdigest()
        if x.get("sha256") and h!=x["sha256"]: print("校验失败:",f); bad+=1
sys.exit(1 if bad else 0)
PYEOF
echo "✅ $DATE 素材已就绪（ref: $REF）：$DAY/"
"$PY" -c 'import json,sys;m=json.load(open(sys.argv[1],encoding="utf-8"));print("episode:",m.get("episode"),"order:",m.get("order") or "(未选择，见 items)")' "$M"
