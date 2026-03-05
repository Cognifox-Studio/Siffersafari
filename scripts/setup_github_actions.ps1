# GitHub Actions - Setup script for Siffersafari alpha releases
# Denna script hjalper dig att:
# 1. Konvertera keystore till Base64
# 2. Skapa GitHub Secrets

Write-Host "=== Siffersafari GitHub Actions Setup ===" -ForegroundColor Green
Write-Host ""

# Step 1: Konvertera keystore till Base64
Write-Host "Step 1: Encoding keystore to Base64..." -ForegroundColor Cyan
$keystorePath = "android/upload-keystore.jks"

if (-not (Test-Path $keystorePath)) {
    Write-Host "ERROR: $keystorePath not found!" -ForegroundColor Red
    Write-Host "Kor forst: keytool -genkey -v -keystore android/upload-keystore.jks ..."
    exit 1
}

$keystore = [System.IO.File]::ReadAllBytes($keystorePath)
$base64 = [Convert]::ToBase64String($keystore)

Write-Host "[OK] Keystore converted to Base64 ($($base64.Length) characters)" -ForegroundColor Green
Write-Host ""

# Step 2: Instruktioner for GitHub Secrets
Write-Host "Step 2: Navigate to GitHub and add these secrets:" -ForegroundColor Cyan
Write-Host ""
Write-Host ""
Write-Host "Go to: https://github.com/Cognifox-Studio/Siffersafari/settings/secrets/actions" -ForegroundColor Yellow
Write-Host ""
Write-Host "Click 'New repository secret' and add these two:" -ForegroundColor White
Write-Host ""
Write-Host "  Secret 1:" -ForegroundColor White
Write-Host "    Name:  KEYSTORE_BASE64" -ForegroundColor Cyan
Write-Host "    Value: (Paste the long Base64 string below)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Secret 2:" -ForegroundColor White
Write-Host "    Name:  KEYSTORE_PASSWORD" -ForegroundColor Cyan
Write-Host "    Value: siffersafari2026" -ForegroundColor Cyan
Write-Host ""

# Step 3: Copy Base64 to clipboard
Write-Host "Step 3: Copying Base64 to clipboard..." -ForegroundColor Cyan
$base64 | Set-Clipboard
Write-Host "[OK] Base64 copied! You can now paste it in GitHub Secrets." -ForegroundColor Green
Write-Host ""

# Step 4: Success
Write-Host "All done! Next steps:" -ForegroundColor Green
Write-Host "  1. Go to URL above"
Write-Host "  2. Add the two secrets (paste Base64 from clipboard)"
Write-Host "  3. Commit changes: git add -A; git commit -m 'chore: setup github actions workflow'"
Write-Host "  4. Push: git push"
Write-Host "  5. GitHub Actions will automatically build and release on next push to main/develop"
Write-Host ""
Write-Host "TIP: Once set up, just commit & push to trigger automatic builds!" -ForegroundColor Cyan
