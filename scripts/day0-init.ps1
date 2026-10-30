# FixDesk - Day 0 bootstrap
# Run from the repo root (the folder that contains README.md):
#   pwsh -ExecutionPolicy Bypass -File .\scripts\day0-init.ps1
# This script only does local work: git init + first commit + folder skeleton.
# It never pushes anything and never touches your global git config.

$ErrorActionPreference = 'Stop'

function Write-Step($n, $msg) { Write-Host "[$n] $msg" -ForegroundColor Cyan }
function Write-Ok($msg)       { Write-Host "    OK  $msg" -ForegroundColor Green }
function Write-Warn2($msg)    { Write-Host "    !!  $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "FixDesk - Day 0 bootstrap" -ForegroundColor White
Write-Host "-------------------------" -ForegroundColor DarkGray

# ---------- 1. preflight ----------
Write-Step "1/5" "checking git"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "    git not found on PATH." -ForegroundColor Red
    Write-Host "    Install it first, then re-open the terminal:" -ForegroundColor Red
    Write-Host "      winget install --id Git.Git -e" -ForegroundColor Yellow
    exit 1
}
Write-Ok ("git " + (git --version).Split(' ')[2])

$name  = git config --global user.name
$email = git config --global user.email
if (-not $name -or -not $email) {
    Write-Host ""
    Write-Host "    git identity is not configured yet. Run these two lines first:" -ForegroundColor Red
    Write-Host '      git config --global user.name  "your name"' -ForegroundColor Yellow
    Write-Host '      git config --global user.email "you@example.com"' -ForegroundColor Yellow
    Write-Host "    (use the same email as your Gitee/GitHub account)" -ForegroundColor DarkGray
    exit 1
}
Write-Ok "identity: $name <$email>"

# ---------- 2. repo ----------
Write-Step "2/5" "git init"

if (Test-Path .git) {
    Write-Warn2 ".git already exists, skipping init"
} else {
    git init -b main | Out-Null
    Write-Ok "initialized on branch main"
}

# ---------- 3. skeleton ----------
Write-Step "3/5" "creating folder skeleton"

$dirs = @(
    'src/main/java',
    'src/main/resources',
    'src/test/java',
    'sql',
    'docs/review',
    'docs/design',
    'docs/test',
    'docs/postmortem',
    'docs/release',
    'docs/retro',
    'docs/demo'
)
foreach ($d in $dirs) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
    $keep = Join-Path $d '.gitkeep'
    if (-not (Test-Path $keep)) { New-Item -ItemType File -Path $keep | Out-Null }
}
Write-Ok ($dirs.Count.ToString() + " folders ready")

if (-not (Test-Path 'blockers.md')) {
    # ASCII only on purpose: Windows PowerShell 5.1 misreads UTF-8 files without BOM.
    # The real Chinese template lives in the repo; this is only a fallback.
    $blockers = @'
# Blockers

> Write down anything that blocked you for more than 40 minutes.
> Solve it first thing next evening. Do not push through, do not give up.

| Date | Where | Error / symptom | Solved |
|---|---|---|---|
| 2026-10-24 | example: mvn download timeout | Could not resolve dependencies | no |
'@
    Set-Content -Path 'blockers.md' -Value $blockers -Encoding utf8
    Write-Ok "blockers.md created (fallback template)"
}

# ---------- 4. first commit ----------
Write-Step "4/5" "first commit"

git add -A
$pending = git status --porcelain
if (-not $pending) {
    Write-Warn2 "nothing to commit"
} else {
    git commit -m "chore: bootstrap repo with project plan docs" | Out-Null
    $hash = (git rev-parse --short HEAD)
    Write-Ok "commit $hash"
}

# ---------- 5. next steps ----------
Write-Step "5/5" "next steps"
Write-Host ""
Write-Host "  1. Create an EMPTY private repo on Gitee/GitHub (no README, no license)." -ForegroundColor White
Write-Host "  2. Then run:" -ForegroundColor White
Write-Host "       git remote add origin git@gitee.com:<you>/fixdesk.git" -ForegroundColor Yellow
Write-Host "       git push -u origin main" -ForegroundColor Yellow
Write-Host ""
Write-Host "  3. Protect main: repo settings -> branch protection -> require PR before merge." -ForegroundColor White
Write-Host "  4. Open the 15 issues from docs/01, label them feat/bug/tech, P0/P1/P2." -ForegroundColor White
Write-Host "  5. Create your first working branch:" -ForegroundColor White
Write-Host "       git switch -c feature/02-db-design" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Today's card: docs/02, Day 1. Do not start coding yet." -ForegroundColor DarkGray
Write-Host ""
