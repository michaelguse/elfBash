// Enable jsforce package for this app
const jsforce = require('jsforce');

// Configure express to be used for this app
var express = require('express');
var app = express();

app.set('port', (process.env.PORT || 5000));

// Configure routes for this app
app.get('/', function (req, res) {
  res.send('This will be the future home of the automation process for event log file extraction, archiving and upload to Einstein Analytics!');
});

app.get('/oauth2/auth', function(req, res) {
    const oauth2 = new jsforce.OAuth2({
        loginUrl: process.env.LOGIN_URL,
        clientId: process.env.CLIENT_ID,
        clientSecret: process.env.CLIENT_SECRET_ID,
        redirectUri: `${req.protocol}://${req.get('host')}/${process.env.REDIRECT_URI}`
    });
    res.redirect(oauth2.getAuthorizationUrl({}));
});
 
app.get('/getAccessToken', function(req,res) {
    const oauth2 = new jsforce.OAuth2({
        loginUrl : process.env.LOGIN_URL,
        clientId: process.env.CLIENT_ID,
        clientSecret: process.env.CLIENT_SECRET_ID,
        redirectUri: `${req.protocol}://${req.get('host')}/${process.env.REDIRECT_URI}`
    });
    const conn = new jsforce.Connection({ oauth2 : oauth2 });
    conn.authorize(req.query.code, function(err, userInfo) {
      if (err) {
        return console.error(err);
      }
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
});

// Bind app to port
app.listen(app.get('port'), function () {
  console.log('Node app is running on port', app.get('port'));
});