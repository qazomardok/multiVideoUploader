
function Stop-Run {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Msg = " "
    )
    if ($Msg -ne "") {
        Toast "* !$($Msg)!"    
    } 
    
    Write-Output "* Работа завершена.", "************************************" 
    Exit 0
}

function Get-Config {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $Config_File = "$FilePath\core\Config.json"
   
    if (!(Test-Path $Config_File)) {
        # Создание пустого конфигурационного файла
        Update-Config $Config_File
    }
   
    $Config = Get-Content -Path $Config_File -Raw | ConvertFrom-Json 
    return $Config
}

function Get-Access {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $Config_File = "$FilePath\core\Access.json"
   
    if (!(Test-Path $Config_File)) {
        # Создание пустого конфигурационного файла
        Update-Access $Config_File
    }
   
    $Config = Get-Content -Path $Config_File -Raw | ConvertFrom-Json 
    return $Config
}


Function Update-Config {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Config_File,
        [array]$NewVars = @{
            "FolderFiles"      = $global:Folder_Files
            "NodeJSPath"       = (Get-Command node).Source
            "Scale_X"          = "1280"
            "Scale_Y"          = "720"
            "Logo_X"           = "15"
            "Logo_Y"           = "15"
            "debug"            = "true"
            "WebServerPort"    = "8081"
            "WebServerAddress" = "http://localhost"
        }
    )
   
    $NewVars | ConvertTo-Json | Out-File -FilePath $Config_File




    $jsonData = Get-Content -Path $Config_File | Out-String
    $utf8Encoding = New-Object System.Text.UTF8Encoding($false)  # указываем $false для беззнаковой UTF-8
    [System.IO.File]::WriteAllText($Config_File, $jsonData, $utf8Encoding)

    # return Get-Config -FilePath $global:Folder_Work
}

Function Update-Access {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Access_File,
        [array]$NewVars = @{
            
            "Telegram" = @{
                
                "Token"         = ""
                "ChatID"        = ""
                "ChatIDPublish" = ""
                "FileLimit"     = 52428800
            }
            "VK"       = @{
                "Group_AceessToken" = ""
                "Group_ID"          = ""
            }
            "OK"       = @{
                "okapp_id"             = ""
                "okpublic_key"         = ""
                "oksecret"             = ""
                "okaccessToken"        = ""
                "oksession_secret_key" = ""
                "okscope"              = ""
                "groupID"              = ""
            }
            "Youtube"  = @{
            }
        }
    )
   
    $NewVars | ConvertTo-Json | Out-File -FilePath $Access_File


    $jsonData = Get-Content -Path $Access_File | Out-String
    $utf8Encoding = New-Object System.Text.UTF8Encoding($false)  # указываем $false для беззнаковой UTF-8
    [System.IO.File]::WriteAllText($Access_File, $jsonData, $utf8Encoding)

    # return Get-Config -FilePath $global:Folder_Work
}


function Toast {
    
    Param([Parameter(Mandatory = $true)][String]$Message)
    
    Write-Output $Message
    $notify = new-object system.windows.forms.notifyicon
    $notify.icon = [System.Drawing.SystemIcons]::Asterisk
    $notify.visible = $true
    $notify.showballoontip(10, "AutoVideos", $Message, [system.windows.forms.tooltipicon]::None)
    $notify.Dispose()
    return

}

Function Send-Telegram {
    Param([Parameter(Mandatory = $true)][String]$Message)

    Toast $Message
    
    $updated = $false

    if ([string]::IsNullOrEmpty($global:Access)) {
        $global:Access = @{}
    }

    if ([string]::IsNullOrEmpty($global:Access.Telegram)) {
        $global:Access | Add-Member -MemberType NoteProperty -Name "Telegram" -Value @{} 
        $updated = $true
    }
    if ([string]::IsNullOrEmpty($global:Access.Telegram.ChatID)) {
        $input_ChatID = Read-Host "Введите ChatID канала уведомлений Telegram"
        $global:Access.Telegram | Add-Member -MemberType NoteProperty -Name "ChatID" -Value $input_ChatID -Force
        $updated = $true
    }
    if ([string]::IsNullOrEmpty($global:Access.Telegram.ChatIDPublish)) {
        $input_ChatIDPublish = Read-Host "Введите ChatID канала для отправки видео в Telegram"
        $global:Access.Telegram | Add-Member -MemberType NoteProperty -Name "ChatID" -Value $input_ChatIDPublish -Force
        $updated = $true
    }
    
    if ([string]::IsNullOrEmpty($global:Access.Telegram.Token)) {
        $input_Token = Read-Host "Введите Token доступа к API Telegram"
        $global:Access.Telegram | Add-Member -MemberType NoteProperty -Name "Token" -Value $input_Token  -Force
        $updated = $true
    }
    
    if ($updated) {
        Update-Access "$($global:Folder_Work)\core\Access.json" $global:Access
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    if (![string]::IsNullOrEmpty($Message)) {
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$($global:Access.Telegram.Token)/sendMessage?chat_id=$($global:Access.Telegram.ChatID)&text=$($Message)"
        "* * TG уведомление отправлено: $($Message)"
    }
    else {
        "* * TG уведомление не отправлено: $($Message)"
    }
}

function runMMPEG {

    param (
        [Parameter(Mandatory = $true)]
        [string]$From,
        [string]$To,
        [string]$OnlyConvert = "Fasle",
        [string]$Scale = "Fasle")

    Write-Output "* Подождите..."
         
    Write-Output "* << $From"
    Write-Output "* >> $To"
                 
    # $From
    # $To
    $FFMPEG_Exec = -join ($global:Folder_Work, "\core\ffmpeg\ffmpeg.exe")
    $FFMPEG_LogoFile = -join ($global:Folder_Work, "\img\logo.png")


    if ($Scale -eq "True") {
        $filter = "-filter_complex `"[0:v]scale=$($global:Config.Scale_X):$($global:Config.Scale_Y)[out]`" -map `"[out]`"  -map 0:a"
    }
    else {
        $filter = ""
    }

    if ($OnlyConvert -eq "True") {


        $comm = "$FFMPEG_Exec -i `"$From`" -y $filter -c:v h264_amf `"$To`""
        Invoke-Expression $comm

    }
    else {
       
        & $FFMPEG_Exec -i $From -y -i $FFMPEG_LogoFile -filter_complex "[0:v]scale=$($global:Config.Scale_X):$($global:Config.Scale_Y)[scaled];[scaled][1:v]overlay=$($global:Config.Logo_X):$($global:Config.Logo_Y)[out]" -map "[out]" -map 0:a -c:v h264_amf $To -hide_banner
    }

    Write-Output  $comm
    Write-Output "* Готово!"
}

function Escape-VariableValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [string]$B = "`""
    )

    # Список специальных символов, которые требуют экранирования
    $specialCharacters = '"`$'

    foreach ($char in $specialCharacters) {
        # Заменяем каждый специальный символ на его экранированную версию
        $Value = "$B$($Value.Replace($char, "`$char"))$B"
    }

    return $Value
}