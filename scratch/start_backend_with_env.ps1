$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot ".env.local"
$backendDir = Join-Path $repoRoot "reconnect_backend"

if (-not (Test-Path $envFile)) {
    Write-Error ".env.local not found at $envFile"
}

Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith("#")) {
        return
    }

    $parts = $line -split "=", 2
    if ($parts.Count -ne 2) {
        return
    }

    $key = $parts[0].Trim()
    $value = $parts[1]
    [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
}

Write-Host "Loaded .env.local into current process env." -ForegroundColor Green
Write-Host "AI_RAG_ENABLED=$env:AI_RAG_ENABLED" -ForegroundColor Cyan
Write-Host "AI_RAG_QDRANT_SCHEME=$env:AI_RAG_QDRANT_SCHEME" -ForegroundColor Cyan
Write-Host "AI_RAG_QDRANT_HOST=$env:AI_RAG_QDRANT_HOST" -ForegroundColor Cyan
Write-Host "AI_RAG_EMBEDDING_MODEL=$env:AI_RAG_EMBEDDING_MODEL" -ForegroundColor Cyan
Write-Host "GEMINI_API_KEY length=$($env:GEMINI_API_KEY.Length)" -ForegroundColor Cyan

Set-Location $backendDir
mvn spring-boot:run
