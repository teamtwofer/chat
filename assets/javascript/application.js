// Generated by CoffeeScript 1.7.1
(function() {
  var app;

  app = angular.module("chat", ["ngRoute", "ngSanitize"]);

  app.config([
    "$routeProvider", "$locationProvider", function($routeProvider, $locationProvider) {
      var roomDescription;
      roomDescription = {
        templateUrl: "/assets/html/new-room-form.html",
        controller: "NewRoomController"
      };
      $routeProvider.when("/", roomDescription);
      $routeProvider.when("/rooms", roomDescription);
      $routeProvider.when("/rooms/:roomName", {
        templateUrl: "/assets/html/room.html",
        controller: "RoomController"
      });
      return $locationProvider.html5Mode(true);
    }
  ]);

  app.controller("NewRoomController", [
    "$scope", "$http", "$location", function($scope, $http, $location) {
      $scope.roomName = "";
      return $scope.findPlace = function() {
        return $http.post("/rooms", {
          room: $scope.roomName
        }).success(function(data) {
          return $location.path("/rooms/" + data.room.name);
        });
      };
    }
  ]);

  app.controller("MessagesController", [
    "$scope", "$rootScope", "$sce", function($scope, $rootScope, $sce) {
      var tempMessages, tmpMessages;
      tempMessages = [];
      if ((localStorage.messages != null) && localStorage.messages.length > 1) {
        tmpMessages = JSON.parse(localStorage.messages);
      }
      $scope.messages = tempMessages;
      if ($scope.messages === "") {
        $scope.messages = new Array();
      }
      $scope.sendBody = function(text) {
        return $sce.trustAsHtml(text);
      };
      return $rootScope.socket.on("receive-chat", function(messageText) {
        var image_paths, message, tmpMessage, urlRegex;
        tmpMessage = messageText.message;
        urlRegex = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/g;
        image_paths = ["jpg", "png", "gif", "jpeg"];
        console.log("Trying to match: " + tmpMessage);
        tmpMessage = tmpMessage.replace(urlRegex, function(full_string, was_matched, base_url, base_protocol, path) {
          var image_path, _i, _len;
          console.log("SOME SHIT WAS MATCHED BRO");
          for (_i = 0, _len = image_paths.length; _i < _len; _i++) {
            image_path = image_paths[_i];
            if ((path != null) && path.indexOf(image_path) !== -1) {
              return "<a href='" + full_string + "'><img style='max-width: 250px;' src='" + full_string + "'></img></a>";
            }
          }
          return full_string;
        });
        message = {
          body: tmpMessage,
          author: messageText.name,
          color: messageText.color,
          timestamp: Date.now()
        };
        $scope.styleColor = function(color) {
          return {
            'color': '#' + color
          };
        };
        $scope.messages.push(message);
        localStorage.messages = JSON.stringify($scope.messages);
        return $scope.$apply();
      });
    }
  ]);

  app.directive("messages", function() {
    return {
      restrict: "E",
      templateUrl: "/assets/html/messages.html",
      controller: "MessagesController"
    };
  });

  app.controller("RoomController", [
    "$scope", "$http", "$location", "$routeParams", "$rootScope", function($scope, $http, $location, $routeParams, $rootScope) {
      $rootScope.socket = io.connect("/", {
        'reconnect': true,
        'reconnection delay': 500,
        'max reconnection attempts': 10
      });
      $scope.messageText = "";
      $scope.roomName = $routeParams.roomName;
      if (localStorage.name == null) {
        localStorage.name = "Nobody";
      }
      $scope.name = localStorage.name;
      $scope.getColor = function() {
        return $http.get("/assets/colors.json").success(function(data) {
          var colors;
          colors = data.colors;
          $scope.color = colors[Math.floor(Math.random() * data.colors.length)];
          return console.log(colors);
        });
      };
      $scope.getColor();
      $scope.isShiftDown = false;
      $rootScope.socket.emit("join-room", $scope.roomName);
      $scope.keyPressed = function(e) {
        console.log("e.keyCode='" + e.keyCode + "'");
        if (e.shiftKey) {
          $scope.isShiftDown = true;
        }
        if (e.keyCode === 13 && $scope.isShiftDown !== true) {
          return $scope.createNewMessage();
        }
      };
      $scope.keyReleased = function(e) {
        console.log("Key Released=" + e.keyCode);
        if (e.keyCode === 16) {
          $scope.isShiftDown = false;
        }
        return console.log($scope.isShiftDown);
      };
      return $scope.createNewMessage = function() {
        localStorage.name = $scope.name;
        $rootScope.socket.emit("chat message", {
          "message": $scope.messageText,
          "chatroom": $scope.roomName,
          "name": $scope.name,
          "color": $scope.color
        });
        return $scope.messageText = "";
      };
    }
  ]);

  angular.module('chat').directive('timeago', function() {
    var getTimeAgo, template, templates;
    templates = {
      seconds: 'a few seconds ago',
      minute: 'a minute ago',
      minutes: '%d minutes ago',
      hour: 'an hour ago',
      hours: '%d hours ago',
      day: 'a day ago',
      days: '%d days ago',
      month: 'a month ago',
      months: '%d months ago',
      year: 'a year ago',
      years: '%d years ago'
    };
    template = function(name, value) {
      var _ref;
      return (_ref = templates[name]) != null ? _ref.replace(/%d/i, Math.abs(Math.round(value))) : void 0;
    };
    getTimeAgo = function(time) {
      var days, hours, minutes, seconds, years;
      if (!time) {
        return 'Never';
      }
      seconds = ((Date.now() - time) * .001) >> 0;
      minutes = seconds / 60;
      hours = minutes / 60;
      days = hours / 24;
      years = days / 365;
      if (seconds < 30) {
        return template('seconds', seconds);
      }
      if (seconds < 90) {
        return template('minute', 1);
      }
      if (minutes < 45) {
        return template('minutes', minutes);
      }
      if (minutes < 90) {
        return template('hour', 1);
      }
      if (hours < 24) {
        return template('hours', hours);
      }
      if (hours < 42) {
        return template('day', 1);
      }
      if (days < 30) {
        return template('days', days);
      }
      if (days < 45) {
        return template('month', 1);
      }
      if (days < 365) {
        return template('months', days / 30);
      }
      if (years < 1.5) {
        return template('year', 1);
      }
      return template('years', years);
    };
    return {
      restrict: 'E',
      replace: true,
      template: '<time datetime="{{time}}" title="{{time|date:\'medium\'}}">{{timeago}}</time>',
      scope: {
        time: "="
      },
      controller: [
        '$scope', '$interval', function($scope, $interval) {
          console.log($scope.time);
          $scope.timeago = getTimeAgo($scope.time);
          return $interval(function() {
            return $scope.timeago = getTimeAgo($scope.time);
          }, 5000);
        }
      ]
    };
  });

}).call(this);
