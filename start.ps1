param (
      [string]$File = "empty",
      [string]$Notify = "False",
      [string]$OnlyNotify = "False",
      [string]$AddLogo = "False",
      [string]$Convert = "False",
      [string]$Scale = "True",
      [string]$SocialSend = "False",
      [string]$Remove = "False",
      [int]$AddHour = 0,
      [int]$AddMin = 0
)


[reflection.assembly]::loadwithpartialname('System.Windows.Forms')
[reflection.assembly]::loadwithpartialname('System.Drawing')

Write-Output "Welcome! ������!"

$global:Folder_Work = $PSScriptRoot

Set-Location $global:Folder_Work
Write-Output $global:Folder_Work
. .\core\ps1\functions.ps1
. .\core\ps1\config.ps1
. .\core\ps1\install.ps1

# [System.Text.Encoding]::UTF8

Write-Output "������!"
# if (-not $Notify) {
#       Write-Host  "�������� ����������� � Telegram? (y/n): "
#       $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
#       if ($key -eq "y") { $Notify = $True } else { $Notify = "False" }
#       if ($key -eq "�") { $Notify = $True } else { $Notify = "False" }
# }
  

# if (-not $AddLogo) {
#       Write-Host "�������� �������? (y/n): "
#       $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
#       if ($key -eq "y") { $AddLogo = $True } else { $AddLogo = "False" }
#       if ($key -eq "�") { $AddLogo = $True } else { $AddLogo = "False" }
# }
        

# if (-not $SocialSend) {
#       Write-Host "��������� ���� � VK � YouTube? (y/n): "
#       $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
#       if ($key -eq "y") { $SocialSend = $True } else { $SocialSend = "False" }
#       if ($key -eq "�") { $SocialSend = $True } else { $SocialSend = "False" }
# }
              
                        






# �������� �����������
if ($OnlyNotify -eq "True") {
      if ($File -eq "empty") {
            Send-Telegram "? ������ ������ ��� �������� ����������� �����"
      }
      else {
            Send-Telegram "? ���� $([System.IO.Path]::GetFileName($File))"
      }
}
else {
      Write-Output "����� ��� ����������� � Telegram"
      if ($File -eq "empty") {
            Toast "������ ������ ��� �������� ����������� �����"
      }
      else {
            Toast "�������� ��������� $($File)"
      } 
}

if ($OnlyNotify -eq "True") {
      exit 0
}

Write-Output "************************************"
$fileFinded = "False"
if ($File -ne "empty") {

      if (-not (Test-Path $File)) {
            Stop-Run -Msg "������ ����� �� ����������"
      }
      $MODE = "FILE"

      $FileCName = "$($global:Folders_Today["input"])\$([System.IO.Path]::GetFileName($File))"
      
      $extension = [System.IO.Path]::GetExtension($File)

      if ($global:videoExtensions -contains $extension) {
            if ($File -ne $FileCName) {
                        
                  Write-Output "*", "* ��������:", "* ��  $File` ", "* �   $FileCName"
            
                  try {
                        Copy-Item -Path $File -Destination $FileCName -Force  -ErrorAction SilentlyContinue
                        
                  }
                  catch {
                        Stop-Run -Msg "�������� ������ ��� ����������� �����."
                  }
                  $FileInputed = $File
                  $File = $FileCName
                  Toast "* ���� ������� ����������."
                  Write-Output "*", "************************************"
            
            }
            Write-Output "* ������� ����: $($File)"
            $fileFinded = $True
      }
      else {
            Write-Warning "* $($File) �� �������� �����"
            return
      }
}
else {
      $MODE = "FOLDER"
      Write-Output ("* ����� ����������� � ����� $($global:Folders["input"])")

      # ��������� ���� ����� ������ � ����� � �� ���������
      $videoFiles = Get-ChildItem -Path $global:Folders["input"] -File -Recurse |
      Where-Object { $_.Extension -in $global:videoExtensions }
      
      if ($videoFiles.Count -gt 0) {
            # ���������� ����� ������ �� ���� ���������� ��������� � �������� �������
            $sortedVideoFiles = $videoFiles | Sort-Object -Property LastWriteTime -Descending
      
            # ����� ������� ����� ����� �� ���������������� ������ (���������� �����)
            $lastVideoFile = $sortedVideoFiles | Select-Object -First 1
      
            # $lastVideoFileName = $lastVideoFile.Name
      
            $File = $lastVideoFile.FullName
            # ����� ���������� � ��������� ����� �����
            Write-Output "* ������� ����: $File" 

            $fileFinded = $True
            # $CONSOLEADD = -join (" -File ", "$($($lastVideoFile.FullName))")
            # $CONSOLEADD
      }
      else {
            Stop-Run -Msg "����� ����� �� ������� � ��������� �����"
            return
      }
}

if ($fileFinded) {
      
      if ($Notify -eq "True") {
            Send-Telegram "?? ��������� ���� $([System.IO.Path]::GetFileName($File))"    
      }
      
      # �������������� ������� �������� � �������
      $WAIT_Seconds = ($AddHour * 60 + $AddMin) * 60

      if ($WAIT_Seconds -gt 0) {
            $endTime = $(Get-Date).AddSeconds($WAIT_Seconds) 
            $tms = "?? ��������� $([System.IO.Path]::GetFileName($File)) ����� ���������� $($endTime)."
            if ($Notify) {
                  Send-Telegram $tms
            }
            else {
                  Write-Output $tms  
            }
            Start-Sleep -Seconds $WAIT_Seconds
      }

      # ������������� �������
      if (($AddLogo -eq "True") -or ($Convert -eq "True")) {
            Write-Output "************************************", "*", "* ������� ���� �������� �����.", "* ����������� �������."
            
            
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
            $fileExtension = [System.IO.Path]::GetExtension($File)
            # ������� ������ ���� � �������� �����
            $FileArchive = Join-Path -Path $($global:Folders_Today["success"]) -ChildPath "$fileName$fileExtension"
            $FileTo = Join-Path -Path $($global:Folders_Today["withlogo"]) -ChildPath "$fileName$fileExtension"

            if ($MODE -eq "FOLDER") {                  
                  Write-Output "* � ������ ������ ��� �������� ��������� -File ������� ���� ������������ � �����."
                  try {
                        $counter = 1
                        while (Test-Path $FileArchive) {
                              # ����������� ������� � ����������� ��� ����� � ����� ���������
                              $newFileName = "{0} ({1}){2}" -f $fileName, $counter, $fileExtension
                              $FileArchive = Join-Path -Path $($global:Folders_Today["success"]) -ChildPath $newFileName
                              $counter++
                        }

                        Move-Item -Path $File -Destination  $FileArchive
                        Write-Output "* $([System.IO.Path]::GetFileName($File)) ��������� � $($global:Folders_Today["success"])."
                        runMMPEG $FileArchive $FileTo $Convert $Scale
                        Toast "* ��������� ���� $FileTo." -BackgroundColor White -ForegroundColor Red
                        $File = $FileTo
                  }
                  catch {
                        Toast "* �������� ������ ��� ����������� $([System.IO.Path]::GetFileName($File)) � �����."
                        Toast "* `($File`) -> `($FileArchive`)."
                        Write-Output "* $_"
                  }
            }
            else {
                  runMMPEG $File $FileTo $Convert $Scale
                  Toast "* ��������� ���� $FileTo."
                  $File = $FileTo
            }

            if ($Notify -eq "True") {
                  Send-Telegram "?? ������� ������� �� $File." 
            }
            Write-Output "*", "************************************"
      }
      else {
            Write-Output ("* ��� ��������� �������� �������� �������� `"-AddLogo `$True`" � ������.")
      }

      if ($SocialSend -eq "True") {
            

            if (($null -ne $global:Config.NodeJSPath) -and (Test-Path $global:Config.NodeJSPath)) {

                  $nodeExePath = Escape-VariableValue -Value $global:Config.NodeJSPath -B "`""
                  $videoFile = Escape-VariableValue -Value $File      
                  # $Folder_Work = Escape-VariableValue -Value $($global:Folder_Work)


                  Write-Output "* Folder_Work: $Folder_Work"
                  $SocialNetworksFiles = @{
                        "���������" = "vk"
                        "YouTube"   = "youtube"
                        #"Telegram" = "telegram"
                        "OK" = "okru"
                  }

                  $command = "D:"
                  Invoke-Expression $command
                  $NodeJSFolder = Join-Path -Path $global:Folder_Work -ChildPath "core\nodejs"
                  $command = "cd $NodeJSFolder"
                  Invoke-Expression $command

                  # $command = "& npm update"
                  # Invoke-Expression $command

                  foreach ($key in $SocialNetworksFiles.Keys) {
                        Write-Output " ", "* ������ ������ $key..."
                        $scriptPath = Escape-VariableValue -Value "$($global:Folder_Work)\core\nodejs\$($SocialNetworksFiles[$key]).js"
                        $command = "& $nodeExePath $scriptPath $videoFile $Folder_Work"
                        Invoke-Expression $command
                        Write-Output " "
                  }

                  $command = "cd $($global:Folder_Work)" 
                  Invoke-Expression $command
            }
            else {
                  Stop-Run -Msg "NodeJS �� ���������. ���������� ��� ��������� ���� � node.exe � ����� Config.json (���������� `"NodeJSPath`")"
            }             
      }
      else {
            Write-Output ("* ��� �������� � ��������� � YouTube �������� �������� `"-SocialSend `$True`" � ������.")
      }

      if ($Remove -eq "True") {

            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
            $fileExtension = [System.IO.Path]::GetExtension($File)
            # ������� ������ ���� � �������� �����
            $FileArchive = Join-Path -Path $($global:Folders["success"]) -ChildPath "$fileName$fileExtension"

            try {
                  $counter = 1
                  while (Test-Path $FileArchive) {
                        # ����������� ������� � ����������� ��� ����� � ����� ���������
                        $newFileName = "{0} ({1}){2}" -f $fileName, $counter, $fileExtension
                        $FileArchive = Join-Path -Path $($global:Folders["success"]) -ChildPath $newFileName
                        $counter++
                  }

                  Move-Item -Path $File -Destination  $FileArchive
                  Remove-Item $FileInputed
                  Toast "* $([System.IO.Path]::GetFileName($File)) ��������� � $($global:Folders["success"])."
                 
            }
            catch {
                  Toast "* �������� ������ ��� ����������� $([System.IO.Path]::GetFileName($File)) � �����."
                  Toast "* `($File`) -> `($FileArchive`)."
                  Write-Output "* $_"
            }
      }


      if ($WAIT_Seconds -gt 0) {
            Add-Type -AssemblyName System.Windows.Forms

            $mss = 900000;
            [int] $mins = $mss / 60 / 1000
            $timespan = New-TimeSpan -Seconds ($mss / 1000)
            
            $newTime = (Get-Date) + $timespan
            $ht = $newTime.ToString("HH:mm")
             
            
            
            $form = New-Object System.Windows.Forms.Form
            $form.Text = "�������������"
            $form.Size = New-Object System.Drawing.Size(600, 125)
            $form.StartPosition = "CenterScreen"
            $form.TopMost = $true

            $label = New-Object System.Windows.Forms.Label
            $label.Text = "������� ������ �� ���������� ���������. ����� $mins ����� ��������� ������� � ������ ����� � $ht."
            $label.AutoSize = $true
            $label.Location = New-Object System.Drawing.Point(10, 10)
            $form.Controls.Add($label)
            
            $yesButton = New-Object System.Windows.Forms.Button
            $yesButton.Text = "����������� ������"
            $yesButton.Location = New-Object System.Drawing.Point(10, 50)
            $yesButton.Size = New-Object System.Drawing.Size(150, 23)
            $yesButton.DialogResult = "Yes"
            $form.Controls.Add($yesButton)
            
            $noButton = New-Object System.Windows.Forms.Button
            $noButton.Text = "�� �����������"
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
                  Write-Output ("������� ��")
                  shutdown /h
                  Exit 0
            }
            else {
                  Write-Output ("������� ���")
            }
            
      }

}

Write-Output "* ������ ���������.", "************************************"
#Start-Sleep -Seconds 120
# Environment.Exit(0)
Exit 0