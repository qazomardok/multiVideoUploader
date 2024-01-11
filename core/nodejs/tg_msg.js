const core = require("./app/app.js");

let msg = vars.add;
core.telegram(msg);

console.log(`** ${msg}`);