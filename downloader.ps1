# Fast Downloader
$scriptDir = $PSScriptRoot

do {
    Clear-Host
    Write-Host ""
    Write-Host "  ============================="
    Write-Host "       快速下载器 v1.0"
    Write-Host "  ============================="
    Write-Host ""
    Write-Host "  [1] 普通下载 (exe/zip/视频/文件)"
    Write-Host "  [2] M3U8 流媒体下载"
    Write-Host "  [0] 退出"
    Write-Host ""
    $choice = Read-Host "请选择"

    if ($choice -eq '0') { exit }
    if ($choice -notin '1','2') { continue }

    $url = Read-Host "请输入下载链接"
    if ([string]::IsNullOrWhiteSpace($url)) { continue }

    Write-Host ""
    Write-Host "保存到: $env:USERPROFILE\Downloads"
    Write-Host ""

    if ($choice -eq '1') {
        & "$scriptDir\aria2c.exe" -x 16 -s 16 -c $url -d "$env:USERPROFILE\Downloads"
    } else {
        & "$scriptDir\N_m3u8DL-RE.exe" $url --thread-count 16 --save-dir "$env:USERPROFILE\Downloads"
    }

    Write-Host ""
    Write-Host "=== 下载完成 ==="
    Read-Host "按回车继续"

} while ($true)