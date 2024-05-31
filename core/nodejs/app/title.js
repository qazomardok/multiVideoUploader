newTitle = "";
switch (Title.toLowerCase()) {
  case "вести":
    case "ВЕСТИ":
    // newTitle += "Выпуск";
    //newTitle += "АКТВ Вести";
    newTitle += "Летние новости";
    vkPlayListID = 50969644;
    break;

    case "неделя":
      case "НЕДЕЛЯ":
    // newTitle += "Выпуск";
    // newTitle += "АКТВ Вести";
    newTitle += "Неделя";
    vkPlayListID = 50969645;
    break;
  case "посмотрим":
    // newTitle += "Выпуск";
    // newTitle += "АКТВ Вести";
    newTitle += "Что посмотреть в сети АКТВ?";
    vkPlayListID = 50969647;
    break;

  default:
    //newTitle += Title.charAt(0).toUpperCase() + Title.slice(1);
    newTitle += Title;
    vkPlayListID = 50969646;
    break;
}

var out = {
  newTitle: newTitle,
  vkPlayListID: vkPlayListID
}

module.exports = out;
