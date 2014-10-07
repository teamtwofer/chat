app = angular.module("chat", ["ngRoute", "ngSanitize"])

# window.angular_routes = 


app.config ["$routeProvider", "$locationProvider",($routeProvider, $locationProvider) ->
  roomDescription = 
    templateUrl: "/assets/html/new-room-form.html"
    controller:  "NewRoomController"
  $routeProvider.when "/",      roomDescription
  $routeProvider.when "/rooms", roomDescription
  $routeProvider.when "/rooms/:roomName", 
    templateUrl: "/assets/html/room.html"
    controller:  "RoomController"
  $locationProvider.html5Mode true
]


app.controller "NewRoomController", ["$scope", "$http", "$location", ($scope, $http, $location)->
  # other things
  $scope.roomName = ""
  $scope.findPlace = () ->
    $http.post("/rooms", {
      room: $scope.roomName   
    }).success (data) ->
      $location.path("/rooms/#{data.room.name}")
]

app.controller "MessagesController", ["$scope", "$rootScope", "$sce", ($scope, $rootScope, $sce) ->
  tempMessages = []
  if localStorage.messages? && localStorage.messages.length > 1
    tmpMessages = JSON.parse localStorage.messages

  $scope.messages = tempMessages
  if $scope.messages == ""
    $scope.messages = new Array()


  $scope.sendBody = (text) ->
    $sce.trustAsHtml(text);

  $rootScope.socket.on "receive-chat", (messageText) ->
    # message = {
    #   body: messageText.message

    # }
    tmpMessage = messageText.message

    urlRegex = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/g

    image_paths = ["jpg", "png", "gif", "jpeg"]
    console.log("Trying to match: #{tmpMessage}")
    tmpMessage = tmpMessage.replace urlRegex, (full_string, was_matched, base_url, base_protocol, path) ->
      console.log("SOME SHIT WAS MATCHED BRO")
      for image_path in image_paths
        if path? && path.indexOf(image_path) != -1
          return "<a href='#{full_string}'><img style='max-width: 250px;' src='#{full_string}'></img></a>"
      return full_string

    # currentTime = new Date()

    message = {
      body:      tmpMessage
      author:    messageText.name
      color:     messageText.color
      timestamp: Date.now()
    }

    $scope.styleColor = (color) ->
      return {
        'color': '#'+color
      }
    $scope.messages.push message
    localStorage.messages = JSON.stringify $scope.messages
    $scope.$apply()
]

app.directive "messages", () ->
  return {
    restrict: "E",
    templateUrl: "/assets/html/messages.html"
    controller:  "MessagesController"
  }

app.controller "RoomController", ["$scope", "$http", "$location", "$routeParams", "$rootScope", ($scope, $http, $location, $routeParams, $rootScope)->
  # other things
  $rootScope.socket = io.connect "/", 
    'reconnect': true,
    'reconnection delay': 500,
    'max reconnection attempts': 10
  $scope.messageText = ""
  $scope.roomName = $routeParams.roomName
  unless localStorage.name?
    localStorage.name = "Nobody"

  $scope.name   = localStorage.name
  $scope.getColor = () ->
    $http.get("/assets/colors.json").success (data) ->
      colors = data.colors
      # console.log data.colors

      $scope.color = colors[Math.floor (Math.random() * data.colors.length)]
      console.log colors
      # $scope.$apply()
  # $scope.color  = "006699"
  $scope.getColor()
  $scope.isShiftDown = false;

  $rootScope.socket.emit "join-room", $scope.roomName

  $scope.keyPressed = (e) ->
    console.log("e.keyCode='#{e.keyCode}'");
    if (e.shiftKey) 
      $scope.isShiftDown = true
    if (e.keyCode == 13 && $scope.isShiftDown != true) 
      $scope.createNewMessage()

  $scope.keyReleased = (e) ->
    console.log("Key Released=#{e.keyCode}")
    if (e.keyCode == 16)
      $scope.isShiftDown = false
    console.log($scope.isShiftDown)

  $scope.createNewMessage = () ->
    # nothing yett
    localStorage.name = $scope.name
    $rootScope.socket.emit "chat message", 
      "message":  $scope.messageText
      "chatroom": $scope.roomName
      "name":     $scope.name
      "color":    $scope.color
    $scope.messageText = ""
]

angular.module('chat').directive 'timeago', ->
  templates =
    seconds: 'a few seconds ago'
    minute: 'a minute ago'
    minutes: '%d minutes ago'
    hour: 'an hour ago'
    hours: '%d hours ago'
    day: 'a day ago'
    days: '%d days ago'
    month: 'a month ago'
    months: '%d months ago'
    year: 'a year ago'
    years: '%d years ago'

  # replace %d with a value
  template = (name, value) ->
    templates[name]?.replace /%d/i, Math.abs(Math.round(value))

  # generate time ago string
  getTimeAgo = (time) ->
    if not time then return 'Never'

    # time = time.replace /\.\d+/, ''
    # time = time.replace(/-/, '/').replace /-/, '/'
    # time = time.replace(/T/, ' ').replace /Z/, ' UTC'
    # time = time.replace /([\+\-]\d\d)\:?(\d\d)/, ' $1$2'

    seconds = ((Date.now() - time) * .001) >> 0
    minutes = seconds / 60
    hours = minutes / 60
    days = hours / 24
    years = days / 365

    if seconds < 30 then return template 'seconds', seconds
    if seconds < 90 then return template 'minute', 1
    if minutes < 45 then return template 'minutes', minutes
    if minutes < 90 then return template 'hour', 1
    if hours < 24 then return template 'hours', hours
    if hours < 42 then return template 'day', 1
    if days < 30 then return template 'days', days
    if days < 45 then return template 'month', 1
    if days < 365 then return template 'months', days/30
    if years < 1.5 then return template 'year', 1
    return template 'years', years

  restrict: 'E'
  replace: true
  template: '<time datetime="{{time}}" title="{{time|date:\'medium\'}}">{{timeago}}</time>'
  scope:
    time: "="
  controller: ['$scope','$interval', ($scope, $interval)->
      console.log($scope.time)
      $scope.timeago = getTimeAgo($scope.time)
      $interval(->
          $scope.timeago = getTimeAgo($scope.time)
      , 5000)
    ]