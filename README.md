# Автоматизация обработки видеофайлов
# Мультизагрузка, рассылка видео в соцсети

## Описание

Предназначен для автоматизации обработки видеофайлов с добавлением логотипа, созданием шортс, уведомлениями в Telegram, а также отправкой обработанных файлов в социальные сети (YouTube, ВКонтакте, OK и др.).

## Параметры

Скрипт поддерживает следующие параметры:

- **File**: путь к файлу для обработки (по умолчанию `"empty"`).
- **Notify**: отправка уведомлений в Telegram (по умолчанию `"False"`).
- **OnlyNotify**: только уведомления без обработки файлов (по умолчанию `"False"`).
- **AddLogo**: добавление логотипа на видео (по умолчанию `"False"`).
- **Convert**: конвертация видео (по умолчанию `"False"`).
- **Scale**: изменение масштаба видео (по умолчанию `"True"`).
- **SocialSend**: отправка файла в социальные сети (по умолчанию `"False"`).
- **isCron**: использование в планировщике заданий (по умолчанию `"False"`).
- **fromContext**: маркер о том, что скрипт был запущен из контекстного меню (по умолчанию `"False"`).
- **nmpUpdate**: обновление модулей (по умолчанию `"False"`).
- **Remove**: удаление файла после обработки (по умолчанию `"False"`).
- **AddHour**: добавить часы к задержке выполнения (по умолчанию `0`).
- **AddMin**: добавить минуты к задержке выполнения (по умолчанию `0`).
- **Server**: выбор одной конкретной социальной сети для отправки (`vk` `ok` `youtube` или `rutube`).
- **Text**: Описание видеофайла.
- **Reinstall**: переустановка конфигурации (по умолчанию `"False"`).
- **Stopnow**: немедленное завершение работы после окончания (по умолчанию `"False"`).

## Основные функции

- **Создание логов**: при каждом запуске создается лог-файл с командой, запущенной с параметрами.
- **Уведомления**: отправка уведомлений о статусе обработки в Telegram (если активировано).
- **Копирование и архивирование**: обработанный файл копируется или перемещается в заданные папки.
- **Добавление логотипа**: опционально накладывается логотип на видео.
- **Конвертация и масштабирование**: преобразование и изменение размеров видео.
- **Отправка в соцсети**: автоматическая загрузка файла на YouTube, ВКонтакте и Одноклассники.
- **Планировщик задач**: создание запланированных задач на отправку видео в социальные сети с задержкой.

## Примеры запуска
Примеры, создаваемых видео и shorts: https://rutube.ru/channel/13456/

### Пример обработки файла с добавлением логотипа и уведомлением в Telegram

```powershell
powershell.exe -File start.ps1 -File путь_к_файлу.mp4 -Notify True -AddLogo True -SocialSend True
```
Эта команда сделает следующее:
- Скопирует видеофайл в папку "Исходное"
- Возьмет файл logo.png
- Создаст 3 видео:
  - 1280x720 с наложенным в левый верхний угол логотипом
  - 1 шортс с первыми 15 секундами (для ВК)
  - 1 шортс с первыми 60 секундами
- Отправит 1-е видео в соцсети.
- Пришлёт уведомление в телеграмм с ссылками.


```powershell
powershell.exe -File start.ps1 -File путь_к_файлу.mp4 -AddHour 12 -Notify True -AddLogo True -SocialSend True 
```
Сделает всё тоже самое, но через планироващик заданий Windows
 - Создадутся 4 задачи в планировщике с запуском через 12 часов.


```powershell
powershell.exe -File start.ps1 -File путь_к_файлу.mp4 -AddHour 12 -Server vk -Notify True -AddLogo True -SocialSend True 
```
 - Создастся 1 задача (с ВК) в планировщике с запуском через 12 часов.

## Требования
- **PowerShell**: скрипт работает на PowerShell.
- **ffmpeg.exe**: для работы с видео. При отсутствии, он скачается.
- **NodeJS**: используется для отправки файлов в социальные сети.
- **Социальные сети**: требуется предварительная настройка авторизации для отправки файлов.
  - **vk**: нужно создать приложение ВК и иметь доступ к администрированию сообщества.
  - **youtube**: потребуется получить API ключ в консоли разработчика
  - **ok**: премодерация, потребуется создать приложение в ОК и запросить доступ к методу `video` через чат с техподдержкой.
  - **rutube**: премодерация, потребуется запросить доступ к API через чат с техподдержой.
- **Telegram Bot**: настроен бот для отправки уведомлений в Telegram.

## Установка
### Внесите изменения в `core/Config.json`:
- **WebServerAddress** и **WebServerPort**: используется для получения токена в ВК, как значение `redirect_uri` - добавьте этот url в настройки приложения (напр. `http://localhost:8081`)
- **FolderFiles**: корневая папка для обработки и хранения видео
  - В ней создадутся папки "Исходное", "Готовое" и др.
  - Для удобства работы, их можете подключить к программе "FolderMonitor" (скачается при первом запуске, но нужно будет её настроить).
    - В результате можно будет просто закидывать видео в папку и оно на автомате будет обрабатываться и рассылаться в соцсети.
- **FolderMonitorXML**: Исправьте обязательно. Укажите правильный путь в своей системе (появится после первого запуска "FolderMonitor").
### Разрешите выполнение сценариев
- В некоторых случаях может быть отключено выполнение скриптов. В этом случае запустите команду:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Запуск
Откройте терминал Windows и запустите start.ps1 с нужными аттрибутами
```console
PS C:\Users\username> cd H:\autovideo\multiVideoUploader
PS H:\autovideo\multiVideoUploader> .\start.ps1
```

## Замечания
- Скрипт требует прав администратора для корректной работы в некоторых режимах.
- После первого запуска или запуска с параметром -Reinstall, в контекстное меню windows на видеофайлах добавится меню "Обработка видео" с быстрым запуском команд "Отправить сейчас", "Обработать через 24 часа" и пр.
- Если папка для хранения логов не существует, она будет автоматически создана.

## Лицензия
Скрипт предоставляется "как есть" и предназначен для внутреннего использования. Не для продажи.