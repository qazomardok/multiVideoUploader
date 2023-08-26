if (!global.access.OK) {
    global.access.OK = {}
    rewriteOKAccess = true
}

if (!global.access.OK.okapp_id) {
    console.log(`Создайте Приложение в Одноклассники (https://apiok.ru/en/dev/app/create). Вам нужно будет получить права разработчиков (https://ok.ru/devaccess). В поле \"Список разрешённых redirect_uri\" введите \"http://localhost:${global.config.WebServerPort}\". Далее вам понадобятся права доступа VALUABLE_ACCESS, LONG_ACCESS_TOKEN, GROUP_CONTENT. А также VIDEO_CONTENT, которое можно получить только написав письмо администрации соцсети на email api-support@ok.ru.`)
    console.log("Введите ID приложения:")
    let AppID = core.readline.question("");
    global.access.OK.okapp_id = AppID
    rewriteOKAccess = true
}

if (!global.access.OK.okpublic_key) {
    console.log("Введите Публичный ключ приложения:")
    let Appclient_secret = core.readline.question("");
    global.access.OK.okpublic_key = Appclient_secret
    rewriteOKAccess = true
}

if (!global.access.OK.oksecret) {
    console.log("Введите Секретный ключ приложения:")
    let oksecret = core.readline.question("");
    global.access.OK.oksecret = oksecret
    rewriteOKAccess = true
}

if (!global.access.OK.groupID) {
    console.log("Введите ID группы в Одноклассники:")
    let groupID = core.readline.question("");
    global.access.OK.groupID = groupID
    rewriteOKAccess = true
}


if (!global.access.OK.access_token) {
    rewriteOKAccess = true
}