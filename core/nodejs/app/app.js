const fs = require("fs");
const path = require("path");
const request = require("request");
const querystring = require("querystring");
const url = require("url");
const express = require("express");
const bodyParser = require("body-parser");
const opn = require("opn");
const readline = require("readline-sync");
const { google } = require("googleapis");
const formdata = require('form-data');
const ftp = require('basic-ftp');

function vars() {
  let vars = process.argv; // будет выведено значение "paramValue"
  // console.log("VARS:", vars);
  let outvars = {
    file: path.normalize(vars[2]),
    workFolder: path.normalize(vars[3]),
    description: path.normalize(vars[4] || ""),
    add: vars[5] || "",
  };
  // console.log("outvars:", outvars);
  return outvars;
}

function config() {
  const filePath = global.vars["workFolder"] + "\\core\\Config.json";
  return require(filePath);
}

function access() {
  const filePath = global.vars["workFolder"] + "\\core\\Access.json";
  return require(filePath);
}

function update_access(newconfig) {
  let updatedConfig = JSON.stringify(newconfig, null, 2);
  fs.writeFileSync(
    global.vars["workFolder"] + "\\core\\Access.json",
    updatedConfig
  );
}

function telegram($message) {
  request.post(
    {
      url:
        "https://api.telegram.org/bot" +
        global.access.Telegram.Token +
        "/sendMessage?chat_id=" +
        global.access.Telegram.ChatID +
        "&text=" +
        encodeURIComponent($message) +
        "",
    },
    function (error, response, body) {
      if (error) {
        console.error(error, response);
      }
    }
  );
}

function getTitle() {
  const fileExtension = path.extname(global.vars.file);
  //let TitleA = path.basename(global.vars.file).replace(fileExtension, "").toLowerCase().split(" ");
  let TitleA = path
    .basename(global.vars.file)
    .replace(fileExtension, "")
    .split(" ");
  let newTitleR = "";
  PlayListID = 0;
  Title = TitleA[0];

  var newTitleA = require(global.vars.workFolder + "\\core\\nodejs\\app\\title.js");

  newTitleR = newTitleA.newTitle;
  if (newTitleA.vkPlayListID) {
    PlayListID = newTitleA.vkPlayListID;
  }
// console.log(newTitleA);
// process.exit();
  delete TitleA[0];
  if (newTitleR !== "") {
    let filteredArr = TitleA.filter(
      (elem) => elem !== null && elem !== "" && elem !== undefined
    );

    if (filteredArr.length > 0) {
      filteredArr.forEach(function (element) {
        if (/\d/.test(element)) {
          newTitleR += " (" + element + ")";
        } else {
          // process.exit(0);
          //newTitleR += " " + element.toLowerCase();
          newTitleR += " " + element;
        }

      });
    }
  } else {
    newTitleR = path.basename(global.vars.file, fileExtension);
  }
  newTitleR = newTitleR.replace(/\_\d+\)/g, ")");
  out = {
    newTitleExt: newTitleR + fileExtension,
    newTitle: newTitleR,
    PlayListID: vkPlayListID,
  };

  return out;
}

function transliterate(text) {
  const cyrillicToLatinMap = {
      "А": "A", "Б": "B", "В": "V", "Г": "G", "Д": "D", "Е": "E", "Ё": "E", "Ж": "Zh", "З": "Z", "И": "I", "Й": "Y",
      "К": "K", "Л": "L", "М": "M", "Н": "N", "О": "O", "П": "P", "Р": "R", "С": "S", "Т": "T", "У": "U", "Ф": "F",
      "Х": "Kh", "Ц": "Ts", "Ч": "Ch", "Ш": "Sh", "Щ": "Shch", "Ы": "Y", "Э": "E", "Ю": "Yu", "Я": "Ya",
      "а": "a", "б": "b", "в": "v", "г": "g", "д": "d", "е": "e", "ё": "e", "ж": "zh", "з": "z", "и": "i", "й": "y",
      "к": "k", "л": "l", "м": "m", "н": "n", "о": "o", "п": "p", "р": "r", "с": "s", "т": "t", "у": "u", "ф": "f",
      "х": "kh", "ц": "ts", "ч": "ch", "ш": "sh", "щ": "shch", "ы": "y", "э": "e", "ю": "yu", "я": "ya"
  };

  return text.replace(/[А-яёЁ]/g, char => cyrillicToLatinMap[char] || char);
}

global.vars = vars();
global.config = config();
global.access = access();

module.exports = {
  config: config,
  access: access,
  vars: vars,
  transliterate: transliterate,
  telegram: telegram,
  update_access: update_access,
  request: request,
  fs: fs,
  path: path,
  readline: readline,
  querystring: querystring,
  express: express,
  bodyParser: bodyParser,
  opn: opn,
  newTitle: getTitle,
  url: url,
  google: google,
  formdata: formdata,
  ftp: ftp
};
