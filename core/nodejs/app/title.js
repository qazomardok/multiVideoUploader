newTitle = "";
switch (Title) {
  case "вести":
    // newTitle += "Выпуск";
    newTitle += "АКТВ Вести";
    //newTitle += "Летние новости";
    vkPlayListID = 50969644;
    break;

    case "неделя":
        // newTitle += "Выпуск";
        // newTitle += "АКТВ Вести";
        newTitle += "Неделя";
        vkPlayListID = 50969645;
        break;
        case "посмотрим":
          // newTitle += "Выпуск";
          // newTitle += "АКТВ Вести";
          newTitle += "Что посмотреть?";
          vkPlayListID = 50969645;
          break;

  default:
    newTitle += Title.charAt(0).toUpperCase() + Title.slice(1);
    vkPlayListID = 50969645;
    break;
}

module.exports = newTitle;
