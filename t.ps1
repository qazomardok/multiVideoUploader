param (
      [string]$File = "empty",
      [string]$Notify = "False",
      [string]$OnlyNotify = "False",
      [string]$AddLogo = "False",
      [string]$Convert = "False",
      [string]$Scale = "True",
      [string]$SocialSend = "False",


      [string]$SendYouTube = "False",
      [string]$SendOK = "False",
      [string]$SendVK = "False",


      [string]$nmpUpdate = "False",
      [string]$Remove = "False",
      [int]$AddHour = 0,
      [int]$AddMin = 0,


      [string]$Text = "",
      [string]$Rename = ""

)


# $SocialSend = "False"
# $Notify = "False"
[reflection.assembly]::loadwithpartialname('System.Windows.Forms')
[reflection.assembly]::loadwithpartialname('System.Drawing')

$global:Folder_Work = $PSScriptRoot

$Text = ""

Set-Location $global:Folder_Work
Write-Output $global:Folder_Work



. .\core\ps1\functions.ps1
. .\core\ps1\config.ps1
. .\core\ps1\install.ps1

# [System.Text.Encoding]::UTF8
# Clear-Host

Write-Output "?? Привет!"

Send-Telegram "? тестUU тестUU тестUU"