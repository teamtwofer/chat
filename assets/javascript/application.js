// Generated by CoffeeScript 1.7.1
(function() {
  var FindRoom, Model, Room, contentYield, hash, models, routeTo, router,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Model = (function() {
    function Model() {}

    Model.prototype.contructor = function(title, templateId) {
      this.title = title;
      this.template = document.querySelector(templateId);
      return this.template.createShadowRoot();
    };

    Model.prototype.path = function() {
      return "/";
    };

    Model.prototype.stateObj = function() {
      return {};
    };

    Model.prototype.render = function() {
      return false;
    };

    return Model;

  })();

  FindRoom = (function(_super) {
    __extends(FindRoom, _super);

    function FindRoom() {
      this.title = 'Find A Chatroom';
      this.template = document.querySelector('#new-room-form');
      this.template.createShadowRoot();
    }

    FindRoom.prototype.path = function() {
      return "#!/find-room";
    };

    FindRoom.prototype.checkRoom = function(roomName) {
      var xhr;
      xhr = new XMLHttpRequest();
      xhr.open("POST", "/rooms");
      xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
      xhr.send(JSON.stringify({
        "room": roomName
      }));
      return xhr.onloadend = function(data) {
        return console.log(this);
      };
    };

    FindRoom.prototype.render = function() {
      var findButton, findForm, findRoomDOM;
      findRoomDOM = this.template.content.querySelector(".room-finder").cloneNode(true);
      console.log(findRoomDOM);
      findButton = findRoomDOM.querySelector(".room-search");
      findForm = findRoomDOM.querySelector(".find-room");
      findForm.addEventListener("submit", (function(_this) {
        return function(evt) {
          var room;
          evt.preventDefault();
          room = _this.checkRoom(document.querySelector(".input-room-name").value);
          if (room != null) {
            routeTo('room', room);
          }
          return false;
        };
      })(this));
      return findRoomDOM;
    };

    return FindRoom;

  })(Model);

  Room = (function(_super) {
    __extends(Room, _super);

    function Room(roomName) {
      this.title = "Welcome to, " + roomName;
    }

    return Room;

  })(Model);

  router = {
    'root': {
      'path': '',
      'matcher': /^\/?$/,
      'name': 'root'
    },
    'find-room': {
      'path': '/find-room',
      'matcher': /^#!\/find-room$/
    },
    'rooms': {
      'path': '/rooms',
      'matcher': /^\#!\/rooms\/?$/,
      'name': 'view rooms'
    },
    'room': {
      'path': '/rooms/:name',
      'matcher': /^\#!\/rooms?\/([\w\d]+)\/?$/,
      'name': 'view a room'
    }
  };

  models = {
    'root': FindRoom,
    'find-room': FindRoom
  };

  contentYield = document.querySelector(".yield");

  routeTo = function(where, match) {
    var TempModel, instance;
    console.log(where);
    TempModel = models[where];
    if (TempModel != null) {
      instance = new TempModel(where, match);
      contentYield.innerHTML = "";
      contentYield.appendChild(instance.render());
      history.pushState(instance.stateObj(), instance.title, instance.path());
      return console.log(instance.render());
    } else {
      return console.log('you havent programmed that yet dawg');
    }
  };

  hash = window.location.hash;

  Object.keys(router).forEach(function(key) {
    var match, route;
    if (router.hasOwnProperty(key)) {
      route = router[key];
      console.log(route);
      match = hash.match(route.matcher);
      if ((match != null) && match.length > 0) {
        console.log("We made it to a page! " + route.name);
        match.shift();
        routeTo(key, match);
        return true;
      }
    }
  });

  window.onpopstate = function(data) {
    console.log(history.state);
    console.log(data);
    return console.log('WHO WHAT WHERE!');
  };

}).call(this);
