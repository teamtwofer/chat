// Generated by CoffeeScript 1.7.1
(function() {
  var Chatroom, app, bp, express, http, io, marked, usersRooms;

  express = require('express');

  app = express();

  bp = require('body-parser');

  http = require('http').Server(app);

  io = require('socket.io')(http);

  Chatroom = require('./chatroom').Chatroom;

  marked = require('marked');

  marked.setOptions({
    gfm: true,
    emoji: function(emoji) {
      return "<img src=\"/images/emojis/" + emoji + ".png\" alt=\":" + emoji + ":\" title=\":" + emoji + ":\" class=\"emoji\" align=\"absmiddle\" height=\"20\" width=\"20\">";
    },
    highlight: function(code, lang, callback) {
      return require("pygmentize-bundled")({
        lang: lang,
        format: "html"
      }, code, function(err, result) {
        return callback(err, result.toString());
      });
    }
  });

  app.use(bp.json());

  app.use("/assets", express["static"](__dirname + '/assets'));

  app.get('/', function(req, res) {
    return res.sendfile('assets/html/index.html');
  });

  app.get('/application.js', function(req, res) {
    return res.sendfile('assets/javascript/application.js');
  });

  app.get('/rooms/:name', function(req, res) {
    return console.log('whoa, something happened!');
  });

  app.get('/images/emojis/:emoji', function(req, res) {
    return res.sendfile("assets/images/emojis/" + req.params.emoji);
  });

  app.post('/rooms', function(req, res) {
    var lookingFor, room, roomExists;
    console.log(req.param("room"));
    lookingFor = req.body.room;
    roomExists = Chatroom.hasRoom(lookingFor);
    console.log("Does the room exist? " + roomExists);
    console.log("Room name: " + lookingFor);
    if (!roomExists) {
      room = Chatroom.newChatroom(lookingFor);
    } else {
      room = Chatroom.rooms[lookingFor];
    }
    console.log("The rooms are: " + (JSON.stringify(Chatroom.rooms[room.name])));
    return res.json({
      "room": room
    });
  });

  usersRooms = {};

  io.on('connection', function(socket) {
    console.log('a user connected');
    console.log(socket.id);
    socket.on('disconnect', function() {
      return console.log('user disconnected');
    });
    socket.on('chat message', function(msg) {
      var renderedMsg;
      console.log(msg);
      renderedMsg = msg.message;
      renderedMsg.replace(/\&lt;br\&gt;/, "    ");
      return marked(renderedMsg, (function(_this) {
        return function(err, content) {
          if (err) {
            throw err;
          }
          io.to(usersRooms[_this.id]).emit('receive-chat', {
            color: msg.color,
            name: msg.name,
            message: content
          });
          return console.log(content);
        };
      })(this));
    });
    return socket.on('join-room', function(room) {
      var roomExists;
      this.join(room);
      console.log(room);
      if (room.length < 6) {
        io.to(this.id).emit('receive-chat', {
          name: 'system',
          message: "Room name is not long enough, sorry bro!"
        });
        return false;
      }
      roomExists = Chatroom.hasRoom(room);
      if (!roomExists) {
        Chatroom.newChatroom(room);
      }
      Chatroom.rooms[room].users.push(this.id);
      usersRooms[this.id] = room;
      return io.to(usersRooms[this.id]).emit('receive-chat', {
        color: "#000",
        name: "system",
        message: "A User Has Joined the Chatroom"
      });
    });
  });

  http.listen(Number(process.env.PORT || 3000), function() {
    return console.log('listening on *:3000');
  });

}).call(this);
