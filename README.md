# video-daily

每日机器人热点素材仓库。每天收集、选中的素材（图片、视频、文案）上传到这里，剪辑电脑按日期拉取，**每天剪一条合集视频**。

> ⚠️ 本仓库是 **公开（public）** 仓库，任何人都能看到和下载其中内容。请不要放入账号、密码、手机号、未授权或不宜公开的素材；素材版权归原作者，来源见各条 `post.md` / `meta.json`。

## 目录结构

```
video-daily/
├── README.md
├── .gitattributes          图片/音视频走 Git LFS
├── scripts/pull-day.sh     剪辑电脑拉取某天素材（macOS/Linux）
├── scripts/pull-day.ps1    同上（Windows）
├── schema/meta.schema.json meta.json 的字段说明
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
- 只上传**被选中**的条目。
- 视频统一转码为 H.264，长边不超过 1080。
- **成片 mp4 不放进仓库**；剪辑电脑只回写 `_output/publish.json`（用了哪些条目、发布链接等）。

### manifest.json

```json
{
  "schema_version": 1,
  "date": "2026-10-21",
  "episode": 1,
  "order": ["003", "001", "005"],
  "status": "pending"
}
```

- `episode`：期号，每天一期，按天递增。
- `order`：合集中的剪辑顺序（收集编号）。
- `status`：`pending` 上传中 / `ready` 全部上传完成。**只有 `ready` 才可以开始剪辑。**

## 剪辑电脑使用方法

需要先安装 git 和 [Git LFS](https://git-lfs.com)（`git lfs install`）。

首次克隆（不下载任何大文件，只建稀疏工作区）：

```bash
GIT_LFS_SKIP_SMUDGE=1 git clone --filter=blob:none --sparse https://github.com/chchenghuiguo-alt/video-daily.git
cd video-daily
```

Windows PowerShell：

```powershell
$env:GIT_LFS_SKIP_SMUDGE=1; git clone --filter=blob:none --sparse https://github.com/chchenghuiguo-alt/video-daily.git; Remove-Item Env:GIT_LFS_SKIP_SMUDGE
cd video-daily
```

每天拉取当天素材（默认今天，新加坡时间）：

```bash
bash scripts/pull-day.sh              # 今天
bash scripts/pull-day.sh 2026-10-21   # 指定日期
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts\pull-day.ps1 [-Date 2026-10-21]
```

脚本会：`git pull --ff-only` → 稀疏检出只保留 README、scripts 和当天文件夹 → `git lfs pull` 只下载当天的大文件 → 若 `manifest.json` 不是 `ready` 会给出警告。

## 容量说明

GitHub Git LFS 免费额度约 **1 GB 存储**（另有带宽限制），超出需购买数据包；进了历史的文件很难真正删除。每天约几百 MB，必要时**按季度换新仓库**，如 `video-daily-2026Q4`。
