// Generated by CoffeeScript 1.7.1
(function() {
  var Chatroom, app, bp, cs, http, io;

  cs = require('coffee-script/register');

  app = require('express')();

  bp = require('body-parser');

  http = require('http').Server(app);

  io = require('socket.io')(http);

  Chatroom = require('./chatroom').Chatroom;

  app.use(bp.json());

  app.get('/', function(req, res) {
    return res.sendfile('assets/html/index.html');
  });

  app.get('/application.js', function(req, res) {
    return res.sendfile('assets/javascript/application.js');
  });

  app.get('/rooms/:name', function(req, res) {
    return console.log('whoa, something happened!');
  });

  app.post('/rooms', function(req, res) {
    console.log(req.param("room"));
    return res.json({
      "has-room": req.body
    });
  });

  io.on('connection', function(socket) {
    console.log('a user connected');
    socket.on('disconnect', function() {
      return console.log('user disconnected');
    });
    return socket.on('chat message', function(msg) {
      console.log('message: ' + msg);
      return io.emit('receive-chat', {
        message: msg,
        "for": 'everyone'
      });
    });
  });

  http.listen(3000, function() {
    return console.log('listening on *:3000');
  });

}).call(this);
