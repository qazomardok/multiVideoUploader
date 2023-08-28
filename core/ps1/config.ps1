

$global:Config = Get-Config -FilePath $global:Folder_Work
$global:Access = Get-Access -FilePath $global:Folder_Work

if ([string]::IsNullOrEmpty($global:Config.FolderFiles)) {
    $folderFilesPath = Join-Path -Path $global:Folder_Work -ChildPath "files"
    if (-not (Test-Path $folderFilesPath)) {
        New-Item -Path $folderFilesPath -ItemType Directory | Out-Null
    }

    $global:Folder_Files = Convert-Path -Path (Resolve-Path $folderFilesPath)
    $global:Config | Add-Member -MemberType NoteProperty -Name "FolderFiles" -Value $global:Folder_Files -Force
    Update-Config "$($global:Folder_Work)\core\Config.json" $global:Config
}
else {
    $global:Folder_Files = $global:Config.FolderFiles
}

$global:Folder_Files

if (-not (Test-Path $global:Folder_Files)) {
    New-Item -ItemType Directory -Path $global:Folder_Files | Out-Null
}

$global:Folders_Original = @{
    "input"    = "Исходное"
    "cropped"  = "Наложить логотип"
    "withlogo" = "Готовое"
    "forsend"  = "Отправить в соцсети (сейчас)"
    "success"  = "Архив"
}

$global:videoExtensions = ".avi", ".mp4", ".mkv", ".mov", ".mpg"
$global:Folders = @{}
$global:Folders_Today = @{}
$global:Folder_Today_Prefix = Get-Date -Format "dd"

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
