console.log("Starting NodeJS...");

const core = require('./app/app.js');

let rewriteTGAccess = false

const TelegramBot = require('node-telegram-bot-api');

if (!global.access.VK) {
    global.access.VK = {}
    rewriteVKAccess = true
}



async function sendVideoToTelegram() {


    // Формируем API-запрос для отправки видео
    const url = `https://api.telegram.org/bot${global.access.Telegram.Token}/sendVideo`;

    const formData = {
        chat_id: global.access.Telegram.ChatIDPublish,
        video: core.fs.createReadStream(global.vars.file),
    };

    core.fs.stat(global.vars.file, (err, stats) => {

    let fsize = 0;
    let fsizeMB = 0;

        if (err) {
            console.log(`File doesn't exist.`);
        } else {
            fsize = stats.size;
            fsizeMB = Math.round(fsize / (1024 * 1024));
        }

        if (fsize >= global.access.Telegram.FileLimit) {
            console.log(`Файл слишком большой (${fsizeMB} MB)`);
            process.exit(0);
        }

        Title = core.newTitle()

        core.request.post({ url, formData }, (err, response, body) => {

            const data = JSON.parse(body);
            if ((err) || (data.ok === false)) {

                let msg = `Видео "${Title.newTitle}" не загружено в Телеграмм: ${data.description}`
                console.log(`** ${msg}`);
                core.telegram(msg)

            } else {
                const data = JSON.parse(body);
                console.log(data);
            }
        });

    });
}

sendVideoToTelegram();

/*





 
const bot = new TelegramBot(global.access.Telegram.Token, {polling: true});

let Title = core.newTitle()
console.log(`${global.vars.file} будет загружен в Телеграм`)
console.log(`под именем "${Title.newTitle}"`)

// const video = core.fs.createReadStream(global.vars.file);

// bot.sendVideo(global.access.Telegram.ChatIDPublish, "https://service.aktv.ru/vesti25.07.mp4");
// bot.sendVideo(global.access.Telegram.ChatIDPublish, video);


const file = core.fs.createReadStream(global.vars.file);
let o = bot.sendDocument(global.access.Telegram.ChatIDPublish, file, {}, {filename: global.vars.file, timeout:100000, contentType: 'video/'+(core.path.extname(global.vars.file).slice(1))});
console.log(o);
*/