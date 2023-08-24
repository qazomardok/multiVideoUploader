newTitle = "";
switch (Title) {
    case "вести":
        // newTitle += "Выпуск";
        // newTitle += "АКТВ Вести";
        newTitle += "Летние новости";
        vkPlayListID = 50969644;
        break;

    case "неделя":
        // newTitle += "Выпуск";
        // newTitle += "АКТВ Вести";
        newTitle += "Неделя";
        vkPlayListID = 50969645;
        break; 
}

module.exports = newTitle