// Generated by CoffeeScript 1.8.0
(function() {
  var Chatroom, http;

  http = require('http');

  Chatroom = (function() {
    Chatroom.rooms = {};

    function Chatroom(name, password) {
      if ((password != null) && (name != null)) {
        this.name = name;
        this.password = password;
        this.users = [];
        this.status = {
          valid: true
        };
        console.log('New Chatroom made');
      } else {
        this.status = {
          valid: false,
          reason: 'A Room Must have a Password and Name.'
        };
      }
      if (Chatroom.rooms[this.name] != null) {
        this.status = {
          valid: false,
          reason: 'There is already a room with this name.'
        };
      }
    }

    Chatroom.hasRoom = function(name) {
      console.log("Chatroom.rooms[name] = " + Chatroom.rooms[name]);
      if (Chatroom.rooms[name] != null) {
        return true;
      } else {
        return false;
      }
    };

    Chatroom.newChatroom = function(name) {
      var password, room;
      password = '';
      console.log("Creating a new chatroom!");
      room = new Chatroom(name, "potato");
      console.log("room = " + name);
      return Chatroom.rooms[room.name] = room;
    };

    return Chatroom;

  })();

  exports.Chatroom = Chatroom;

}).call(this);
