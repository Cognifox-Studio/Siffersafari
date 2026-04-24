Add-Type -AssemblyName System.Drawing
$srcPath = "D:\Projects\Personal\Multiplikation\artifacts\play_console_raw\current.png"
$destPath = "D:\Projects\Personal\Multiplikation\artifacts\play_console_phone_9x16\01_welcome.png"

Write-Host "Source Path: $srcPath"
Write-Host "Destination Path: $destPath"

if (Test-Path $srcPath) {
    try {
        $img = [System.Drawing.Image]::FromFile($srcPath)
        $bmp = New-Object System.Drawing.Bitmap 1080, 1920
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $srcRect = New-Object System.Drawing.Rectangle 0, 128, 1080, 1920
        $destRect = New-Object System.Drawing.Rectangle 0, 0, 1080, 1920
        $g.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        $bmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $g.Dispose(); $bmp.Dispose(); $img.Dispose()
        Write-Host "Image saved to $destPath"
        Get-ChildItem $destPath | Select-Object Name, @{N='Dimensions'; E={'1080x1920'}}, @{N='Size(KB)'; E={[math]::Round($_.Length/1KB, 2)}} | Format-Table -AutoSize
    } catch {
        Write-Error "Error processing image: $($_.Exception.Message)"
    }
} else {
    Write-Error "Source file not found: $srcPath"
}
