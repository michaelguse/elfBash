var express = require('express');
var router = express.Router();

// Enable jsforce package for this app
const jsforce = require('jsforce');
var request = require('request');

// Imports the Google Cloud client library.
const Storage = require('@google-cloud/storage');

// Define OAuth2 client information
var oauth2 = new jsforce.OAuth2({
    loginUrl: process.env.LOGIN_URL,
    clientId: process.env.CLIENT_ID,
    clientSecret: process.env.CLIENT_SECRET_ID,
    redirectUri: `${process.env.REDIRECT_URI}`
});

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Daily Archive Router Home Page' });
});

router.get('/oauth2/auth', function(req, res) {
    console.log('Redirect URI: ' + oauth2.getAuthorizationUrl({});
    res.redirect(oauth2.getAuthorizationUrl({}));
});

router.get('/oauth2/callback', function(req,res) {
    var conn = new jsforce.Connection({ oauth2: oauth2 });
    var code = req.query.code;
    conn.authorize(code, function(err, userInfo) {
        if (err) { return console.error(err); }

        console.log('Access Token: ' + conn.accessToken);
        console.log('Instance URL: ' + conn.instanceUrl);
        console.log('User ID: ' + userInfo.id);
        console.log('Org ID: ' + userInfo.organizationId);

        req.session.accessToken = conn.accessToken;
        req.session.instanceUrl = conn.instanceUrl;
        res.redirect('/accounts'); 
    });
});

router.get('/accounts', function(req, res) {
    // if auth has not been set, redirect to index
    if (!req.session.accessToken || !req.session.instanceUrl) { res.redirect('/'); }

    var query = 'SELECT id, name FROM account LIMIT 10';
    // open connection with client's stored OAuth details
    var conn = new jsforce.Connection({
        accessToken: req.session.accessToken,
        instanceUrl: req.session.instanceUrl
    });

    conn.query(query, function(err, result) {
        if (err) {
            console.error(err);
            res.redirect('/');
        }
        res.render('accounts', {title: 'Accounts List', accounts: result.records});
    });
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
