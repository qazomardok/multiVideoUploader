
const fs = require('fs');
const path = require('path');
const request = require('request');
const querystring = require('querystring');
const url = require('url');
const express = require('express');
const bodyParser = require('body-parser');
const opn = require('opn');
const readline = require('readline-sync');
const googleapis = require('googleapis');
function vars() {
    let vars = process.argv; // будет выведено значение "paramValue"

    let outvars = {
        "file": path.normalize(vars[2]),
        "workFolder": path.normalize(vars[3])
    }
    return outvars
}

function config() {
    const filePath = global.vars["workFolder"] + '\\core\\Config.json';
    return require(filePath);
}

function access() {
    const filePath = global.vars["workFolder"] + '\\core\\Access.json';
    return require(filePath);
}

function update_access(newconfig) {
    let updatedConfig = JSON.stringify(newconfig, null, 2);
    fs.writeFileSync(global.vars["workFolder"] + '\\core\\Access.json', updatedConfig);
}

function telegram($message) {
    request.post({
        url: "https://api.telegram.org/bot" + global.access.Telegram.Token + "/sendMessage?chat_id=" + global.access.Telegram.ChatID + "&text=" + encodeURIComponent($message) + "",
    }, function (error, response, body) {
        if (error) {
            console.error(error, response);
        }
    });
}

function getTitle() {

    const fileExtension = path.extname(global.vars.file);
    let TitleA = path.basename(global.vars.file).replace(fileExtension, "").toLowerCase().split(" ");
    let newTitleR = "";
    PlayListID = 0;
    Title = TitleA[0]; 

    newTitleR = require(global.vars.workFolder + '\\core\\nodejs\\app\\title.js');

    delete (TitleA[0]);
if(newTitleR !== "") {
    let filteredArr = TitleA.filter(elem => elem !== null && elem !== "" && elem !== undefined);

    if (filteredArr.length > 0) {
        filteredArr.forEach(function (element) {
            if (/\d/.test(element)) {
                newTitleR += " (" + element + ")";
            } else {
                // process.exit(0);
                newTitleR += " " + element.toLowerCase();
            }
        });
    }
} else {
    newTitleR = path.basename(global.vars.file, fileExtension);
    
}
    out = {
        "newTitleExt": newTitleR + fileExtension,
        "newTitle": newTitleR,
        "PlayListID": vkPlayListID
    }

    return out
}

global.vars = vars()
global.config = config()
global.access = access()

module.exports = {
    config: config,
    access: access,
    vars: vars,
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
    googleapis: googleapis
};
