# Убедитесь, что переменная $global:videoExtensions определена
$global:videoExtensions = ".avi", ".mp4", ".mkv", ".mov", ".mpg"

# Укажите путь к вашему скрипту
$scriptPath = "$($global:Folder_Work)\start.ps1"

# Функция для добавления контекстного меню
function Add-ContextMenu {
    param (
        [string]$extension,
        [string]$scriptPath
    )

    # Основной путь к контекстному меню
    $contextMenuPath = "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\$extension\shell\VideoProcessing"
    $commandBasePath = "$contextMenuPath\shell"

    # Создание записи для главного пункта контекстного меню
    New-Item -Path $contextMenuPath -Force | Out-Null
    Set-ItemProperty -Path $contextMenuPath -Name "MUIVerb" -Value "Обработка видео" -Force
    Set-ItemProperty -Path $contextMenuPath -Name "SubCommands" -Value "" -Force

    # Создание подпунктов меню
    $subCommands = @(
        @{
            Verb = "SendToSocialMedia"
            Name = "Отправить в соцсети"
            Args = "-File `"%1`" -AddLogo `"False`" -SocialSend `"True`" -Notify `"True`" -fromContext `"True`""
        },
        @{
            Verb = "AddLogo"
            Name = "Наложить логотип"
            Args = "-File `"%1`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        },
        @{
            Verb = "ProcessLater0"
            Name = "Наложить логотип и опубликовать"
            Args = "-File `"%1`" -AddLogo `"True`" -SocialSend `"True`" -Notify `"True`" -fromContext `"True`""
        },
        @{
            Verb = "ProcessLater3"
            Name = "Обработать через 3 часа"
            Args = "-File `"%1`"  -AddHour `"3`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        },
        @{
            Verb = "ProcessLater6"
            Name = "Обработать через 6 часов"
            Args = "-File `"%1`"  -AddHour `"6`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        },
        @{
            Verb = "ProcessLater9"
            Name = "Обработать через 9 часов"
            Args = "-File `"%1`"  -AddHour `"9`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        },,
        @{
            Verb = "ProcessLater12"
            Name = "Обработать через 12 часов"
            Args = "-File `"%1`"  -AddHour `"12`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        },,
        @{
            Verb = "ProcessLater19"
            Name = "Обработать через 19 часов"
            Args = "-File `"%1`"  -AddHour `"19`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        },
        @{
            Verb = "ProcessLater24"
            Name = "Обработать через 24 часа"
            Args = "-File `"%1`"  -AddHour `"24`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        },
        @{
            Verb = "ProcessLater36"
            Name = "Обработать через 36 часа"
            Args = "-File `"%1`"  -AddHour `"36`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        },
        @{
            Verb = "ProcessLater48"
            Name = "Обработать через 48 часа"
            Args = "-File `"%1`"  -AddHour `"48`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        },
        @{
            Verb = "ProcessLater66"
            Name = "Обработать через 66 часа"
            Args = "-File `"%1`"  -AddHour `"66`" -AddLogo `"True`" -SocialSend `"False`" -Notify `"True`" -fromContext `"True`""
        }
    )

    foreach ($key in $global:SocialNetworksFiles.Keys) {
        $subCommands += @{
            Verb = "ProcessLater$($key)"
            Name = "Отправить в $key"
            Args = "-File `"%1`" -AddLogo `"False`" -SocialSend `"True`" -Notify `"False`" -Server `"$($global:SocialNetworksFiles[$key])`" -fromContext `"True`""
        }
    }

    foreach ($subCommand in $subCommands) {
        $subCommandPath = "$commandBasePath\$($subCommand.Verb)"
        New-Item -Path $subCommandPath -Force | Out-Null
        Set-ItemProperty -Path $subCommandPath -Name "MUIVerb" -Value $subCommand.Name -Force

        $commandPath = "$subCommandPath\command"
        New-Item -Path $commandPath -Force | Out-Null
        Set-ItemProperty -Path $commandPath -Name "(Default)" -Value "powershell.exe -exec bypass -file `"$scriptPath`" $($subCommand.Args)" -Force


        # Write-Output "💼 команда меню: $($subCommand.Args)"
        # Write-Output "powershell.exe -exec bypass -file '$scriptPath' $($subCommand.Args)"
        # Write-Output "======================"
    }
}

# Функция для удаления контекстного меню
function Remove-ContextMenu {
    param (
        [string]$extension
    )

    # Основной путь к контекстному меню
    $contextMenuPath = "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\$extension\shell\VideoProcessing"

    # Удаление записи для пункта контекстного меню
    if (Test-Path -Path $contextMenuPath) {
        Remove-Item -Path $contextMenuPath -Recurse -Force
    }
}

if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script runned with Admin privileges"


if ($Reinstall -eq "True") {

    Write-Output "💼 Обновляем меню..."
    # Удаление контекстного меню для каждого расширения
    foreach ($extension in $global:videoExtensions) {
        Remove-ContextMenu -extension $extension
        Add-ContextMenu -extension $extension -scriptPath $scriptPath
    }

    Write-Output "💼 Готово"

    Environment.Exit(0);
    exit 0;
}
} else {
    Write-Host "Script runned without Admin privileges"
}










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
