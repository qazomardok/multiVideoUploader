console.log("Starting NodeJS...");
const core = require("./app/app.js");

let rewriteRUTUBEAccess = false;

if (!global.access.RUTUBE) {
  global.access.RUTUBE = {};
  rewriteRUTUBEAccess = true;
}

if (!global.access.RUTUBE.ftp_server) {
  console.log("Введите IP FTP сервера:");
  let ftp_server = core.readline.question("");
  global.access.RUTUBE.ftp_server = ftp_server;
  rewriteRUTUBEAccess = true;
}

if (!global.access.RUTUBE.ftp_login) {
  console.log("Введите логин от FTP:");
  let ftp_login = core.readline.question("");
  global.access.RUTUBE.ftp_login = ftp_login;
  rewriteRUTUBEAccess = true;
}

if (!global.access.RUTUBE.ftp_password) {
  console.log("Введите пароль от FTP:");
  let ftp_password = core.readline.question("");
  global.access.RUTUBE.ftp_password = ftp_password;
  rewriteRUTUBEAccess = true;
}

if (!global.access.RUTUBE.ftp_path) {
  console.log("Введите путь в FTP для загрузки файлов:");
  console.log("* без слеша в конце");
  let ftp_path = core.readline.question("");
  global.access.RUTUBE.ftp_path = ftp_path;
  rewriteRUTUBEAccess = true;
}

if (!global.access.RUTUBE.ftp_site_url) {
  console.log("Введите URL сайта, связанный с путем FTP:");
  console.log("* без слеша в конце");
  let ftp_site_url = core.readline.question("");
  global.access.RUTUBE.ftp_site_url = ftp_site_url;
  rewriteRUTUBEAccess = true;
}

if (!global.access.RUTUBE.callback_url) {
  console.log("Введите URL для получения положительных ответов от RUTUBE:");
  let callback_url = core.readline.question("");
  global.access.RUTUBE.callback_url = callback_url;
  rewriteRUTUBEAccess = true;
}

if (!global.access.RUTUBE.errback_url) {
  console.log("Введите URL для получения ответов с ошибками от RUTUBE:");
  let errback_url = core.readline.question("");
  global.access.RUTUBE.errback_url = errback_url;
  rewriteRUTUBEAccess = true;
}

if (!global.access.RUTUBE.access_token) {
  if (!global.access.RUTUBE.username) {
    console.log("Введите логин от Rutube:");
    var RUTUBEusername = core.readline.question("");
    // global.access.RUTUBE.Appclient_secret = Appclient_secret
    // rewriteRUTUBEAccess = true
  }

  if (!global.access.RUTUBE.password) {
    console.log("Введите пароль от Rutube:");
    var RUTUBEpassword = core.readline.question("");
    // global.access.RUTUBE.Group_ID = Group_ID
    // rewriteRUTUBEAccess = true
  }

  const authparams = {
    username: RUTUBEusername,
    password: RUTUBEpassword,
  };

  const authUrl = `https://rutube.ru/api/accounts/token_auth/`;

  //   authparams.username = "tvgazeta@aktv.ru";
  //   authparams.password = "84686PK";

  core.request.put(
    {
      url: authUrl,
      form: authparams,
    },
    function (error, response, body) {
      if (error) {
        return console.error("core.request failed:", error);
      }
      const RUbody = JSON.parse(body);

      if (RUbody && RUbody.token) {
        global.access.RUTUBE.access_token = RUbody.token;
        global.access.RUTUBE.user_id = RUbody.userid;
        console.log("Конфигурация ОК.");
        core.update_access(access);
      } else {
        console.log(RUbody);
        console.warn("Неверный логин или пароль.");
        return;
      }
    }
  );

  rewriteRUTUBEAccess = true;

}

if (rewriteRUTUBEAccess === true) {
  core.update_access(access);
} else {
  console.log("Конфигурация ОК.");

}




/** ОТПРАВЛЯЕМ ФАЙЛ ПО FTP **/
uploadFileToFtp();



async function uploadFileToFtp() {
    const client = new core.ftp.Client();
    client.ftp.verbose = true; // Включаем вывод логов

    try {
        // Подключаемся к FTP-серверу
        await client.access({
            host: global.access.RUTUBE.ftp_server,
            user: global.access.RUTUBE.ftp_login,
            password: global.access.RUTUBE.ftp_password,
            secure: false // Установите true, если соединение должно быть защищенным
        });

        console.log("Подключение к FTP установлено");
        // let fileName = core.transliterate(core.newTitle().newTitleExt.replace(/\s+/g, '_'));
        let fileName = core.newTitle().newTitleExt.replace(/\s+/g, '_');


        // Отправляем файл на сервер
        await client.uploadFrom(global.vars.file, global.access.RUTUBE.ftp_path + "/" + fileName);

        let FILEURL = global.access.RUTUBE.ftp_site_url + "/" + fileName;
        console.log("Файл успешно загружен на FTP");
        console.log("URL: " + FILEURL);

        runRUTUBEupload(FILEURL);

    } catch (err) {
        console.error("Ошибка при загрузке файла на FTP:", err);
    } finally {
        // Закрываем соединение с сервером
        client.close();
    }
}

function runRUTUBEupload(FILEURL) {
    const uploadUrl = "http://rutube.ru/api/video/";
    // https://tele.aktv.ru/auto_videos/callback_url.php
    // https://tele.aktv.ru/auto_videos/errback_url.php
    const options = {
      url: uploadUrl,
      method: "POST",
      headers: {
        "Authorization": `Token ${global.access.RUTUBE.access_token}`,
      },
      form: {
        url: FILEURL,
        callback_url: global.access.RUTUBE.callback_url, // Укажите реальный URL для callback
        errback_url: global.access.RUTUBE.errback_url, // Укажите реальный URL для errback
        title: core.newTitle().newTitle, // Название видео
        description: global.vars.description || "", // Описание видео
        is_hidden: false, // Приватность (false означает публичное видео)
        category_id: 8, // ID категории видео
        author: global.access.RUTUBE.user_id, // ID пользователя Rutube
      },
    };

    core.request(options, function (error, response, body) {
      if (error) {
        console.error("Ошибка загрузки на Rutube:", error);
        return;
      }
    let video = JSON.parse(body);

      if (video.video_id) {

        let videoId = video.video_id;

        let link = `http://rutube.ru/video/${videoId}`;
        let msg = `📺 Видео "${core.newTitle().newTitle}" загружено в RUTUBE: ${link}`;
        core.telegram(msg);
        console.log("Видео загружено на Rutube. Ответ:", body);

      } else {
        let msg = `📺 ОШИБКА загрузки "${core.newTitle().newTitle}" в RUTUBE: ${body}`;
        core.telegram(msg);
        console.error("Ошибка загрузки на Rutube. Ответ:", body);
        return;
      }







    });
  }



function runRUTUBEupload2() {
    return;




  const form = new core.formdata();
  let Title = core.newTitle();

  // Добавление данных в форму
  form.append("file", core.fs.createReadStream(global.vars.file));
  form.append("title", Title.newTitle);
  form.append("description", "");
  form.append("category_id", 8);

  // Выполнение запроса через core.request
  const requestOptions = {
    url: "https://rutube.ru/api/video/",
    method: "POST",
    headers: {
      Authorization: `Token ${global.access.RUTUBE.access_token}`,
      ...form.getHeaders(), // Получаем заголовки из form-data
    },
    body: form, // Передаем сам объект form-data в теле запроса
  };

  core.request(requestOptions, (error, response, body) => {
    if (error) {
      return console.error("Ошибка при загрузке видео:", error);
    }

    if (response.statusCode === 200) {
      const responseBody = JSON.parse(body);
      console.log("Видео успешно загружено! ID видео:", responseBody.video_id);
    } else {
      console.error("Ошибка загрузки:", body);
    }
  });

  return;

  console.log(`${global.vars.file} будет загружен в RUTUBE`);
  console.log(`под именем "${Title.newTitle}"`);
  // console.log(`в плейлист №"${Title.PlayListID}"`)
  // process.exit(0);
  const video_file = core.fs.createReadStream(global.vars.file);

  return Title;

  const upload_url_options = {
    url: "https://api.RUTUBE.com/method/video.save",
    qs: {
      group_id: global.access.RUTUBE.Group_ID,
      access_token: global.access.RUTUBE.access_token,
      name: Title.newTitle,
      album_id: Title.PlayListID,
      // wallpost: (global.vars.description === "") ? 0 : 1,
      v: 5.95,
    },
    json: true,
  };
  console.log(`Title:`, Title);
  console.log(`upload_url_options:`, upload_url_options);

  // process.exit()

  core.request
    .get(upload_url_options, function (error, response, body) {
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
        group_id: global.access.RUTUBE.Group_ID,
        access_token: global.access.RUTUBE.access_token,
        video_id: video_id,
        owner_id: global.access.RUTUBE.user_id,
        name: Title.newTitle,
        album_id: Title.PlayListID,
        description: global.vars.description,
        //    wallpost: (global.vars.description === "") ? 0 : 1,
        v: 5.95,
      };

      core.request
        .post(video_upload_options, function (error, response, body) {
          const video_save_options = {
            url: "https://api.RUTUBE.com/method/video.save",
            qs: dat,
            json: true,
          };

          core.request.get(video_save_options, function (error, response, body) {
            // console.log("!!!!!!", error, response, body);
            let link = `https://RUTUBE.com/video${body.response.owner_id}_${body.response.video_id}`;
            let msg = `📺 Видео "${Title.newTitle}" загружено в ВК: ${link}`;
            console.log(`** ${msg}`);
            core.telegram(msg);
          });
        })
        .on("error", function (err) {
          console.error(err, "Ошибка загрузки");
        })
        .on("end", function () {
          console.log("Загрузка завершена");
        });
    })
    .on("error", function (err, data) {
      console.error(err, data, "Ошибка отправки");
    })
    .on("end", function () {
      console.log("Отправка завершена");
    });
}
