var express = require('express');
var router = express.Router();

// Enable jsforce package for this app
const jsforce = require('jsforce');

router.get('/', function(req,res) {
    res.render('index', { title: 'Upload Module' });
});

router.post('/', function(req,res) {

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

module.exports = router;