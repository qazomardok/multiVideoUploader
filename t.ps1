$StoryH = 1440
$StoryW = 900
$StoryAW = $StoryW + ($StoryW * 0.1)

$global:Folder_Work = "d:\_autovideos3\"

$From = "D:\_autovideos3\files\test.mp4"
$SubscribesMov = "D:\_autovideos3\files\link_vk.mov"

$StoryTo = "D:\_autovideos3\files\out.mp4"

$FFMPEG_Exec = -join ($global:Folder_Work, "\core\ffmpeg\ffmpeg.exe")
$FFMPEG_LogoFile = -join ($global:Folder_Work, "\img\logo.png")

$SubscribePos = @(
      # W:H:X:Y
      "290:120:125:550", #сайт
      "270:120:465:550", #вк
      "250:120:782:550"  #ОК
)

$RandomSubscribePos = Get-Random -InputObject $SubscribePos

$TextToOverlay = "Продолжение в группе"
$FontPath = "C:\Windows\Fonts\MyriadPro-BoldCond.otf"

# Добавьте новый фильтр для наложения текста "Продолжение в группе"
$TextFilter = "[4:v]drawtext=text='$TextToOverlay':fontfile=$FontPath:fontsize=24:fontcolor=white:shadowcolor=black:shadowx=2:shadowy=2:x=(w-text_w)/2:y=h-50[text_overlay]"

$filterShortsArray = @(
      "[0:v]scale=$StoryW`:$StoryH,setsar=1:1,boxblur=30[bg]",
      "[1:v]scale=$StoryAW`:-1[fg]",
      "[bg][fg]overlay=(W-w)/2:(H-h)/2[main]",
      "[2:v]scale=$StoryH/2.2:-1[logo]",
      "[3:v]crop=$RandomSubscribePos,scale=-1:300[subscribe]",
      "[main][logo]overlay=(main_w-overlay_w)/2:(H-h)/9[main2]",
      "[main2][subscribe]overlay=(main_w-overlay_w)/2:(H/3-h)*5.5;"
)
$filterShortsString = $filterShortsArray -join ';'
$Seconds = 3
$commShorts = "$FFMPEG_Exec -i `"$From`" -i `"$From`"  -i `"$FFMPEG_LogoFile`" -i `"$SubscribesMov`" -y -filter_complex `"$filterShortsString`" -c:v h264_amf -t $Seconds `"$StoryTo`""
$commShorts

$REcomm = '$progress = ""
'+ $commShorts + ' 2>&1 | ForEach-Object { if ($_ -match "frame=" -or $_ -match "time=" -or $_ -match "Output #") { Write-Host -NoNewline "`r* ? $progress" $progress = $_  }}'
Write-Output "*", "************************************", "*", "* ?? Сборка видеофайла"
Invoke-Expression $REcomm
Write-Output ""
Write-Output "* ?? Готово"