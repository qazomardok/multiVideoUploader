﻿param (
      [string]$File = "empty",
      [string]$Notify = "False",
      [string]$OnlyNotify = "False",
      [string]$AddLogo = "False",
      [string]$Convert = "False",
      [string]$Scale = "True",
      [string]$SocialSend = "False",
      [string]$isCron = "False",
      [string]$fromContext = "False",


      [string]$SendYouTube = "False",
      [string]$SendOK = "False",
      [string]$SendVK = "False",


      [string]$nmpUpdate = "False",
      [string]$Remove = "False",
      [int]$AddHour = 0,
      [int]$AddMin = 0,

      [string]$Server = "",
      [string]$Text = "",
      [string]$Rename = "",
      [string]$Reinstall = "False",
      [string]$Stopnow = "False"
)

 if($Server -eq ""){

      $global:SocialNetworksFiles = @{
            "RUTUBE"    = "rutube"
            "ВКонтакте" = "vk"
            "YouTube"   = "youtube"
            #"Telegram" = "telegram"
            "OK"        = "okru"
      }

} else {
      $global:SocialNetworksFiles = @{
            $Server = $Server
      }
}

# $SocialSend = "False"
# $Notify = "False"
[reflection.assembly]::loadwithpartialname('System.Windows.Forms')
[reflection.assembly]::loadwithpartialname('System.Drawing')

$global:Folder_Work = $PSScriptRoot

# $Text = ""




$commands_logfolderName = ".commands_log"

# Создаем полный путь к папке
$commands_logfolderPath = Join-Path -Path $global:Folder_Work -ChildPath $commands_logfolderName

# Проверяем, существует ли папка
if (-not (Test-Path -Path $commands_logfolderPath)) {
    # Создаем папку, если она не существует
    New-Item -Path $commands_logfolderPath -ItemType Directory
}
Get-ChildItem -Path $commands_logfolderPath -Recurse | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt (Get-Date).AddDays(-7) } | Remove-Item -Force
$currentDateTime = Get-Date
$formattedDateTime = $currentDateTime.ToString("dd.MM.yyyy H-mm")


$logFile = "$($commands_logfolderPath)\$formattedDateTime.bat"
$logText = $MyInvocation.MyCommand
$logText = ""
$PSBoundParameters.GetEnumerator() | ForEach-Object { $logText += "-$($_.Key) ""$($_.Value)"" " }
Write-Output $logText


$CCOM = "powershell.exe -exec bypass -file `"$($global:Folder_Work)`\$($MyInvocation.MyCommand)`" $($logText)"

New-Item -Path $logFile -ItemType file -Force
Set-Content -Path $logFile $CCOM

Write-Output "📝 Команда `"$($global:Folder_Work)`\$($MyInvocation.MyCommand)`" $($logText)"
Write-Output "📝 записана в $logFile"

if($fromContext -eq "True"){
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    $arguments = "-exec bypass -file `"$($global:Folder_Work)`\$($MyInvocation.MyCommand)`" $($logText)"
    Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs


#     Start-Process $CCOM -Verb RunAs
      Start-Sleep -Seconds 30
Exit 0
}

}






Set-Location $global:Folder_Work


. .\core\ps1\functions.ps1
. .\core\ps1\config.ps1
. .\core\ps1\install.ps1

# [System.Text.Encoding]::UTF8
# Clear-Host

Write-Output "🤗 Привет!"
# if (-not $Notify) {
#       Write-Host  "Посылать уведомления в Telegram? (y/n): "
#       $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
#       if ($key -eq "y") { $Notify = $True } else { $Notify = "False" }
#       if ($key -eq "н") { $Notify = $True } else { $Notify = "False" }
# }


# if (-not $AddLogo) {
#       Write-Host "Добавить логотип? (y/n): "
#       $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
#       if ($key -eq "y") { $AddLogo = $True } else { $AddLogo = "False" }
#       if ($key -eq "н") { $AddLogo = $True } else { $AddLogo = "False" }
# }


# if (-not $SocialSend) {
#       Write-Host "Загрузить файл в VK и YouTube? (y/n): "
#       $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
#       if ($key -eq "y") { $SocialSend = $True } else { $SocialSend = "False" }
#       if ($key -eq "н") { $SocialSend = $True } else { $SocialSend = "False" }
# }








# ПОСЫЛАЕМ УВЕДОМЛЕНИЕ
if ($OnlyNotify -eq "True") {
      if ($File -eq "empty") {
            Send-Telegram "⚡ Начало работы без указания конкретного файла"
      }
      else {
            Send-Telegram "⚡ Новый файл $([System.IO.Path]::GetFileName($File))"
      }
}
else {
      # Write-Output "Режим без уведомлений в Telegram"
      if ($File -eq "empty") {
            Toast "Начало работы без указания конкретного файла"
      }
      else {
            Toast "Началась обработка $($File)"
      }
}

if ($OnlyNotify -eq "True") {
      exit 0
}

Write-Output "************************************"
$fileFinded = "False"
if ($File -ne "empty") {

      if (-not (Test-Path $File)) {
            Stop-Run -Msg "Такого файла не существует"
      }
      $MODE = "FILE"

      $FileCName = "$($global:Folders_Today["input"])\$([System.IO.Path]::GetFileName($File))"

      $extension = [System.IO.Path]::GetExtension($File)

      if ($global:videoExtensions -contains $extension) {
            if ($File -ne $FileCName) {

                  Write-Output "*", "* Копируем:", "* >>  $File` ", "* <<  $FileCName"

                  try {
                        Copy-Item -Path $File -Destination $FileCName -Force  -ErrorAction SilentlyContinue
                  }
                  catch {
                        Stop-Run -Msg "Возникла ошибка при копировании файла."
                  }
                  $FileInputed = $File
                  $File = $FileCName
                  Toast "* Файл успешно скопирован."
                  Write-Output "*", "************************************"

            }
            Write-Output "* Рабочий файл: $($File)"
            $fileFinded = $True
      }
      else {
            Write-Warning "* $($File) не является видео"
            return
      }
}
else {
      $MODE = "FOLDER"
      Write-Output ("* Поиск видеофайлов в папке $($global:Folders["input"])")

      # Получение всех видео файлов в папке и ее подпапках
      $videoFiles = Get-ChildItem -Path $global:Folders["input"] -File -Recurse |
      Where-Object { $_.Extension -in $global:videoExtensions }

      if ($videoFiles.Count -gt 0) {
            # Сортировка видео файлов по дате последнего изменения в обратном порядке
            $sortedVideoFiles = $videoFiles | Sort-Object -Property LastWriteTime -Descending

            # Выбор первого видео файла из отсортированного списка (последнего файла)
            $lastVideoFile = $sortedVideoFiles | Select-Object -First 1

            # $lastVideoFileName = $lastVideoFile.Name

            $File = $lastVideoFile.FullName
            # Вывод информации о последнем видео файле
            Write-Output "* Рабочий файл: $File"

            $fileFinded = $True
            # $CONSOLEADD = -join (" -File ", "$($($lastVideoFile.FullName))")
            # $CONSOLEADD
      }
      else {
            Stop-Run -Msg "Видео файлы не найдены в указанной папке"
            return
      }
}

if ($fileFinded) {

      if (($Notify -eq "True") -and ($isCron -ne "True")) {
            Send-Telegram "⚡ Обрабатывается файл $([System.IO.Path]::GetFileName($File))"
      }



      # УСТАНАВЛИВАЕМ ЛОГОТИП
      if (($AddLogo -eq "True") -or ($Convert -eq "True")) {
            Write-Output "************************************", "*", "* Рабочий файл является видео.", "* Будет наложен логотип."


            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
            $fileExtension = [System.IO.Path]::GetExtension($File)
            # Создаем полный путь к целевому файлу
            $FileArchive = Join-Path -Path $($global:Folders_Today["success"]) -ChildPath "$fileName$fileExtension"
            $FileTo = Join-Path -Path $($global:Folders_Today["withlogo"]) -ChildPath "$fileName$fileExtension"

            if ($MODE -eq "FOLDER") {
                  Write-Output "* 👻 В режиме работы без указания аттрибута -File рабочий файл перемещается в архив."
                  try {
                        $counter = 1
                        while (Test-Path $FileArchive) {
                              # Увеличиваем счетчик и форматируем имя файла с новым счетчиком
                              $newFileName = "{0} ({1}){2}" -f $fileName, $counter, $fileExtension
                              $FileArchive = Join-Path -Path $($global:Folders_Today["success"]) -ChildPath $newFileName
                              $counter++
                        }

                        Move-Item -Path $File -Destination  $FileArchive
                        Write-Output "* $([System.IO.Path]::GetFileName($File)) перемещён в $($global:Folders_Today["success"])."
                        runMMPEG $FileArchive $FileTo $Convert $Scale
                        Toast "* 🟢 Проверьте файл $FileTo." -BackgroundColor White -ForegroundColor Red
                        $File = $FileTo
                  }
                  catch {
                        Toast "* 🔴 Возникла ошибка при перемещении $([System.IO.Path]::GetFileName($File)) в архив."
                        Toast "* `($File`) -> `($FileArchive`)."
                        Write-Output "* $_"
                  }
            }
            else {
                  runMMPEG $File $FileTo $Convert $Scale
                  Toast "* ⚡Проверьте файл $FileTo."
                  $File = $FileTo
            }

            if ($Notify -eq "True") {

                  Send-Telegram "🟢 Наложен логотип на $File."

                        $msg = "Наложен логотип на $File"
                        # $computerName = "verstka"
                        # msg * /server:$computerName $msg
                        # Invoke-Command -ComputerName verstka -ScriptBlock {msg * $msg}
                        Toast $msg
            }
            Write-Output "*", "************************************"
      }
      else {
            Write-Output ("* ⚡ Для установки логотипа добавьте параметр `"-AddLogo `$True`" в запрос.")
            $FileTo = $File
      }


      # Преобразование времени задержки в секунды
      $WAIT_Seconds = ($AddHour * 60 + $AddMin) * 60

      if ($WAIT_Seconds -gt 0) {



$folderPath = "\Отправка в соцсети\"

try {
    $tasks = Get-ScheduledTask -TaskPath $folderPath -ErrorAction Stop |
        ForEach-Object {
            $taskName = $_.TaskName
            $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName -TaskPath $folderPath
            if ($taskInfo.LastTaskResult -eq 0) {
                $_  # Возвращаем задачу, если она завершилась с кодом 0x0
            }
        }

    # Если есть задачи, которые нужно удалить, выполняем их удаление
    if ($tasks) {
        $tasks | ForEach-Object {
            Unregister-ScheduledTask -TaskName $_.TaskName -TaskPath $folderPath -Confirm:$false
        }
    } else {
        Write-Host "Нет задач с кодом завершения 0x0 в указанной папке."
    }

} catch {
    Write-Host "В папке '$($folderPath)' нет задач или произошла ошибка: $_"
}

# $tasksMsgs = @()
$cronWAITSECONDS = $WAIT_Seconds
 foreach ($key in $global:SocialNetworksFiles.Keys) {
                        # Write-Output " ", "* 🎱 Запуск модуля $key..."
                        # $scriptPath = Escape-VariableValue -Value "$($global:Folder_Work)\core\nodejs\$($SocialNetworksFiles[$key]).js"



$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-command `"& '$($MyInvocation.MyCommand.Path)' -File '$FileTo' -AddLogo 'False' -SocialSend 'True' -isCron 'True' -Notify 'True' -Server $($global:SocialNetworksFiles[$key])`""

$taskName = "$($AddHour)ч. $($global:SocialNetworksFiles[$key]) $([System.IO.Path]::GetFileName($File))_$((Get-Date).Ticks)"
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds($cronWAITSECONDS)
$Settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -WakeToRun -AllowStartIfOnBatteries -StartWhenAvailable
$SvcUser = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType Password
Register-ScheduledTask -TaskPath $folderPath -TaskName "$taskName" -Action $Action -Trigger $Trigger -Principal $SvcUser -Settings $Settings

# $tasksMsgs += $taskName

Send-Telegram "⚡ Добавлена запись в планировщик: " + $taskName

$cronWAITSECONDS = $cronWAITSECONDS + 300
}

# Send-Telegram "⚡ Добавлены записи в планировщик: " + ($tasksMsgs -join ", ")


if($isCron -eq "True"){
} else {

            $endTime = $(Get-Date).AddSeconds($WAIT_Seconds)
            $tms = "🕘 Обработка $([System.IO.Path]::GetFileName($File)) будет продолжена $($endTime)."
            if ($Notify -eq "True") {
                  Send-Telegram $tms
                  Write-Output $tms
            }
            else {
                  Write-Output $tms
            }


Write-Output "* Работа завершена.", "************************************"
Start-Sleep -Seconds 120

# Environment.Exit(0)
Exit 0

            # Start-Sleep -Seconds $WAIT_Seconds
}
      }

      if ($SocialSend -eq "True") {



            if (($null -ne $global:Config.NodeJSPath) -and (Test-Path $global:Config.NodeJSPath)) {

                  $nodeExePath = Escape-VariableValue -Value $global:Config.NodeJSPath -B "`""
                  $videoFile = Escape-VariableValue -Value $File
                  # $Folder_Work = Escape-VariableValue -Value $($global:Folder_Work)


                  Write-Output "* Folder_Work: $Folder_Work"


                  $command = "D:"
                  Invoke-Expression $command
                  $NodeJSFolder = Join-Path -Path $global:Folder_Work -ChildPath "core\nodejs"

                  if ($nmpUpdate -eq "True") {
                        $command = "cd $NodeJSFolder\app"
                        Invoke-Expression $command

                        $command = "& npm update"
                        Invoke-Expression $command
                  }
                  $command = "cd $NodeJSFolder"
                  Invoke-Expression $command


                  foreach ($key in $global:SocialNetworksFiles.Keys) {
                        Write-Output " ", "* 🎱 Запуск модуля $key..."
                        $scriptPath = Escape-VariableValue -Value "$($global:Folder_Work)\core\nodejs\$($global:SocialNetworksFiles[$key]).js"
                        $command = "& $nodeExePath $scriptPath $videoFile $Folder_Work $Text"
                        Invoke-Expression $command
                        Write-Output " "
                  }

                  $command = "cd $($global:Folder_Work)"
                  Invoke-Expression $command
            }
            else {
                  Stop-Run -Msg "🔴 NodeJS не обнаружен. Установите или проверьте путь к node.exe в файле Config.json (переменная `"NodeJSPath`")"
            }
      }
      else {
            Write-Output ("* Для отправки в социальные сети добавьте -SocialSend `"True`" в запрос.")
      }

      if ($Remove -eq "True") {

            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
            $fileExtension = [System.IO.Path]::GetExtension($File)
            # Создаем полный путь к целевому файлу
            $FileArchive = Join-Path -Path $($global:Folders["success"]) -ChildPath "$fileName$fileExtension"

            try {
                  $counter = 1
                  while (Test-Path $FileArchive) {
                        # Увеличиваем счетчик и форматируем имя файла с новым счетчиком
                        $newFileName = "{0} ({1}){2}" -f $fileName, $counter, $fileExtension
                        $FileArchive = Join-Path -Path $($global:Folders["success"]) -ChildPath $newFileName
                        $counter++
                  }

                  Move-Item -Path $File -Destination  $FileArchive
                  Remove-Item $FileInputed
                  Toast "* $([System.IO.Path]::GetFileName($File)) перемещён в $($global:Folders["success"])."

            }
            catch {
                  Toast "* 🔴 Возникла ошибка при перемещении $([System.IO.Path]::GetFileName($File)) в архив."
                  Toast "* `($File`) -> `($FileArchive`)."
                  Write-Output "* $_"
            }
      }

  #    if ((Get-Date).DayOfWeek -ne 'Sunday') {
         $WAIT_Seconds = 0
  #    }

      if ($WAIT_Seconds -gt 0) {
            Add-Type -AssemblyName System.Windows.Forms

            $mss = 900000;
            [int] $mins = $mss / 60 / 1000
            $timespan = New-TimeSpan -Seconds ($mss / 1000)

            $newTime = (Get-Date) + $timespan
            $ht = $newTime.ToString("HH:mm")

            $form = New-Object System.Windows.Forms.Form
            $form.Text = "Подтверждение"
            $form.Size = New-Object System.Drawing.Size(600, 125)
            $form.StartPosition = "CenterScreen"
            $form.TopMost = $true

            $label = New-Object System.Windows.Forms.Label
            $label.Text = "Скрытая задача по публикации выполнена. Через $mins минут компьютер перейдёт в спящий режим в $ht."
            $label.AutoSize = $true
            $label.Location = New-Object System.Drawing.Point(10, 10)
            $form.Controls.Add($label)

            $yesButton = New-Object System.Windows.Forms.Button
            $yesButton.Text = "Блокировать сейчас"
            $yesButton.Location = New-Object System.Drawing.Point(10, 50)
            $yesButton.Size = New-Object System.Drawing.Size(150, 23)
            $yesButton.DialogResult = "Yes"
            $form.Controls.Add($yesButton)

            $noButton = New-Object System.Windows.Forms.Button
            $noButton.Text = "Не блокировать"
            $noButton.Location = New-Object System.Drawing.Point(175, 50)
            $noButton.Size = New-Object System.Drawing.Size(100, 23)
            $noButton.DialogResult = "No"
            $form.Controls.Add($noButton)

            $form.AcceptButton = $yesButton
            $form.CancelButton = $noButton

            $timer = New-Object System.Windows.Forms.Timer
            $timer.Interval = $mss
            $timer.Add_Tick({
                        $form.DialogResult = "Yes"
                        $form.Close()
                  })
            $timer.Start()

            $result = $form.ShowDialog()

            $timer.Stop()

            $timer.Dispose()


            if ($result -eq "Yes") {
                  Write-Output ("выбрано ДА")
                  shutdown /h
                  Exit 0
            }
            else {
                  Write-Output ("выбрано НЕТ")
            }

      }
}
if($isCron -eq "True"){

} else {
Write-Output "* Работа завершена.", "************************************"
      if($Stopnow -ne "True"){
      Start-Sleep -Seconds 120
      }
}
# Environment.Exit(0)
Exit 0