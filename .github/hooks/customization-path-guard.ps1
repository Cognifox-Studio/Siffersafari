$stdinJson = [Console]::In.ReadToEnd()
$pattern = '(?i)(/create-(skill|prompt|agent|instruction|hook)|AGENTS\.md|copilot-instructions|\.github[/\\](skills|prompts|agents|instructions|hooks)|chat customization|customization)'

if ($stdinJson -match $pattern) {
  @{
    continue = $true
    systemMessage = "Customization hygiene: verify relative links from the current file folder, ensure skill name matches folder name, prefer updating existing central files, and keep using link, don't embed."
  } | ConvertTo-Json -Compress
}