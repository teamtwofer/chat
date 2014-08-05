// Generated by CoffeeScript 1.7.1
(function() {
  var FindRoom, Model, Room, contentYield, displayError, hash, models, routeTo, router,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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

    FindRoom.prototype.stateObj = function() {
      return {
        view: "find-room"
      };
    };

    FindRoom.prototype.path = function() {
      return "#!/find-room";
    };

    FindRoom.prototype.checkRoom = function(roomName) {
      var xhr;
      if (roomName.length > 5) {
        xhr = new XMLHttpRequest();
        xhr.open("POST", "/rooms");
        xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xhr.send(JSON.stringify({
          "room": roomName
        }));
        return xhr.onloadend = function(data) {
          console.log("Checked the room and this is the result: " + (JSON.stringify(this)));
          return routeTo('room', [void 0, JSON.parse(this.response).room.name]);
        };
      } else {
        return {
          error: "Room did not have a long enough name"
        };
      }
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
            return displayError(room);
          }
        };
      })(this));
      return findRoomDOM;
    };

    return FindRoom;

  })(Model);

  Room = (function(_super) {
    __extends(Room, _super);

    function Room(type, roomNameAry) {
      this.submitForm = __bind(this.submitForm, this);
      this.stateObj = __bind(this.stateObj, this);
      var roomName, xhr;
      roomName = roomNameAry[1];
      this.title = "Welcome to, " + roomName;
      this.template = document.querySelector('#room');
      this.template.createShadowRoot();
      this.name = roomName;
      this.your_name = "Nobody";
      this.your_color = "#006699";
      this.socket = io();
      this.newRoomDom = this.template.content.querySelector(".chatroom").cloneNode(true);
      this.chatter = this.newRoomDom.querySelector('.message-form');
      this.message_input = this.newRoomDom.querySelector('.message-input');
      this.message = this.newRoomDom.querySelector('.message-field');
      this.messages_holder = this.newRoomDom.querySelector('.messages-holder');
      this.message_name = this.newRoomDom.querySelector('.message-name');
      this.message_color = this.newRoomDom.querySelector('.message-color');
      this.new_message_template = document.querySelector('#new-message');
      this.new_message_template.createShadowRoot();
      xhr = new XMLHttpRequest();
      xhr.overrideMimeType("application/json");
      xhr.open('GET', '/assets/colors.json', true);
      xhr.onreadystatechange = (function(_this) {
        return function() {
          var data, number;
          if (xhr.readyState === 4) {
            data = JSON.parse(xhr.responseText);
            number = Math.floor(Math.random() * data.colors.length);
            return _this.your_color = data.colors[number];
          }
        };
      })(this);
      xhr.send();
    }

    Room.prototype.path = function() {
      console.log("Path is: #!/rooms/" + this.name);
      return "#!/rooms/" + this.name;
    };

    Room.prototype.stateObj = function() {
      return {
        view: 'room',
        name: [void 0, this.name]
      };
    };

    Room.prototype.render = function() {
      var isShiftDown;
      Notification.requestPermission();
      this.socket.emit('join-room', this.name);
      isShiftDown = false;
      this.message_input.addEventListener("keydown", (function(_this) {
        return function(e) {
          if (e.shiftKey) {
            isShiftDown = true;
          }
          if (e.keyCode === 13 && isShiftDown !== true) {
            return _this.submitForm();
          }
        };
      })(this));
      this.message_input.addEventListener("keyup", function(e) {
        if (e.keyCode === 16) {
          return isShiftDown = false;
        }
      });
      this.chatter.addEventListener('submit', this.submitForm);
      this.socket.on('receive-chat', (function(_this) {
        return function(message_text) {
          var body, height, html, image_paths, message_body, new_message, notification, tmpMessage, urlRegex;
          console.log("is this working?");
          new_message = _this.new_message_template.content.querySelector(".message").cloneNode(true);
          console.log(message_text);
          tmpMessage = message_text.message;
          urlRegex = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/g;
          image_paths = ["jpg", "png", "gif"];
          console.log("Trying to match: " + tmpMessage);
          tmpMessage = tmpMessage.replace(urlRegex, function(full_string, was_matched, base_url, base_protocol, path) {
            var image_path, _i, _len;
            console.log("SOME SHIT WAS MATCHED BRO");
            for (_i = 0, _len = image_paths.length; _i < _len; _i++) {
              image_path = image_paths[_i];
              if (path.indexOf(image_path) !== -1) {
                return "<a href='" + full_string + "'><img style='max-width: 250px;' src='" + full_string + "'></img></a>";
              }
            }
            return full_string;
          });
          message_body = new_message.querySelector(".message-body");
          message_body.innerHTML = tmpMessage;
          new_message.querySelector(".message-author").textContent = message_text.name;
          new_message.querySelector(".message-author").style.color = message_text.color;
          _this.messages_holder.appendChild(new_message);
          body = document.body;
          html = document.documentElement;
          height = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
          window.scrollTo(0, height);
          if (message_text.name !== _this.message_name.value) {
            return notification = new Notification("" + _this.message_name.value + " says...", {
              body: tmpMessage
            });
          }
        };
      })(this));
      return this.newRoomDom;
    };

    Room.prototype.submitForm = function(e) {
      this.message_color.value = this.your_color;
      this.message.value = this.message_input.innerHTML;
      if (this.message_name.value.length < 3) {
        displayError({
          error: "Must have a name bro"
        });
        return false;
      }
      console.log("submitting...");
      if (!(this.message_input.innerHTML.length < 1)) {
        this.socket.emit('chat message', {
          'message': this.message_input.innerHTML,
          'chatroom': this.name,
          'name': this.message_name.value,
          'color': this.message_color.value
        });
        this.message.value = '';
        this.message_input.innerHTML = '';
      }
      if (e != null) {
        e.preventDefault();
      }
      this.message_input.focus();
      return false;
    };

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
    'find-room': FindRoom,
    'room': Room
  };

  contentYield = document.querySelector(".yield");

  displayError = function(err) {
    if (err.error != null) {
      document.querySelector(".error-display").textContent = err.error;
    }
    return setTimeout(function() {
      return document.querySelector(".error-display").textContent = "";
    }, 2000);
  };

  routeTo = function(where, match, dontChangeState) {
    var TempModel, instance;
    console.log("You want to go to: " + where + ".");
    TempModel = models[where];
    if (TempModel != null) {
      console.log("The Match is: " + match);
      instance = new TempModel(where, match);
      contentYield.innerHTML = "";
      contentYield.appendChild(instance.render());
      console.log(instance.title);
      if (true) {
        console.log(history.state);
        console.log(instance.stateObj());
        if ((history.state != null) && instance.stateObj().view !== history.state.view) {
          return history.pushState(instance.stateObj(), instance.title, instance.path());
        } else if (history.state == null) {
          return history.pushState(instance.stateObj(), instance.title, instance.path());
        }
      }
    } else {
      return console.log('you havent programmed that yet dawg');
    }
  };

  hash = window.location.hash;

  Object.keys(router).forEach(function(key) {
    var matched, route;
    if (router.hasOwnProperty(key)) {
      route = router[key];
      console.log(route);
      matched = hash.match(route.matcher);
      if ((matched != null) && matched.length > 0) {
        console.log("We made it to a page! " + route.name);
        console.log("Match really is: " + matched);
        routeTo(key, matched);
        return true;
      }
    }
  });

  window.onpopstate = function(data) {
    console.log(history.state);
    console.log("data is: ");
    console.log(data);
    console.log('WHO WHAT WHERE!');
    if (data.state && data.state.view) {
      console.log("Routing to " + data.state.view);
      return routeTo(data.state.view, data.state.name, true);
    } else {
      hash = window.location.hash;
      return Object.keys(router).forEach(function(key) {
        var matched, route;
        console.log(hash);
        if (router.hasOwnProperty(key)) {
          route = router[key];
          console.log(route);
          matched = hash.match(route.matcher);
          if ((matched != null) && matched.length > 0) {
            console.log("We made it to a page! " + route.name);
            console.log("Match really is: " + matched);
            routeTo(key, matched);
            return true;
          }
        }
      });
    }
  };

}).call(this);
