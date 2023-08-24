console.log("Starting NodeJS...");

const core = require('./_core.js');
const { google } = require('googleapis');

let rewriteYoutubeAccess = false

if (!global.access.Youtube) {
    global.access.Youtube = {}
    rewriteYoutubeAccess = true
}

const fileCredentials = `${global.vars.workFolder}\\core\\credentials.json`;

if (!global.access.Youtube.client_id || !global.access.Youtube.client_secret) {
    // Проверка существования файла
    core.fs.access(fileCredentials, core.fs.constants.F_OK, (err) => {
        if (err) {
            console.warn(`Создайте проект в Google Cloud  (https://console.cloud.google.com/apis/dashboard?hl=ru).`)
            console.warn(`Перейдите в раздел "Credentials", создайте "OAuth 2.0 Client ID", в "Application type" выберите "Desktop App".`)
            console.warn(`Нажмите "Download Json", скачайте файл, назовите как "credentials.json" и положите его в директорию ${global.vars.workFolder}\\core\\`);
        }
        let Credentials = require(fileCredentials);
        if (Credentials.installed) {
            global.access.Youtube = Credentials.installed
            rewriteYoutubeAccess = true
        } else if (Credentials.web) {
            global.access.Youtube = Credentials.web
            rewriteYoutubeAccess = true
        }
        if (rewriteYoutubeAccess) {
            core.update_access(access);
            core.fs.unlink(fileCredentials, (err) => {
                if (err) {
                    console.error('Ошибка при удалении файла:', err);
                    return;
                }
                console.log(`Файл ${fileCredentials} успешно удален`);
            });
            console.log('Конфигурация обновлена.');
        }
    });
} else {

    console.log('Конфигурация ОК.');
    authorize(global.access.Youtube, uploadVideo);

    function authorize(credentials, callback) {

        const oAuth2Client = new google.auth.OAuth2(
            credentials.client_id,
            credentials.client_secret,
            `${credentials.redirect_uris[0]}:${global.config.WebServerPort}`);

        if (!global.access.Youtube.auth) {
            getNewToken(oAuth2Client, callback);
        } else {
            oAuth2Client.setCredentials(global.access.Youtube.auth);
            callback(oAuth2Client);
        }
    }

    function getNewToken(oAuth2Client, callback) {

        const authUrl = oAuth2Client.generateAuthUrl({
            access_type: 'offline',
            scope: ['https://www.googleapis.com/auth/youtube.upload'],
        });

        const localhost = core.express();

        localhost.get('/', (req, res) => {
            let code = req.query.code;
            res.send(`Окно можно закрыть.`);

            oAuth2Client.getToken(code, (err, token) => {
                webserver.close();
                console.log(`Сервер ${global.config.WebServerAddress}:${global.config.WebServerPort} выключён`);

                if (err) return console.error('Ошибка в получении токена', err);
                global.access.Youtube.auth = token
                core.update_access(access);
                oAuth2Client.setCredentials(token);
                callback(oAuth2Client);
            });
        });

        webserver = localhost.listen(global.config.WebServerPort, () => {
            console.log(`Сервер ${global.config.WebServerAddress}:${global.config.WebServerPort} включён`);
        });

        console.log('Авторизуйтесь в Google, используя ссылку:', authUrl);
        core.opn(authUrl);

    }

    function uploadVideo(auth) {
        const youtube = google.youtube({ version: 'v3', auth });

        const requestData = {
            part: 'snippet, status',
            requestBody: {
                snippet: {
                    title: core.newTitle().newTitle,
                    //description: 'Description of your video',
                    tags: ['АКТВ', 'КировоЧепецк', 'АКТВВести'],
                    categoryId: '25' // Новости и политика
                },
                status: {
                    privacyStatus: 'public',
                    selfDeclaredMadeForKids: true,
                    madeForKids: true,
                    license: "youtube",
                    embeddable: true,
                    publicStatsViewable: true
                }
            },
            media: {
                body: core.fs.createReadStream(global.vars.file)
            }
        };

        console.log(`Отправляем ${requestData.requestBody.snippet.title} в YouTube. Ждите...`);
        youtube.videos.insert(requestData, (err, res) => {
            if (err) return console.log(`Ошибка при отправке видео: ${err}`, res);
//https://www.youtube.com/watch?v=Hk2Bc-2YfIs&list=RDGMEMJQXQAmqrnmK1SEjY_rKBGAVMHk2Bc-2YfIs&start_radio=1
            let link = `https://www.youtube.com/watch?v=${res.data.id}`
            // let link = `https://studio.youtube.com/video/${res.data.id}/edit`
            let msg = `📺 Видео "${requestData.requestBody.snippet.title}" загружено в YouTube: ${link}`
            // console.log(res);
            console.log(`** ${msg}`);
            console.log(`** На канал "${res.data.snippet.channelTitle}" (https://www.youtube.com/channel/${res.data.snippet.channelId})`);
            console.log(`** Для смены канала, удалите раздел Youtube.auth в файле Access.json`);
            console.log(`** Редактировать видео: https://studio.youtube.com/video/${res.data.id}/edit`);
            core.telegram(msg)

            return res.data.id;

        });


    }

}

