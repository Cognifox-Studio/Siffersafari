param()

$f = "d:\Projects\Personal\Multiplikation\lib\presentation\screens\home_screen.dart"
$text = [System.IO.File]::ReadAllText($f)

# Detect line ending style
$hasCRLF = $text.Contains("`r`n")
$nl = if ($hasCRLF) { "`r`n" } else { "`n" }

Write-Host "Line ending: $(if ($hasCRLF) { 'CRLF' } else { 'LF' })"
Write-Host "File length: $($text.Length) chars"

# Build old/new with detected line endings  
$LE = $nl

function B {
    param([string[]]$lines)
    return [string]::Join($LE, $lines)
}

$old_lines = @(
    "                    if (user == null) ...[",
    "                      ElevatedButton(",
    "                        onPressed: () {",
    "                          showCreateUserDialog(context: context, ref: ref);",
    "                        },",
    "                        child: const Text('Skapa profil'),",
    "                      ),",
    "                      // Daily challenge card",
    "                      if (user != null) ...[",
    "                        const SizedBox(height: AppConstants.defaultPadding),",
    "                        DailyChallengeCard(",
    "                          userId: user.userId,",
    "                          allowedOps: allowedOps,",
    "                          onStart: _startDailyChallenge,",
    "                          onPrimary: onPrimary,",
    "                          mutedOnPrimary: mutedOnPrimary,",
    "                          accentColor: accentColor,",
    "                        ),",
    "                      ],",
    "",
    "                      const SizedBox(height: AppConstants.largePadding),",
    "",
    "                      if (user == null) ...[",
    "                        ElevatedButton(",
    "                          onPressed: () {",
    "                            showCreateUserDialog(context: context, ref: ref);",
    "                        title: Text(",
    "                          'Visa mer',"
)

$new_lines = @(
    "                    // Daily challenge card (only when profile is active)",
    "                    if (user != null) ...[",
    "                      const SizedBox(height: AppConstants.defaultPadding),",
    "                      DailyChallengeCard(",
    "                        userId: user.userId,",
    "                        allowedOps: allowedOps,",
    "                        onStart: _startDailyChallenge,",
    "                        onPrimary: onPrimary,",
    "                        mutedOnPrimary: mutedOnPrimary,",
    "                        accentColor: accentColor,",
    "                      ),",
    "                    ],",
    "",
    "                    const SizedBox(height: AppConstants.largePadding),",
    "",
    "                    if (user == null) ...[",
    "                      ElevatedButton(",
    "                        onPressed: () {",
    "                          showCreateUserDialog(context: context, ref: ref);",
    "                        },",
    "                        child: const Text('Skapa profil'),",
    "                      ),",
    "                      const SizedBox(height: AppConstants.largePadding),",
    "                    ],",
    "",
    "                    // Advanced stats (collapsed by default)",
    "                    if (user != null)",
    "                      ExpansionTile(",
    "                        title: Text(",
    "                          'Visa mer',"
)

$old = B $old_lines
$new = B $new_lines

$found = $text.Contains($old)
Write-Host "Pattern found: $found"

if ($found) {
    $text = $text.Replace($old, $new)
    Write-Host "Fix 1 applied"
} else {
    Write-Host "Pattern NOT found - inspecting file lines around 486..."
    $lines_arr = $text -split $nl
    for ($i=484; $i -lt 515; $i++) {
        Write-Host "$($i+1): $($lines_arr[$i])"
    }
}

# Fix 2: Remove the corrupted DailyChallengeCard block from inside _buildOperationCard
$old2_lines = @(
    "            ),",
    "                    // Daily challenge card (only when profile is active)",
    "                    if (user != null) ...[",
    "                      const SizedBox(height: AppConstants.defaultPadding),",
    "                      DailyChallengeCard(",
    "                        userId: user.userId,",
    "                        allowedOps: allowedOps,",
    "                        onStart: _startDailyChallenge,",
    "                        onPrimary: onPrimary,",
    "                        mutedOnPrimary: mutedOnPrimary,",
    "                        accentColor: accentColor,",
    "                      ),",
    "                    ],",
    "",
    "                    const SizedBox(height: AppConstants.largePadding),",
    "",
    "                    if (user == null) ...[",
    "                      ElevatedButton(",
    "                        onPressed: () {",
    "                          showCreateUserDialog(context: context, ref: ref);",
    "                        },",
    "                        child: const Text('Skapa profil'),",
    "                      ),",
    "                      const SizedBox(height: AppConstants.largePadding),",
    "                    ],",
    "",
    "                    // Advanced stats (collapsed by default)",
    "                    if (user != null)",
    "                      ExpansionTile(",
    "                        title: Text(",
    "                          'Visa mer',",
    "                      child: child,"
)
$new2_lines = @(
    "            ),",
    "                      child: child,"
)

$old2 = B $old2_lines
$new2 = B $new2_lines
$found2 = $text.Contains($old2)
Write-Host "Fix 2 pattern found: $found2"
if ($found2) {
    $text = $text.Replace($old2, $new2)
    Write-Host "Fix 2 applied"
}

[System.IO.File]::WriteAllText($f, $text)
Write-Host "Done. File written."
