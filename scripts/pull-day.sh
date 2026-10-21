#!/usr/bin/env bash
# 拉取某天素材：bash scripts/pull-day.sh [YYYY-MM-DD]（默认今天，Asia/Singapore）
set -euo pipefail
DATE="${1:-$(TZ=Asia/Singapore date +%F)}"
[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "日期格式应为 YYYY-MM-DD" >&2; exit 1; }
YEAR="${DATE:0:4}"
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "请先在仓库内运行。首次使用：" >&2
  echo "  GIT_LFS_SKIP_SMUDGE=1 git clone --filter=blob:none --sparse https://github.com/chchenghuiguo-alt/video-daily.git" >&2
  exit 1; }
command -v git-lfs >/dev/null || { echo "未安装 Git LFS，请先安装并运行 git lfs install" >&2; exit 1; }
GIT_LFS_SKIP_SMUDGE=1 git pull --ff-only
git sparse-checkout set --no-cone /README.md /scripts/ "/$YEAR/$DATE/"
git lfs pull --include="$YEAR/$DATE/**"
M="$YEAR/$DATE/manifest.json"
if [[ ! -f "$M" ]]; then
  echo "⚠️ $DATE 还没有素材（找不到 $M）" >&2; exit 0
fi
if ! grep -Eq '"status"[[:space:]]*:[[:space:]]*"ready"' "$M"; then
  echo "⚠️ $DATE 的 manifest 状态不是 ready，素材可能还没传完" >&2
else
  echo "✅ $DATE 素材已就绪：$YEAR/$DATE/"
fi
