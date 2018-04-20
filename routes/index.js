var express = require('express');
var router = express.Router();

// Enable jsforce package for this app
const jsforce = require('jsforce');
var request = require('request');

// Imports the Google Cloud client library.
const Storage = require('@google-cloud/storage');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/oauth2/auth', function(req, res) {
  const oauth2 = new jsforce.OAuth2({
      loginUrl: process.env.LOGIN_URL,
      clientId: process.env.CLIENT_ID,
      clientSecret: process.env.CLIENT_SECRET_ID,
      redirectUri: `${req.protocol}://${req.get('host')}/${process.env.REDIRECT_URI}`
  });
  res.redirect(oauth2.getAuthorizationUrl({}));
});

router.get('/getAccessToken', function(req,res) {
  const oauth2 = new jsforce.OAuth2({
      loginUrl: process.env.LOGIN_URL,
      clientId: process.env.CLIENT_ID,
      clientSecret: process.env.CLIENT_SECRET_ID,
      redirectUri: `${req.protocol}://${req.get('host')}/${process.env.REDIRECT_URI}`
  });

  const conn = new jsforce.Connection({ oauth2 : oauth2 });
  conn.authorize(req.query.code, function(err, userInfo) {
      if (err) { return console.error(err); }

      const conn2 = new jsforce.Connection({
          instanceUrl : conn.instanceUrl,
          accessToken : conn.accessToken
      });

      conn2.identity(function(err, res) {
          if (err) { return console.error(err); }
          console.log("user ID: " + res.user_id);
          console.log("organization ID: " + res.organization_id);
          console.log("username: " + res.username);
          console.log("display name: " + res.display_name);
      });
  });
  res.send('getAccessToken page completed successfully!');
});

router.get('/dailyArchiveToGoogle', function() {
    
    var formData = {
        // query string
        q: 'Select+Id+,+EventType+,+LogDate,+Sequence+From+EventLogFile+Where+LogDate+%3E=+YESTERDAY',
        // Pass data for Authentication Bearer token and headers
        auth: {
            'bearer': accessToken
        },
        headers: {
            'X-PrettyPrint': 1
        }
    };

    request({uri: 'https://cs80.salesforce.com/services/data/v42.0/query', 
            method: "POST",
            formData: formData
        },
        function (error, response, body) {
            console.log('error:', error); // Print the error if one occurred
            console.log('statusCode:', response && response.statusCode); // Print the response status code if a response was received
            console.log('body:', body); // Print the response body.
            res.render('content', { res_content: body});
    });
    
    //.pipe(fs.createWriteStream('doodle.png'));

    // Creates a client
    //const storage = new Storage();
    //fs.createReadStream('file.json').pipe(request.put('http://mysite.com/obj.json'))    
});

module.exports = router;
