param(
    [string]$RootPath = "$env:APPDATA\Code - Insiders\User\globalStorage\github.copilot-chat",
    [string[]]$AllowedTools = @(
        "search",
        "read",
        "web",
        "vscode/memory",
        "execute/getTerminalOutput",
        "execute/testFailure",
        "vscode.mermaid-chat-features/renderMermaidDiagram",
        "vscode/askQuestions",
        "agent"
    )
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $RootPath)) {
    Write-Error "Root path not found: $RootPath"
    exit 2
}

$agentFiles = Get-ChildItem -LiteralPath $RootPath -Recurse -File -Filter "*.agent.md"
if ($agentFiles.Count -eq 0) {
    Write-Host "No .agent.md files found under $RootPath"
    exit 0
}

$unknownFound = $false

foreach ($file in $agentFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $match = [regex]::Match($content, "(?ms)^---\s*(.*?)\s*---")
    if (-not $match.Success) {
        continue
    }

    $frontmatter = $match.Groups[1].Value
    $toolsLine = [regex]::Match($frontmatter, "(?m)^tools:\s*\[(.*?)\]\s*$")
    if (-not $toolsLine.Success) {
        continue
    }

    $toolsRaw = $toolsLine.Groups[1].Value
    $toolMatches = [regex]::Matches($toolsRaw, "'([^']+)'|""([^""]+)""")
    $tools = @()
    foreach ($m in $toolMatches) {
        if ($m.Groups[1].Success) { $tools += $m.Groups[1].Value }
        elseif ($m.Groups[2].Success) { $tools += $m.Groups[2].Value }
    }

    $unknown = $tools | Where-Object { $_ -notin $AllowedTools }
    if ($unknown.Count -gt 0) {
        $unknownFound = $true
        Write-Host ""
        Write-Host "Unknown tools in $($file.FullName):" -ForegroundColor Yellow
        $unknown | Sort-Object -Unique | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }
}

if ($unknownFound) {
    Write-Error "Validation failed: unknown tool identifiers were found."
    exit 1
}

Write-Host "Validation passed: all discovered tools are in the allow list." -ForegroundColor Green
exit 0
