# 拉取某天素材：powershell -ExecutionPolicy Bypass -File scripts\pull-day.ps1 [-Date YYYY-MM-DD] [-AllowPending]
# 默认今天（Asia/Singapore）。规范见 AGENTS.md。
param([string]$Date = "", [switch]$AllowPending)
$ErrorActionPreference = "Continue"
function Fail($msg, $code) { Write-Host $msg -ForegroundColor Red; exit $code }
function Run { & $args[0] $args[1..($args.Count-1)]; if ($LASTEXITCODE -ne 0) { Fail ("命令失败: " + ($args -join " ")) 5 } }
if (-not $Date) { $Date = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow, "Singapore Standard Time").ToString("yyyy-MM-dd") }
if ($Date -notmatch '^\d{4}-\d{2}-\d{2}$') { Fail "日期格式应为 YYYY-MM-DD" 2 }
$Year = $Date.Substring(0,4); $Day = "$Year/$Date"; $Tag = "d$Date"
$top = (git rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $top) { Fail "请先在仓库内运行。首次使用：`n  `$env:GIT_LFS_SKIP_SMUDGE=1; git clone --filter=blob:none --sparse https://github.com/chchenghuiguo-alt/video-daily.git" 2 }
Set-Location $top
git lfs version *> $null
if ($LASTEXITCODE -ne 0) { Fail "未安装 Git LFS，请先安装并运行 git lfs install" 2 }
$env:GIT_LFS_SKIP_SMUDGE = "1"
git checkout -q main 2>$null
Run git pull -q --ff-only --tags origin main
Run git sparse-checkout set --no-cone /README.md /AGENTS.md /CLAUDE.md /.gitattributes /scripts/ /schema/ "/$Day/"
$ref = "main"; git rev-parse -q --verify "refs/tags/$Tag" *> $null; if ($LASTEXITCODE -eq 0) { $ref = $Tag }
$M = "$Day/manifest.json"
if (-not (Test-Path $M)) { Remove-Item Env:GIT_LFS_SKIP_SMUDGE; Fail "$Date 还没有素材（找不到 $M）" 3 }
$man = Get-Content $M -Raw -Encoding UTF8 | ConvertFrom-Json
if ($man.status -ne "ready" -and -not $AllowPending) { Remove-Item Env:GIT_LFS_SKIP_SMUDGE; Fail "$Date 的 manifest 状态是 '$($man.status)'，素材还没传完。稍后再试，或加 -AllowPending" 4 }
Remove-Item Env:GIT_LFS_SKIP_SMUDGE
Run git lfs pull --include="$Day/**"
$bad = 0
Get-ChildItem "$Day" -Directory | Where-Object { $_.Name -match '^\d{3}$' } | ForEach-Object {
  $meta = Get-Content (Join-Path $_.FullName "meta.json") -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($x in $meta.media) {
    $f = Join-Path $_.FullName $x.file
    if (-not (Test-Path $f)) { Write-Host "缺失: $f"; $bad++; continue }
    $h = (Get-FileHash $f -Algorithm SHA256).Hash.ToLower()
    if ($x.sha256 -and $h -ne $x.sha256) { Write-Host "校验失败: $f"; $bad++ }
  }
}
if ($bad -gt 0) { Fail "$bad 个文件缺失或校验失败" 6 }
Write-Host "✅ $Date 素材已就绪（ref: $ref）：$Day/" -ForegroundColor Green
Write-Host ("episode: " + $man.episode + "  order: " + ($(if ($man.order.Count) { $man.order -join "," } else { "(未选择，见 items)" })))
