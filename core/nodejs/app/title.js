newTitle = "";
switch (Title.toLowerCase()) {
  case "вести":
    // newTitle += "Выпуск";
    newTitle += "АКТВ Вести";
    poster = "vesti.png";
    // newTitle += "Летние новости";
    vkPlayListID = 50969644;
    break;
case "story60sec-вести":
  newTitle += "АКТВ Вести Shorts";
  vkPlayListID = 50969644;
    break;
case "story-неделя":
  newTitle += "Неделя Shorts";
  vkPlayListID = 50969644;
    break;
  case "неделя":
    // newTitle += "Выпуск";
    // newTitle += "АКТВ Вести";
    poster = "nedelya.png";
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
  vkPlayListID: vkPlayListID,
};

module.exports = out;
