var createError = require('http-errors');
var express = require('express');
var session = require('express-session');
var path = require('path');
var logger = require('morgan');

var archiveRouter = require('./routes/archive');

var app = express();

// Get port from environment and store in Express
app.set('port', (process.env.PORT || 5050));

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(session({secret: 'monitor marble', resave: false, saveUninitialized: true}));
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', archiveRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

// Bind app to port
app.listen(app.get('port'), function () {
  console.log('Node app is running on port', app.get('port'));
});

