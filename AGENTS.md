# AGENTS.md — video-daily 仓库规范（给 AI agent 执行）

本文件是**规范性**的。MUST / MUST NOT 必须遵守。所有时间用 Asia/Singapore（UTC+8），时间戳必须带偏移（如 `2026-10-21T11:42:00+08:00`）。

## 0. 角色

| 角色 | 是谁 | 可写的路径 |
|---|---|---|
| uploader（上传方） | 收集素材的 agent（box 上的内容收集 bot） | 除 `*/_output/` 外的所有路径 |
| editor（剪辑方） | 剪辑电脑上的 agent（如 Claude Code）或人 | **只有** `YYYY/YYYY-MM-DD/_output/publish.json` |

每天产出 **一条** 合集视频 = 一期（episode）。

## 1. 目录与命名

```
YYYY/YYYY-MM-DD/
├── manifest.json            当天清单，schema/manifest.schema.json
├── index.md                 人读清单（由 manifest 生成）
├── NNN/                     收集编号，3 位数字，= 当天收集清单编号（不是期号，可不连续）
│   ├── post.md              中文文案，固定章节（见 §3）
│   ├── meta.json            schema/meta.schema.json
│   ├── images/NN.jpg        01.jpg、02.jpg…（视频封面/缩略图也放这里）
│   └── videos/NN.mp4        01.mp4、02.mp4…
└── _output/publish.json     只由 editor 写，schema/publish.schema.json
```

规则：
- 文件名 MUST 全小写；图片 MUST 是 `.jpg`，视频 MUST 是 `.mp4`；编号从 01 连续。
- 空的 `images/` 或 `videos/` 放 `.gitkeep`。
- 视频：H.264（yuv420p）+ AAC 128k，长边 ≤ 1080，CRF 23，`+faststart`。图片：JPEG，长边 ≤ 1920，质量约 85。
- 所有媒体走 Git LFS（`.gitattributes` 已配置）。MUST NOT 绕过 LFS 提交媒体。
- 成片、工程文件、未转码原片 MUST NOT 进仓库。

## 2. manifest.json（schema_version 2）

```json
{
  "schema_version": 2,
  "date": "2026-10-21",
  "timezone": "Asia/Singapore",
  "episode": 1,
  "status": "pending",
  "selection": "unknown",
  "items": [{"id": "001", "title": "…", "selected": null, "bytes": 40900000, "has_video": true, "duration": 393.9}],
  "order": [],
  "total_bytes": 77400000,
  "updated_at": "2026-10-21T11:45:00+08:00",
  "notes": "…"
}
```

- `status`：`pending` = 上传中；`ready` = 全部文件已推送。**editor 只处理 `ready`。**
- `selection`：`selected` = 用户已选，`order` 为合集顺序；`unknown` = 用户未选，`items[].selected = null`，`order = []`。
- `episode`：建议值 = 最近一个 `_output/publish.json` 中 `status=published` 的 episode + 1（没有则为 1）。**最终期号以 publish.json 为准。**
- `order` 中的每个 id MUST 出现在 `items` 中。

## 3. 条目文件

### meta.json（schema_version 2，`additionalProperties: false`）
必填：`schema_version, id, date, title, summary, source, source_url, published_at, collected_at, selected, verify_status, verification, media`。
`media[]` 必填：`file, type(image|video), w, h, bytes, sha256`；视频另含 `duration, fps, codec, has_audio, transcoded`。
`verify_status`：`unverified | partly_verified | verified | disputed`。可选 `suggested_clips: [{file, in, out, note}]`。

### post.md（中文，章节顺序固定）
```
# NNN 标题
## 标题
## 摘要        只依据原帖内容，不编造
## 待核实      逐条列出；没有写“- 无”
## 素材        每个文件：路径、类型、分辨率、时长
## 来源        账号、原帖 URL、发布时间（UTC+8）
```
可在 `## 来源` 之前追加 `## 建议口播`、`## 画面建议`（editor 读取时 MUST 忽略不认识的章节）。

### _output/publish.json（schema_version 1）
```json
{
  "schema_version": 1, "date": "2026-10-21", "episode": 1, "source_ref": "d2026-10-21",
  "title": "成片标题",
  "used": [{"id": "001", "files": ["videos/01.mp4"], "in": 12.0, "out": 30.5}],
  "skipped": ["007"], "duration_sec": 95.0, "status": "edited",
  "platforms": [{"name": "douyin", "url": null, "published_at": null}],
  "updated_at": "2026-10-21T20:00:00+08:00"
}
```
`status`: `draft | edited | published`。

## 4. uploader 流程（逐步执行）

前提：`export PATH=$HOME/.local/bin:$PATH`；`git lfs install` 已执行；工作区干净，`git pull --ff-only` 成功。

1. 确认当天收集目录有 `news.json` + `media/`。确定 `--selected`（用户选了就传逗号分隔 id；没选就省略 → 全部上传，`selection=unknown`）。
2. 计算 episode（§2）。
3. 生成文件（转码、post.md、meta.json、manifest.json 为 `pending`、index.md）：
   `python3 scripts/build-day.py <collect_dir> YYYY-MM-DD --episode N [--selected 001,003]`
   等价的 ffmpeg 命令：`ffmpeg -i in.mp4 -vf "scale='if(gt(iw,ih),min(1080,iw),-2)':'if(gt(iw,ih),-2,min(1080,ih))',format=yuv420p" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k -movflags +faststart videos/01.mp4`
4. 校验：`python3 scripts/validate.py YYYY-MM-DD`（需 `jsonschema`）。失败 MUST 修复后再继续。
5. 容量检查：当天 `total_bytes` 建议 ≤ 150 MB；仓库 LFS 累计（`git lfs ls-files -s` 求和）接近 800 MB 时 MUST 停止并通知用户换新仓库（如 `video-daily-2026-11`）。
6. 提交 1（状态 pending）：`git add YYYY/YYYY-MM-DD && git commit -m "data(YYYY-MM-DD): N items, pending" && git push`
7. 确认 LFS 已上传：`git lfs ls-files -I "YYYY/YYYY-MM-DD/**"` 列出全部媒体，且 `git lfs push --all origin` 无报错。
8. 提交 2（**最后一步才改 ready**）：只把 manifest 的 `status` 改为 `ready`、更新 `updated_at`，`git commit -m "ready(YYYY-MM-DD)" && git push`。
9. 打 tag：`git tag -a dYYYY-MM-DD -m "YYYY-MM-DD ready" && git push origin dYYYY-MM-DD`。
10. 之后若需修改（如用户补选）：改 manifest/meta → 提交 → 用 `git tag -f -a` 移动 tag 并 `git push -f origin dYYYY-MM-DD`，并通知 editor。不得在 ready 状态下删除已有条目。

## 5. editor 流程（逐步执行）

首次：`GIT_LFS_SKIP_SMUDGE=1 git clone --filter=blob:none --sparse https://github.com/chchenghuiguo-alt/video-daily.git`

1. 在仓库目录运行 `bash scripts/pull-day.sh YYYY-MM-DD`（Windows：`powershell -ExecutionPolicy Bypass -File scripts\pull-day.ps1 -Date YYYY-MM-DD`）。
   退出码：0 就绪；3 当天无素材；4 状态不是 ready（稍后重试，MUST NOT 开始剪辑）；5/6 git 或校验失败。
2. 读 `manifest.json`：
   - `selection=selected` → 按 `order` 顺序剪。
   - `selection=unknown` → 不要自作主张发布；可按 `items` 准备草稿，或等用户给出顺序。
3. 读每个条目的 `post.md` 和 `meta.json`。`待核实` 中的说法在字幕/口播里 MUST 带“据称/厂商称/待核实”等措辞；画面 MUST 标注 `credit`。
4. 把需要的文件**复制**到本地剪辑工程目录（仓库外），在工程里剪。MUST NOT 在仓库里改素材。
5. 写 `YYYY/YYYY-MM-DD/_output/publish.json`（`source_ref` 填 tag 名），然后：
   `git add YYYY/YYYY-MM-DD/_output/publish.json && git commit -m "publish(YYYY-MM-DD): episode N" && git pull --rebase && git push`
6. 发布后把 `status` 改为 `published`、填 `platforms[].url/published_at`，再提交一次。

## 6. Do / Don't

Do
- 先 pull 再写；提交信息用 `data(...)` / `ready(...)` / `publish(...)` 前缀。
- 所有 JSON 用 UTF-8、2 空格缩进、`ensure_ascii=false`。
- 只依据原帖写摘要；不确定就写进 `待核实`。

Don't
- 不要提交成片 mp4、工程文件、原始未转码视频、账号/密码/手机号/验证码。
- editor 不要改 `_output/` 以外的文件；uploader 不要改 `_output/`。
- 不要在 `status=pending` 时剪辑；不要在所有媒体推送之前把 status 改成 `ready`。
- 不要 force-push `main`，不要重写历史（LFS 文件删不掉，重写也不省额度）。

## 7. 容量

GitHub 免费 Git LFS 约 1 GB 存储 + 有限带宽（公开仓库别人下载也算）。每天目标 ≤ 150 MB；超过 800 MB 累计就换新仓库（按月或按季度，如 `video-daily-2026-11`），旧仓库保留只读。
