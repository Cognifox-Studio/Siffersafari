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
      Where-Object {
        $_ -and (
          $_ -match '^\.github/skills/.+/SKILL\.md$' -or
          $_ -match '^\.github/prompts/.+\.prompt\.md$' -or
          $_ -match '^\.github/agents/.+\.agent\.md$' -or
          $_ -match '^\.github/instructions/.+\.instructions\.md$'
        )
      } |
      Sort-Object -Unique
  )

  if (-not $changed -or $changed.Count -eq 0) {
    exit 0
  }

  $root = (Get-Location).Path
  $warnings = New-Object System.Collections.Generic.List[string]

  function Get-FrontmatterBlock {
    param([string]$Content)

    $match = [regex]::Match($Content, '(?s)\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)')
    if ($match.Success) {
      return $match.Groups[1].Value
    }

    return $null
  }

  function Has-FrontmatterKey {
    param(
      [string]$Frontmatter,
      [string]$Key
    )

    if ([string]::IsNullOrWhiteSpace($Frontmatter)) {
      return $false
    }

    return [regex]::IsMatch($Frontmatter, ('(?im)^\s*{0}\s*:' -f [regex]::Escape($Key)))
  }

  function Get-FrontmatterValue {
    param(
      [string]$Frontmatter,
      [string]$Key
    )

    if ([string]::IsNullOrWhiteSpace($Frontmatter)) {
      return $null
    }

    $match = [regex]::Match(
      $Frontmatter,
      ('(?im)^\s*{0}\s*:\s*["'']?([^"''#\r\n]+)["'']?\s*(?:#.*)?$' -f [regex]::Escape($Key))
    )

    if ($match.Success) {
      return $match.Groups[1].Value.Trim()
    }

    return $null
  }

  foreach ($relativePath in $changed) {
    $fullPath = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
      continue
    }

    $content = Get-Content -Raw -LiteralPath $fullPath
    if ([string]::IsNullOrWhiteSpace($content)) {
      continue
    }

    $frontmatter = Get-FrontmatterBlock -Content $content
    if ($null -eq $frontmatter) {
      $warnings.Add(('{0} saknar YAML-frontmatter' -f $relativePath))
      continue
    }

    if ($content -match '(?m)^\*\*Description:\*\*') {
      $warnings.Add(('{0} använder gammal **Description:**-header i stället för frontmatter' -f $relativePath))
    }

    if ($relativePath -match '^\.github/skills/.+/SKILL\.md$') {
      $expectedName = Split-Path (Split-Path $fullPath -Parent) -Leaf
      $actualName = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'name'

      if (-not (Has-FrontmatterKey -Frontmatter $frontmatter -Key 'name')) {
        $warnings.Add(('{0} saknar frontmatter-fältet name' -f $relativePath))
      } elseif ($actualName -ne $expectedName) {
        $warnings.Add(('{0} har name="{1}" men mappnamnet är "{2}"' -f $relativePath, $actualName, $expectedName))
      }

      if (-not (Has-FrontmatterKey -Frontmatter $frontmatter -Key 'description')) {
        $warnings.Add(('{0} saknar frontmatter-fältet description' -f $relativePath))
      }

      continue
    }

    if ($relativePath -match '^\.github/prompts/.+\.prompt\.md$') {
      foreach ($key in @('name', 'description')) {
        if (-not (Has-FrontmatterKey -Frontmatter $frontmatter -Key $key)) {
          $warnings.Add(('{0} saknar frontmatter-fältet {1}' -f $relativePath, $key))
        }
      }

      continue
    }

    if ($relativePath -match '^\.github/agents/.+\.agent\.md$') {
      foreach ($key in @('name', 'description')) {
        if (-not (Has-FrontmatterKey -Frontmatter $frontmatter -Key $key)) {
          $warnings.Add(('{0} saknar frontmatter-fältet {1}' -f $relativePath, $key))
        }
      }

      continue
    }

    if ($relativePath -match '^\.github/instructions/.+\.instructions\.md$') {
      foreach ($key in @('description', 'applyTo')) {
        if (-not (Has-FrontmatterKey -Frontmatter $frontmatter -Key $key)) {
          $warnings.Add(('{0} saknar frontmatter-fältet {1}' -f $relativePath, $key))
        }
      }
    }
  }

  $unique = @($warnings | Sort-Object -Unique)
  if ($unique.Count -gt 0) {
    $sample = ($unique | Select-Object -First 5) -join '; '
    @{
      continue = $true
      systemMessage = 'Customization frontmatter guard: mojliga metadatafel i andrade .github-filer: ' + $sample + '. Anvand YAML-frontmatter, lagg description i frontmatter och lat skill-name matcha mappnamnet.'
    } | ConvertTo-Json -Compress
  }
} catch {
  exit 0
}