
const fs = require('fs');
const path = require('path');
const request = require('request');
const querystring = require('querystring');
const url = require('url');
const express = require('express'); 
const bodyParser = require('body-parser');
const opn = require('opn');
const readline = require('readline-sync'); 

function vars() {
    let vars = process.argv; // будет выведено значение "paramValue"

    let outvars = {
        "file": path.normalize(vars[2]),
        "workFolder": path.normalize(vars[3])
    }
    return outvars
}

global.vars = vars()

function config() {
    const filePath = global.vars["workFolder"] + '\\core\\Config.json';
    return require(filePath);
}

global.config = config()

function access() {
    const filePath = global.vars["workFolder"] + '\\core\\Access.json';
    return require(filePath);
}

global.access = access()

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
    const NewTitle = require(global.vars.workFolder + '\\core\\nodejs\\title.js');
    return NewTitle
}

module.exports = {
    config: config,
    access: access,
    vars: vars,
    telegram: telegram,
    update_access: update_access,
    request: request,
    fs: fs,
    path: path,
    readline:readline,
    querystring: querystring,
    express: express,
    bodyParser: bodyParser, 
    opn: opn,
    newTitle: getTitle,
    url: url
};
