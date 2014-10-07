# cs   = require 'coffee-script/register'
express  = require('express')
app      = express()
bp       = require('body-parser')
http     = require('http').Server(app)
io       = require('socket.io')(http)
Chatroom = require('./chatroom').Chatroom
marked   = require('marked')

marked.setOptions 
  gfm: true
  emoji:  (emoji) ->
    return "<img src=\"/images/emojis/#{emoji}.png\" alt=\":#{emoji}:\" title=\":#{emoji}:\" class=\"emoji\" align=\"absmiddle\" height=\"20\" width=\"20\">"
    # return '<span data-emoji="' + emoji + '"></span>';
  highlight: (code, lang, callback) ->
    require("pygmentize-bundled")
      lang: lang
      format: "html"
    , code, (err, result) ->
      callback err, result.toString()

app.use(bp.json())

app.use("/assets", express.static(__dirname + '/assets'));

app.get '/', (req, res) ->
  res.sendfile 'assets/html/index.html'

app.get '/application.js', (req, res) ->
  res.sendfile 'assets/javascript/application.js'

app.get '/rooms/:name', (req, res) -> 
  res.sendfile 'assets/html/index.html'

app.get '/images/emojis/:emoji', (req, res) -> 
  res.sendfile "assets/images/emojis/#{req.params.emoji}"

app.post '/rooms', (req, res) ->
  console.log req.param("room")

  lookingFor = req.body.room

  roomExists = Chatroom.hasRoom(lookingFor)

  console.log("Does the room exist? #{roomExists}")
  console.log("Room name: #{lookingFor}")

  if !roomExists
    room = Chatroom.newChatroom lookingFor
  else
    room = Chatroom.rooms[lookingFor]

  console.log "The rooms are: #{JSON.stringify(Chatroom.rooms[room.name])}"

  res.json
    "room": room

usersRooms={}

io.on 'connection', (socket) ->
  console.log 'a user connected'
  console.log socket.id
  socket.on 'disconnect', ->
    console.log 'user disconnected'

  socket.on 'chat message', (msg) ->
    console.log msg

    renderedMsg = msg.message

    renderedMsg.replace(/\&lt;br\&gt;/, "    ")

    # Using async version of marked
    marked renderedMsg, (err, content) =>
      throw err  if err
      io.to(usersRooms[this.id]).emit 'receive-chat', 
        color:   msg.color
        name:    msg.name
        message: content
      console.log content



  socket.on 'join-room', (room) ->
    this.join(room)
    console.log(room)
    if room.length < 6
      io.to(this.id).emit 'receive-chat',
        name:    'system',
        message: "Room name is not long enough, sorry bro!"
      return false
    roomExists = Chatroom.hasRoom(room)
    unless roomExists
      Chatroom.newChatroom room
    Chatroom.rooms[room].users.push(this.id)
    usersRooms[this.id] = room

    io.to(usersRooms[this.id]).emit 'receive-chat',
      color:   "000000"
      name:    "system"
      message: "A User Has Joined the Chatroom"
    # small change to restart heroku
    

  # room = Chatroom.newChatroom 'potato'
  # console.log "Room Name: #{room.name}"
  # console.log "Room Password: #{room.password}"
  # console.log "Room Validity: #{room.status.valid}"
# io.listen(http);
http.listen (Number(process.env.PORT || 3000)), ->
  console.log 'listening on *:3000' 
