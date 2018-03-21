var express = require('express');
var app = express();

app.set('port', (process.env.PORT || 5000));

app.get('/', function (req, res) {
  res.send('This will be the future home of the automation process for event log file extraction, archiving and upload to Einstein Analytics!');
});

app.listen(app.get('port'), function () {
  console.log('Node app is running on port', app.get('port'));
});