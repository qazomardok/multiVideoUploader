console.log("Starting NodeJS...");

const core = require('./app/app.js');

const videoFilePath = global.vars.file;
const apiUrl = 'https://api.ok.ru/fb.do';

function getUploadUrl(callback) {

  let Title = core.newTitle();
  const videoFileName = Title.newTitleExt;
  const videoFileSize = core.fs.statSync(videoFilePath).size;

  const params = {
    method: 'video.getUploadUrl',
    access_token: global.access.OK.okaccessToken,
    application_key: global.access.OK.okpublic_key,
    format: 'json',
    file_name: videoFileName,
    file_size: videoFileSize,
    gid: global.access.OK.groupID
  };

  // console.log(params);
  core.request.post({ url: apiUrl, form: params }, function (err, httpResponse, body) {
    if (err) {
      return console.error('core.request failed:', err);
    }
    const response = JSON.parse(body);
    const uploadUrl = response.upload_url;
    //console.log(response, uploadUrl);
    callback(uploadUrl);
  });
}

function uploadVideo(uploadUrl) {
  const formData = {
    data: core.fs.createReadStream(videoFilePath)
  };

  //let videoUrl = core.url.parse(uploadUrl);
  let videoId = core.querystring.parse(uploadUrl).id;
  let Title = core.newTitle();
  const videoFileName = Title.newTitleExt;

  console.log("Загружается видео " + videoFileName);


  core.request.post({ url: uploadUrl, formData: formData }, function (err, httpResponse, body) {
    if (err) {
      return console.error('upload failed:', err);
    }
if(body === "<retval>1</retval>") {
    console.log('Video uploaded successfully! Link: https://ok.ru/video/' + videoId);
} else {
  console.log('Video uploaded error', body);
}

    updateVideo(videoId);
  });
}

function updateVideo(videoId) {
  const params = {
    method: 'video.update',
    access_token: global.access.OK.okaccessToken,
    application_key: global.access.OK.okpublic_key,
    format: 'json',
    publish: true,
    vid: videoId
  };

  core.request.post({ url: apiUrl, form: params }, function (err, httpResponse, body) {
    if (err) {
      return console.error('core.request failed:', err);
    }
    let Title = core.newTitle()
    let msg = `📺 Видео "${Title.newTitle}" загружено в OK: https://ok.ru/video/${videoId}`
                console.log(`** ${msg}`);
                core.telegram(msg)
  });
}

getUploadUrl(uploadVideo);
