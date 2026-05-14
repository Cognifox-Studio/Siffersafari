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
      Where-Object { $_ -and $_ -match '\.(md|json|ps1)$' } |
      Sort-Object -Unique
  )
  if (-not $changed -or $changed.Count -eq 0) {
    exit 0
  }

  $root = (Get-Location).Path
  $repoPrefixes = @(
    '.github/',
    'docs/',
    'lib/',
    'test/',
    'assets/',
    'scripts/',
    'android/',
    'site/',
    'integration_test/',
    'artifacts/'
  )
  $broken = New-Object System.Collections.Generic.List[string]

  function Test-CustomizationPath {
    param(
      [string]$Source,
      [string]$Candidate,
      [string]$BaseDir
    )

    if ([string]::IsNullOrWhiteSpace($Candidate)) {
      return
    }

    $trimmed = $Candidate.Trim()
    if ($trimmed -match '^(https?:|mailto:|vscode:|#)') {
      return
    }
    if ($trimmed -match '[*{}<>]') {
      return
    }

    $pathOnly = ($trimmed -split '#')[0]
    if ([string]::IsNullOrWhiteSpace($pathOnly)) {
      return
    }

    $target = $null
    if ($pathOnly -match '^(\.\.?[/\\])') {
      $target = [System.IO.Path]::GetFullPath((Join-Path $BaseDir $pathOnly))
    } elseif (($repoPrefixes | Where-Object { $pathOnly.StartsWith($_) }).Count -gt 0) {
      $target = Join-Path $root $pathOnly
    }

    if ($null -eq $target) {
      return
    }

    if (-not (Test-Path -LiteralPath $target)) {
      $broken.Add(('{0} -> {1}' -f $Source, $Candidate))
    }
  }

  function Test-QuotedCandidateValue {
    param(
      [string]$Source,
      [string]$Value,
      [string]$BaseDir
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
      return
    }

    if ($Value -match '^(\.\.?[/\\])') {
      Test-CustomizationPath -Source $Source -Candidate $Value -BaseDir $BaseDir
      return
    }

    if (($repoPrefixes | Where-Object { $Value.StartsWith($_) }).Count -gt 0) {
      Test-CustomizationPath -Source $Source -Candidate $Value -BaseDir $BaseDir
    }
  }

  foreach ($relativePath in $changed) {
    $fullPath = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
      continue
    }

    $content = Get-Content -Raw -LiteralPath $fullPath
    $baseDir = Split-Path -Parent $fullPath

    if ($relativePath -match '\.md$') {
      foreach ($match in [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)')) {
        Test-CustomizationPath -Source $relativePath -Candidate $match.Groups[1].Value -BaseDir $baseDir
      }

      foreach ($match in [regex]::Matches($content, '`([^`]+)`')) {
        $value = $match.Groups[1].Value
        if ($value -match '[/\\]' -and $value -match '(\.(md|json|dart|ya?ml|ps1|html|js|png|jpg|jpeg|svg)|/)$') {
          Test-CustomizationPath -Source $relativePath -Candidate $value -BaseDir $baseDir
        }
      }
      continue
    }

    foreach ($match in [regex]::Matches($content, '"([^"]+)"')) {
      Test-QuotedCandidateValue -Source $relativePath -Value $match.Groups[1].Value -BaseDir $baseDir
    }

    if ($relativePath -match '\.ps1$') {
      foreach ($match in [regex]::Matches($content, "'([^']+)'") ) {
        Test-QuotedCandidateValue -Source $relativePath -Value $match.Groups[1].Value -BaseDir $baseDir
      }
    }
  }

  $unique = @($broken | Sort-Object -Unique)
  if ($unique.Count -gt 0) {
    $sample = ($unique | Select-Object -First 5) -join '; '
    @{
      continue = $true
      systemMessage = 'Customization reference check: mojliga brutna interna referenser i andrade .github-filer: ' + $sample + '. Verifiera relativa lankar fran filens mapp och uppdatera stale paths.'
    } | ConvertTo-Json -Compress
  }
} catch {
  exit 0
}