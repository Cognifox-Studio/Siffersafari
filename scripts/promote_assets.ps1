#Requires -Version 5.1
<#
.SYNOPSIS
    Automate asset promotion workflow: generate, validate, test, promote
    
.DESCRIPTION
    Handles three workflows:
    A) New Character
    B) Update Existing Character (by slug)
    C) Lottie/SFX Only
    
    Runs generators in stable order, validates, tests, and promotes to assets/

.PARAMETER Workflow
    One of: NewCharacter, UpdateCharacter, LottieSFX
    
.PARAMETER CharacterName
    (NewCharacter) Full name, e.g. "Mira"
    
.PARAMETER CharacterBrief
    (NewCharacter) Short description, e.g. "space explorer with teal jacket"
    
.PARAMETER CharacterSlug
    (UpdateCharacter) Slug, e.g. "loke"
    
.PARAMETER SkipQA
    Skip QA tests (analyze/test). Use only for preview/debug.
    
.EXAMPLE
    .\promote_assets.ps1 -Workflow NewCharacter -CharacterName "Mira" -CharacterBrief "space explorer"
    
.EXAMPLE
    .\promote_assets.ps1 -Workflow UpdateCharacter -CharacterSlug loke
    
.EXAMPLE
    .\promote_assets.ps1 -Workflow LottieSFX
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('NewCharacter', 'UpdateCharacter', 'LottieSFX')]
    [string]$Workflow,
    
    [string]$CharacterName,
    [string]$CharacterBrief,
    [string]$CharacterSlug,
    [switch]$SkipQA,
    [switch]$LintWarnOnly,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Write-Host "[*] Asset Promotion Workflow: $Workflow" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Gray

# Helper: Run command and exit on error
function Invoke-CheckedCommand {
    param([string]$Command, [string]$Description)
    
    Write-Host ""
    Write-Host "[+] $Description" -ForegroundColor Yellow
    Write-Verbose "Command: $Command"
    
    if ($DryRun) {
        Write-Host "    [DRY RUN] Would execute: $Command" -ForegroundColor Gray
        return $true
    }
    
    $result = Invoke-Expression $Command 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    [!] Failed: $Description" -ForegroundColor Red
        Write-Host $result
        exit 1
    }
    
    Write-Host "    [OK] Done" -ForegroundColor Green
    return $true
}

# Phase 1: Generate
function Phase-Generate {
    Write-Host ""
    Write-Host "[PHASE 1] Generate" -ForegroundColor Magenta
    Write-Host "================================================================================" -ForegroundColor Gray
    
    if ($Workflow -eq 'NewCharacter') {
        Invoke-CheckedCommand `
            "python tools/create_character.py --name `"$CharacterName`" --brief `"$CharacterBrief`"" `
            "Create new character from brief"
    }
    elseif ($Workflow -eq 'UpdateCharacter') {
        Invoke-CheckedCommand `
            "python tools/refresh_character.py --slug $CharacterSlug" `
            "Refresh existing character: $CharacterSlug"
    }
    
    if ($Workflow -in 'NewCharacter', 'UpdateCharacter') {
        Invoke-CheckedCommand `
            "dart run scripts/generate_mascot_svg_parts.dart" `
            "Generate mascot SVG parts"
        
        Invoke-CheckedCommand `
            "dart run scripts/generate_mascot_composite.dart" `
            "Generate mascot composite"
        
        Invoke-CheckedCommand `
            "dart run scripts/generate_lottie_effects.dart" `
            "Generate Lottie effects"
        
        Invoke-CheckedCommand `
            "dart run scripts/generate_rive_blueprint.dart" `
            "Generate Rive blueprint"
    }
    elseif ($Workflow -eq 'LottieSFX') {
        Invoke-CheckedCommand `
            "dart run scripts/generate_lottie_effects.dart" `
            "Generate Lottie effects"
        
        Invoke-CheckedCommand `
            "dart run scripts/generate_sfx_wav.dart --out assets/sounds" `
            "Generate SFX WAV baseline"
    }
}

# Phase 2: Validate & Manifest
function Phase-Validate {
    Write-Host ""
    Write-Host "[PHASE 2] Validate & Manifest" -ForegroundColor Magenta
    Write-Host "================================================================================" -ForegroundColor Gray
    
    Invoke-CheckedCommand `
        "python tools/pipeline.py validate --strict" `
        "Strict validation"

    $lintCommand = "python tools/pipeline.py lint-assets --strict --report-path artifacts/asset_lint_report.json"
    if ($LintWarnOnly) {
        $lintCommand = "$lintCommand --warn-only"
    }

    Invoke-CheckedCommand `
        $lintCommand `
        "Asset style lint"
    
    Invoke-CheckedCommand `
        "python tools/pipeline.py manifest" `
        "Update manifest and codegen"
}

# Phase 3: Quality Gates
function Phase-QA {
    if ($SkipQA) {
        Write-Host ""
        Write-Host "[SKIP] QA skipped (--SkipQA flag set)" -ForegroundColor Yellow
        return
    }
    
    Write-Host ""
    Write-Host "[PHASE 3] Quality Gates" -ForegroundColor Magenta
    Write-Host "================================================================================" -ForegroundColor Gray
    
    Invoke-CheckedCommand `
        "flutter analyze" `
        "Static analysis"
    
    Invoke-CheckedCommand `
        "flutter test test/unit/assets/generated_asset_paths_test.dart" `
        "Asset paths validation"
    
    if ($Workflow -in 'NewCharacter', 'UpdateCharacter') {
        Invoke-CheckedCommand `
            "flutter test test/widget/mascot_character_test.dart" `
            "Mascot widget integration test"
    }
    
    Invoke-CheckedCommand `
        "flutter test" `
        "Full test suite"
}

# Phase 4: Promote
function Phase-Promote {
    Write-Host ""
    Write-Host "[PHASE 4] Promote artifacts to assets/" -ForegroundColor Magenta
    Write-Host "================================================================================" -ForegroundColor Gray
    
    # Character composite SVG
    if ($Workflow -eq 'NewCharacter' -or $Workflow -eq 'UpdateCharacter') {
        $slug = if ($Workflow -eq 'NewCharacter') { 
            $CharacterName.ToLower() 
        } else { 
            $CharacterSlug 
        }
        
        # Ensure target directory exists
        $targetDir = "assets/characters/$slug/svg"
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        
        $source = "artifacts/${slug}_composite.svg"
        $target = "$targetDir/${slug}_composite.svg"
        
        if (Test-Path $source) {
            Write-Host "[+] Promote composite SVG: $source -> $target" -ForegroundColor Yellow
            if (-not $DryRun) {
                Copy-Item $source $target -Force
                Write-Host "    [OK] Done" -ForegroundColor Green
            }
        } else {
            Write-Host "    [*] No composite found at $source (may be normal for preview)" -ForegroundColor Yellow
        }
    }
    
    # Lottie effects
    if ($Workflow -in 'NewCharacter', 'UpdateCharacter', 'LottieSFX') {
        $sourceDir = "artifacts/ui/lottie"
        $targetDir = "assets/ui/lottie"
        
        if (Test-Path $sourceDir) {
            Write-Host "[+] Promote Lottie effects: $sourceDir -> $targetDir" -ForegroundColor Yellow
            if (-not $DryRun) {
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                Get-ChildItem $sourceDir -Filter "*.json" | ForEach-Object {
                    Copy-Item $_.FullName "$targetDir/$($_.Name)" -Force
                }
                Write-Host "    [OK] Done" -ForegroundColor Green
            }
        }
    }
    
    # SFX
    if ($Workflow -eq 'LottieSFX') {
        $sourceDir = "artifacts/sounds"
        $targetDir = "assets/sounds"
        
        if (Test-Path $sourceDir) {
            Write-Host "[+] Promote SFX: $sourceDir -> $targetDir" -ForegroundColor Yellow
            if (-not $DryRun) {
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                Get-ChildItem $sourceDir -Filter "*.wav" | ForEach-Object {
                    Copy-Item $_.FullName "$targetDir/$($_.Name)" -Force
                }
                Write-Host "    [OK] Done" -ForegroundColor Green
            }
        }
    }
}

# Phase 5: Report
function Phase-Report {
    Write-Host ""
    Write-Host "[PHASE 5] Report & Next Steps" -ForegroundColor Magenta
    Write-Host "================================================================================" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "[COMPLETE] Workflow complete!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Next manual steps:" -ForegroundColor Cyan
    Write-Host "  1. Review git diff: git diff --stat"
    Write-Host "  2. Verify only expected files changed: git status"
    Write-Host "  3. Stage changes: git add ."
    Write-Host "  4. Commit with meaningful message"
    Write-Host "  5. Inspect lint report: artifacts/asset_lint_report.json"
    
    if ($Workflow -in 'NewCharacter', 'UpdateCharacter') {
        $slug = if ($Workflow -eq 'NewCharacter') { $CharacterName.ToLower() } else { $CharacterSlug }
        Write-Host ""
        Write-Host "  Character slug: $slug"
        Write-Host "  SVG composite: assets/characters/$slug/svg/${slug}_composite.svg"
    }
    
    if ($Workflow -eq 'UpdateCharacter') {
        Write-Host ""
        Write-Host "  Note: If .riv runtime was touched:"
        Write-Host "    - Verify in Rive editor (artboard 'Mascot', state machine 'MascotStateMachine')"
        Write-Host "    - Then run: .\scripts\verify_mascot_rive_runtime.ps1"
    }
    
    Write-Host ""
    Write-Host "  Fallback policy: keep_last_known_good_assets (promotion stops before copying on lint failure)"
    Write-Host ""
}

# Main flow
try {
    Phase-Generate
    Phase-Validate
    Phase-QA
    Phase-Promote
    Phase-Report
}
catch {
    Write-Host ""
    Write-Host "[ERROR] $_" -ForegroundColor Red
    exit 1
}

Write-Host "================================================================================" -ForegroundColor Gray
Write-Host ""
