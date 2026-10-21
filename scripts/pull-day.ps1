# 拉取某天素材：powershell -ExecutionPolicy Bypass -File scripts\pull-day.ps1 [-Date YYYY-MM-DD]
param([string]$Date)
$ErrorActionPreference = 'Stop'
if (-not $Date) {
  $tz = [TimeZoneInfo]::FindSystemTimeZoneById($(if ($IsLinux -or $IsMacOS) {'Asia/Singapore'} else {'Singapore Standard Time'}))
  $Date = [TimeZoneInfo]::ConvertTimeFromUtc([DateTime]::UtcNow, $tz).ToString('yyyy-MM-dd')
}
if ($Date -notmatch '^\d{4}-\d{2}-\d{2}$') { throw '日期格式应为 YYYY-MM-DD' }
$Year = $Date.Substring(0,4)
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) {
  Write-Host '请先在仓库内运行。首次使用：'
  Write-Host '  $env:GIT_LFS_SKIP_SMUDGE=1; git clone --filter=blob:none --sparse https://github.com/chchenghuiguo-alt/video-daily.git'
  exit 1
}
Set-Location $root
git lfs version *> $null; if ($LASTEXITCODE -ne 0) { throw '未安装 Git LFS，请先安装并运行 git lfs install' }
$env:GIT_LFS_SKIP_SMUDGE = '1'
git pull --ff-only; if ($LASTEXITCODE -ne 0) { throw 'git pull 失败' }
Remove-Item Env:GIT_LFS_SKIP_SMUDGE
git sparse-checkout set --no-cone /README.md /scripts/ "/$Year/$Date/"
git lfs pull --include="$Year/$Date/**"
$m = "$Year/$Date/manifest.json"
if (-not (Test-Path $m)) { Write-Warning "$Date 还没有素材（找不到 $m）"; exit 0 }
$status = (Get-Content $m -Raw -Encoding UTF8 | ConvertFrom-Json).status
if ($status -ne 'ready') { Write-Warning "$Date 的 manifest 状态是 '$status'，不是 ready，素材可能还没传完" }
else { Write-Host "✅ $Date 素材已就绪：$Year/$Date/" }
