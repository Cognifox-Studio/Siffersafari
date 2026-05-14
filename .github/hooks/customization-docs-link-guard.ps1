try {
  $stdinJson = [Console]::In.ReadToEnd()
  if ($stdinJson -notmatch '(?i)(\.github[/\\]|copilot-instructions|AGENTS\.md|customization|skills/|prompts/|agents/|instructions/|hooks/)') {
    exit 0
  }

  $tracked = @(git diff --name-only -- .github 2>$null)
  $staged = @(git diff --cached --name-only -- .github 2>$null)
  $untracked = @(git ls-files --others --exclude-standard -- .github 2>$null)
  $changed = @(
    $tracked + $staged + $untracked |
      Where-Object { $_ -and $_ -match '^\.github/.+\.md$' } |
      Sort-Object -Unique
  )

  if (-not $changed -or $changed.Count -eq 0) {
    exit 0
  }

  $root = (Get-Location).Path
  $docSignals = @(
    @{ Path = 'docs/SESSION_BRIEF.md'; Pattern = '(?i)(forts[aä]tt|resume|aktuellt l[aä]ge|senaste leveranser|n[aä]sta steg)' }
    @{ Path = 'docs/ARCHITECTURE.md'; Pattern = '(?i)(arkitektur|startup|bootstrap|riverpod|getit|hive|offline-first|persistensmodell|feature-first)' }
    @{ Path = 'docs/DECISIONS_LOG.md'; Pattern = '(?i)(beslut|avv[aä]gning|varf[oö]r|historik|trade-?off)' }
    @{ Path = 'docs/README.md'; Pattern = '(?i)(dokumentationshub|di[aá]taxis|dokumentation|index|project structure|services api|repo-struktur|servicekontrakt)' }
  )

  $warnings = New-Object System.Collections.Generic.List[string]

  foreach ($relativePath in $changed) {
    $fullPath = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
      continue
    }

    $content = Get-Content -Raw -LiteralPath $fullPath
    if ([string]::IsNullOrWhiteSpace($content)) {
      continue
    }

    $mentioned = New-Object System.Collections.Generic.List[string]
    $missing = New-Object System.Collections.Generic.List[string]

    foreach ($signal in $docSignals) {
      if ($content -match $signal.Pattern) {
        $mentioned.Add($signal.Path)
        if ($content -notmatch [regex]::Escape($signal.Path)) {
          $missing.Add($signal.Path)
        }
      }
    }

    $hasAnyDocsRef = $content -match 'docs/'
    $shouldWarn = ($mentioned.Count -ge 2 -and $missing.Count -ge 2) -or (-not $hasAnyDocsRef -and $mentioned.Count -ge 3 -and $content.Length -ge 1200)

    if ($shouldWarn) {
      $sample = ($missing | Select-Object -First 3) -join ', '
      if ([string]::IsNullOrWhiteSpace($sample)) {
        $sample = 'docs/README.md'
      }
      $warnings.Add(('{0} verkar duplicera repo-fakta utan tydlig docs-hänvisning ({1})' -f $relativePath, $sample))
    }
  }

  $unique = @($warnings | Sort-Object -Unique)
  if ($unique.Count -gt 0) {
    $sample = ($unique | Select-Object -First 5) -join '; '
    @{
      continue = $true
      systemMessage = 'Customization docs guard: mojlig duplication mot docs i andrade .github-filer: ' + $sample + '. Linka hellre till docs/README.md, docs/ARCHITECTURE.md, docs/DECISIONS_LOG.md eller docs/SESSION_BRIEF.md an att embedda repo-fakta.'
    } | ConvertTo-Json -Compress
  }
} catch {
  exit 0
}