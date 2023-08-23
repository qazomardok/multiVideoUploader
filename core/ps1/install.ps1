$ffmpegFolderPath = Join-Path -Path $global:Folder_Work -ChildPath "core\ffmpeg"
$ffmpegFilePath = Join-Path -Path $ffmpegFolderPath -ChildPath "ffmpeg.exe"

# ������� ����� core\ffmpeg, ���� ��� �����������
if (-not (Test-Path -Path $ffmpegFolderPath -PathType Container)) {
    New-Item -Path $ffmpegFolderPath -ItemType Directory | Out-Null
}

# ������� ��� ����� � ����� � ����� core\ffmpeg, ����� ffmpeg.exe
Get-ChildItem -Path $ffmpegFolderPath | Where-Object { $_.Name -ne "ffmpeg.exe" } | Remove-Item -Force -Recurse

if (Test-Path -Path $ffmpegFilePath -PathType Leaf) {
    Write-Host "���� ffmpeg.exe ���������� � ����� $ffmpegFolderPath"
} else {
    Write-Host "���� ffmpeg.exe ����������� � ����� $ffmpegFolderPath"
    Write-Host "���������� � ��������� ffmpeg.exe..."

    $ffmpegFolderPathTemp = Join-Path -Path $global:Folder_Work -ChildPath "core\ffmpeg\tmp"
    
    # ������� ����� tmp, ���� ��� �����������
    if (-not (Test-Path -Path $ffmpegFolderPathTemp -PathType Container)) {
        New-Item -Path $ffmpegFolderPathTemp -ItemType Directory | Out-Null
    }

    $zipFilePath = Join-Path -Path $ffmpegFolderPathTemp -ChildPath "ffmpeg.zip"
    $ffmpegDownloadUrl = $global:Config.ffmpegDownloadUrl
    
    Invoke-WebRequest -Uri $ffmpegDownloadUrl -OutFile $zipFilePath
    Expand-Archive -Path $zipFilePath -DestinationPath $ffmpegFolderPathTemp

    $ffmpegExePathInArchive = Get-ChildItem -Path $ffmpegFolderPathTemp -Recurse | Where-Object { $_.Name -eq "ffmpeg.exe" } | Select-Object -First 1
    Move-Item -Path $ffmpegExePathInArchive.FullName -Destination $ffmpegFilePath -Force

    Remove-Item -Path $zipFilePath -Force
    Remove-Item -Path $ffmpegFolderPathTemp -Force -Recurse
    
    Write-Host "FFmpeg.exe ������� ������ � �������� � $ffmpegFilePath"
}
