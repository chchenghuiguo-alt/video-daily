# video-daily

每日机器人热点素材仓库。每天收集、选中的素材（图片、视频、文案）上传到这里，剪辑电脑按日期拉取，**每天剪一条合集视频**。

> 🤖 **AI agent 请先读 [AGENTS.md](AGENTS.md)**（上传方和剪辑方的完整规范、文件格式和步骤）。

> ⚠️ 本仓库是 **公开（public）** 仓库，任何人都能看到和下载其中内容。请不要放入账号、密码、手机号、未授权或不宜公开的素材；素材版权归原作者，来源见各条 `post.md` / `meta.json`。

## 目录结构

```
video-daily/
├── README.md
├── .gitattributes          图片/音视频走 Git LFS
├── scripts/pull-day.sh     剪辑电脑拉取某天素材（macOS/Linux）
├── scripts/pull-day.ps1    同上（Windows）
├── AGENTS.md / CLAUDE.md   给 AI agent 的规范
├── scripts/build-day.py    上传方：生成当天文件夹（转码+文案+manifest）
├── scripts/validate.py     校验当天文件夹（schema + sha256）
├── schema/                 manifest / meta / publish 三个 JSON Schema
└── YYYY/
    └── YYYY-MM-DD/
        ├── manifest.json   当天清单（剪辑以此为准）
        ├── index.md        人读版清单
        ├── <收集编号，如 003>/
        │   ├── post.md     文案：标题、要点、待核实、来源
        │   ├── meta.json   机器可读元数据（见 schema）
        │   ├── images/01.jpg …
        │   └── videos/01.mp4 …
        └── _output/publish.json   仅由剪辑电脑写入
```

- 文件夹编号是**当天收集清单的编号**，不是期号，可能不连续（如 003、005）。
- 用户选好条目时只上传选中的；**用户还没选时上传当天收集的全部条目**，`manifest.json` 里 `selection: "unknown"`、`order: []`、各条 `selected: null`。
- 视频统一转码为 H.264，长边不超过 1080。
- **成片 mp4 不放进仓库**；剪辑电脑只回写 `_output/publish.json`（用了哪些条目、发布链接等）。

### manifest.json

字段见 `schema/manifest.schema.json` 和 AGENTS.md §2。要点：`status` 为 `pending`（上传中）/ `ready`（上传完成，**只有 ready 才能剪**）；`ready` 永远是最后一次提交，随后打 tag `dYYYY-MM-DD`。

## 剪辑电脑使用方法

需要先安装 git 和 [Git LFS](https://git-lfs.com)（`git lfs install`）。

首次克隆（不下载任何大文件，只建稀疏工作区）：

```bash
GIT_LFS_SKIP_SMUDGE=1 git clone --filter=blob:none --sparse https://github.com/chchenghuiguo-alt/video-daily.git
cd video-daily
git sparse-checkout set --no-cone /README.md /AGENTS.md /CLAUDE.md /.gitattributes /scripts/ /schema/
```

Windows PowerShell：

```powershell
$env:GIT_LFS_SKIP_SMUDGE=1; git clone --filter=blob:none --sparse https://github.com/chchenghuiguo-alt/video-daily.git; Remove-Item Env:GIT_LFS_SKIP_SMUDGE
cd video-daily
git sparse-checkout set --no-cone /README.md /AGENTS.md /CLAUDE.md /.gitattributes /scripts/ /schema/
```

每天拉取当天素材（默认今天，新加坡时间）：

```bash
bash scripts/pull-day.sh              # 今天
bash scripts/pull-day.sh 2026-10-21   # 指定日期
bash scripts/pull-day.sh 2026-10-21 --allow-pending   # 未就绪也拉
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts\pull-day.ps1 [-Date 2026-10-21]
```

脚本会：`git pull --ff-only --tags` → 稀疏检出只保留说明、scripts、schema 和当天文件夹 → 检查 `manifest.json` 是否 `ready`（不是则退出码 4，不下载）→ `git lfs pull` 只下载当天的大文件 → 按 `meta.json` 校验 sha256。

## 容量说明

GitHub Git LFS 免费额度约 **1 GB 存储**（另有带宽限制），超出需购买数据包；进了历史的文件很难真正删除。每天约几百 MB，每天目标 ≤150 MB，累计接近 800 MB 时换新仓库（如 `video-daily-2026-11`）。
