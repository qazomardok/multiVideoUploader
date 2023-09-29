console.log("Starting NodeJS...");
const core = require('./app/app.js');

let rewriteVKAccess = false

if (!global.access.VK) {
    global.access.VK = {}
    rewriteVKAccess = true
}

if (!global.access.VK.AppID) {
    console.log(`Создайте приложение в ВКонтакте, указав платформу \"Сайт\". В поле \"Адрес сайта\" и \"Базовый домен\" введите \"localhost:${global.config.WebServerPort}\" (https://vk.com/apps?act=manage)`)
    console.log("Введите ID приложения:")
    let AppID = core.readline.question("");
    global.access.VK.AppID = AppID
    rewriteVKAccess = true
}

if (!global.access.VK.Appclient_secret) {
    console.log("Введите Защищённый ключ приложения:")
    let Appclient_secret = core.readline.question("");
    global.access.VK.Appclient_secret = Appclient_secret
    rewriteVKAccess = true
}

if (!global.access.VK.Group_ID) {
    console.log("Введите ID группы ВКонтакте:")
    let Group_ID = core.readline.question("");
    global.access.VK.Group_ID = Group_ID
    rewriteVKAccess = true
}
if (!global.access.VK.access_token) {
    rewriteVKAccess = true
}

if (rewriteVKAccess === true) {
    core.update_access(access);


    const params = {
        method: "authorize",
        query: {
            client_id: global.access.VK.AppID,
            scope: "video,offline",
            client_secret: global.access.VK.Appclient_secret,
            redirect_uri: `${global.config.WebServerAddress}:${global.config.WebServerPort}`,
            expires_in: 0,
            response_type: "token",
            v: "5.131"
        }
    }

    const authUrl = `https://oauth.vk.com/${params.method}?${core.querystring.stringify(params.query)}`;
    const localhost = core.express();

    webserver = localhost.listen(global.config.WebServerPort, () => {
        console.log(`Сервер ${global.config.WebServerAddress}:${global.config.WebServerPort} включён`);
    });

    localhost.use(core.bodyParser.urlencoded({ extended: true }));

    localhost.post('/', function (request, response) {

        global.access.VK.user_id = request.body.user_id
        global.access.VK.expires_in = request.body.expires_in

        const parsedQuery = core.querystring.parse((request.body.query).split("#")[1]);
        global.access.VK.access_token = parsedQuery.access_token;
        core.update_access(access);
        response.send("OK");

        webserver.close();
        console.log("Сервер выключен");
    });

    localhost.get('/', (req, res) => {
        res.send(`Окно можно закрыть.<script type="text/javascript">document.addEventListener("DOMContentLoaded", function(event) {
        var http = new XMLHttpRequest();
        var params = 'query='+window.location.href;
        http.open('POST', '${global.config.WebServerAddress}:${global.config.WebServerPort}', true);
        http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        http.onreadystatechange = function() {//Call a function when the state changes.
            if(http.readyState == 4 && http.status == 200) {
                alert("Это окно можно закрыть");
                window.close(); return false;
            }
        }
        http.send(params);
      });</script>`);
    });

    console.log('Авторизуйтесь в ВКонтакте, используя ссылку:', authUrl);
    core.opn(authUrl);
} else {
    console.log("Конфигурация ОК.")
    runVKupload()
}


function runVKupload() {

    let Title = core.newTitle()
    console.log(`${global.vars.file} будет загружен в ВК`)
    console.log(`под именем "${Title.newTitle}"`)
    // process.exit(0);
    const video_file = core.fs.createReadStream(global.vars.file);

    const upload_url_options = {
        url: 'https://api.vk.com/method/video.save',
        qs: {
            group_id: global.access.VK.Group_ID,
            access_token: global.access.VK.access_token,
            name: Title.newTitle,
            album_id: Title.vkPlayListID,
            v: 5.95
        },
        json: true,
    };

    core.request.get(upload_url_options, function (error, response, body) {

        const video_data = body.response;
        const upload_url = video_data.upload_url;
        const video_id = video_data.video_id;
        const video_upload_options = {
            url: upload_url,
            formData: {
                video_file: video_file,
            },
            json: true,
        };

        let dat = {
            group_id: global.access.VK.Group_ID,
            access_token: global.access.VK.access_token,
            video_id: video_id,
            owner_id: global.access.VK.user_id,
            name: Title.newTitle,
            album_id: Title.vkPlayListID,
            description: global.vars.description,
            wallpost: (global.vars.description === "") ? 0 : 1,
            v: 5.95
        };


        core.request.post(video_upload_options, function (error, response, body) {
            const video_save_options = {
                url: 'https://api.vk.com/method/video.save',
                qs: dat,
                json: true,
            };
            core.request.get(video_save_options, function (error, response, body) {
                let link = `https://vk.com/video${body.response.owner_id}_${body.response.video_id}`
                let msg = `📺 Видео "${Title.newTitle}" загружено в ВК: ${link}`
                console.log(`** ${msg}`);
                core.telegram(msg)
            });
        }).on('error', function (err) {
            console.error(err);
        }).on('end', function () {
            console.log('Загрузка завершена');
        });
    });

}