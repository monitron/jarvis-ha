// alias j="node /path/to/j.js"
// j turn on living room light

const request = require('request');
const path = require('path');
const fs = require('fs');

const configFile = path.join(process.env.HOME, '.jarvis');

if(process.argv.length < 3) {
  console.log("No command specified.");
  return;
}

const command = process.argv.slice(2).join(' ');

fs.readFile(configFile, "utf8", function(err, data) {
  if(err) {
    console.log(err);
    console.log("Please create a .jarvis file in your home directory.");
    console.log("It must be valid JSON. The following parameters are allowed:");
    console.log();
    console.log("url      (required) - Jarvis server base URL ending in /");
    console.log("username (optional) - An HTTP Basic Authentication username");
    console.log("password (optional) - An HTTP Basic Authentication password");
  } else {
    const config = JSON.parse(data);
    var options = {
      url: config.url + "api/natural/" + encodeURIComponent(command),
      method: 'POST'
    };
    if(config.username) {
      options.auth = {user: config.username, pass: config.password};
    }
    callback = function(err, res, body) {
      if(err) {
        console.log(`Request failed: ${err}`);
      } else {
        const result = JSON.parse(body);
        console.log(result.response);
      }
    };

    request(options, callback);
  }
});


