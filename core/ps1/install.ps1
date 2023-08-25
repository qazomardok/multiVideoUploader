$ffmpegFolderPath = Join-Path -Path $global:Folder_Work -ChildPath "core\ffmpeg"
$ffmpegFilePath = Join-Path -Path $ffmpegFolderPath -ChildPath "ffmpeg.exe"

# Создаем папку core\ffmpeg, если она отсутствует
if (-not (Test-Path -Path $ffmpegFolderPath -PathType Container)) {
    New-Item -Path $ffmpegFolderPath -ItemType Directory | Out-Null
}

# Удаляем все файлы и папки в папке core\ffmpeg, кроме ffmpeg.exe
Get-ChildItem -Path $ffmpegFolderPath | Where-Object { $_.Name -ne "ffmpeg.exe" } | Remove-Item -Force -Recurse

if (Test-Path -Path $ffmpegFilePath -PathType Leaf) {
    Write-Host "Файл ffmpeg.exe существует в папке $ffmpegFolderPath"
}
else {
    Write-Host "Файл ffmpeg.exe отсутствует в папке $ffmpegFolderPath"
    Write-Host "Скачивание и установка ffmpeg.exe..."

    $ffmpegFolderPathTemp = Join-Path -Path $global:Folder_Work -ChildPath "core\ffmpeg\tmp"

    # Создаем папку tmp, если она отсутствует
    if (-not (Test-Path -Path $ffmpegFolderPathTemp -PathType Container)) {
        New-Item -Path $ffmpegFolderPathTemp -ItemType Directory | Out-Null
    }

    $zipFilePath = Join-Path -Path $ffmpegFolderPathTemp -ChildPath "ffmpeg.zip"
    $ffmpegDownloadUrl = $global:Config.ffmpegDownloadUrl

    Invoke-WebRequest -Uri $ffmpegDownloadUrl -OutFile $zipFilePath
    Expand-Archive -Path $zipFilePath -DestinationPath $ffmpegFolderPathTemp

    $ffmpegExePathInArchive = Get-ChildItem -Path $ffmpegFolderPathTemp -Recurse | Where-Object { $_.Name -eq "ffmpeg.exe" } | Select-Object -First 1
    Move-Item -Path $ffmpegExePathInArchive.FullName -Destination $ffmpegFilePath -Force

    # Remove-Item -Path $zipFilePath -Force
    Remove-Item -Path $ffmpegFolderPathTemp -Force -Recurse

    Write-Host "FFmpeg.exe успешно скачан и сохранен в $ffmpegFilePath"
}




$folderMonitorFolderPath = Join-Path -Path $global:Folder_Work -ChildPath "core\foldermonitor"
$folderMonitorFilePath = Join-Path -Path $folderMonitorFolderPath -ChildPath "FolderMonitor.exe"

# Создаем папку core\foldermonitor, если она отсутствует
if (-not (Test-Path -Path $folderMonitorFolderPath -PathType Container)) {
    New-Item -Path $folderMonitorFolderPath -ItemType Directory | Out-Null
}

if (Test-Path -Path $folderMonitorFilePath -PathType Leaf) {
    Write-Host "Файл FolderMonitor.exe существует в папке $folderMonitorFolderPath"
}
else {
    Write-Host "Файл FolderMonitor.exe отсутствует в папке $folderMonitorFolderPath"
    Write-Host "Скачивание и установка FolderMonitor.exe..."

    $folderMonitorDownloadUrl = "https://www.nodesoft.com/foldermonitor/download"
    $zipFilePath = Join-Path -Path $folderMonitorFolderPath -ChildPath "FolderMonitor.zip"

    Invoke-WebRequest -Uri $folderMonitorDownloadUrl -OutFile $zipFilePath

    Expand-Archive -Path $zipFilePath -DestinationPath $folderMonitorFolderPath -Force

    # Удаляем архив
    Remove-Item -Path $zipFilePath -Force

    Write-Host "FolderMonitor.exe успешно установлен в $folderMonitorFolderPath"
}


$localAppDataPath = [Environment]::GetFolderPath("LocalApplicationData")
$folderMonitorXmlPath = Join-Path -Path $localAppDataPath -ChildPath "NodeSoft\FolderMonitor\FolderMonitor.xml"

if (Test-Path -Path $folderMonitorXmlPath -PathType Leaf) {
    if (-not $global:Config.FolderMonitorXML) {

        $global:Config | Add-Member -MemberType NoteProperty -Name "FolderMonitorXML" -Value $folderMonitorXmlPath -Force
        Update-Config "$($global:Folder_Work)\core\Config.json" $global:Config
        Write-Host "Файл FolderMonitor.xml найден и путь обновлен в конфигурационном файле $folderMonitorXmlPath."
    }
    else {
        Write-Host "Ключ 'FolderMonitorXML' уже существует в объекте Config."
    }
}
else {
    Write-Host "Файл FolderMonitor.xml не найден по пути: $folderMonitorXmlPath"
}



if (-not (Test-Path $global:Folder_Files)) {
    New-Item -ItemType Directory -Path $global:Folder_Files | Out-Null
}


foreach ($key in $global:Folders_Original.Keys) {

    $Folder_TMP = (Join-Path -Path $global:Folder_Files -ChildPath  $global:Folders_Original[$key])

    if (-not (Test-Path $Folder_TMP)) {
        New-Item -ItemType Directory -Path $Folder_TMP | Out-Null
    }

    $global:Folders[$key] = $Folder_TMP

    if (-not (Test-Path (Join-Path -Path $Folder_TMP -ChildPath $global:Folder_Today_Prefix))) {
        New-Item -ItemType Directory -Path (Join-Path -Path $Folder_TMP -ChildPath $global:Folder_Today_Prefix) | Out-Null
    }

    $global:Folders_Today[$key] = Convert-Path -Path (Resolve-Path (Join-Path -Path $Folder_TMP -ChildPath $global:Folder_Today_Prefix))

    Remove-Variable -Name Folder_TMP
}
