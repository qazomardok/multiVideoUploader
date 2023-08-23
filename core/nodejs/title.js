
const path = require('path');

// global.vars = {}
// global.vars.file = "D:\\_ind\\_autovideos2\\files\Исходное\\05\\ВЕСТИ 20.06.mp4"

const fileExtension = path.extname(global.vars.file); // расширение файла
let TitleA = path.basename(global.vars.file).replace(fileExtension, "").toLowerCase().split(" ");
let newTitle = "";
PlayListID = 0

switch (TitleA[0]) {
    case "вести":
        // newTitle += "Выпуск";
        // newTitle += "АКТВ Вести";
        newTitle += "Летние новости";
        PlayListID = 50969644;
        break;

    case "неделя":
        // newTitle += "Выпуск";
        // newTitle += "АКТВ Вести";
        newTitle += "Неделя";
        PlayListID = 50969645;
        break;

    default:
        newTitle = path.basename(global.vars.file, fileExtension);
        delete (TitleA);
        TitleA = [newTitle];
        break;
}

delete (TitleA[0]);

let filteredArr = TitleA.filter(elem => elem !== null && elem !== "" && elem !== undefined);

if (filteredArr.length > 0) {


    filteredArr.forEach(function (element) {
        if (/\d/.test(element)) {
            newTitle += " (" + element + ")";
        } else {
            // process.exit(0);
            newTitle += " " + element.toLowerCase();
        }
    });
}

out = {
    "newTitleExt" : newTitle + fileExtension,
    "newTitle": newTitle,
    "PlayListID": PlayListID
}

// console.log(out)

module.exports = out