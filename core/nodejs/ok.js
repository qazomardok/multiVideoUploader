if (!global.access.OK) {
    global.access.OK = {}
    rewriteOKAccess = true
}

if (!global.access.OK.okapp_id) {
    console.log(`�������� ���������� � ������������� (https://apiok.ru/en/dev/app/create). ��� ����� ����� �������� ����� ������������� (https://ok.ru/devaccess). � ���� \"������ ����������� redirect_uri\" ������� \"http://localhost:${global.config.WebServerPort}\". ����� ��� ����������� ����� ������� VALUABLE_ACCESS, LONG_ACCESS_TOKEN, GROUP_CONTENT. � ����� VIDEO_CONTENT, ������� ����� �������� ������ ������� ������ ������������� ������� �� email api-support@ok.ru.`)
    console.log("������� ID ����������:")
    let AppID = core.readline.question("");
    global.access.OK.okapp_id = AppID
    rewriteOKAccess = true
}

if (!global.access.OK.okpublic_key) {
    console.log("������� ��������� ���� ����������:")
    let Appclient_secret = core.readline.question("");
    global.access.OK.okpublic_key = Appclient_secret
    rewriteOKAccess = true
}

if (!global.access.OK.oksecret) {
    console.log("������� ��������� ���� ����������:")
    let oksecret = core.readline.question("");
    global.access.OK.oksecret = oksecret
    rewriteOKAccess = true
}

if (!global.access.OK.groupID) {
    console.log("������� ID ������ � �������������:")
    let groupID = core.readline.question("");
    global.access.OK.groupID = groupID
    rewriteOKAccess = true
}


if (!global.access.OK.access_token) {
    rewriteOKAccess = true
}