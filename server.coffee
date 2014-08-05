# cs   = require 'coffee-script/register'
express  = require('express')
app = express()
bp   = require('body-parser')
http = require('http').Server(app)
io   = require('socket.io')(http)
Chatroom = require('./chatroom').Chatroom

app.use(bp.json())

app.use("/assets", express.static(__dirname + '/assets'));

app.get '/', (req, res) ->
  res.sendfile 'assets/html/index.html'

app.get '/application.js', (req, res) ->
  res.sendfile 'assets/javascript/application.js'

app.get '/rooms/:name', (req, res) -> 
  console.log 'whoa, something happened!'

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

    io.to(usersRooms[this.id]).emit 'receive-chat', 
      color:   msg.color
      name:    msg.name
      message: msg.message

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
    # small change to restart heroku
    

  # room = Chatroom.newChatroom 'potato'
  # console.log "Room Name: #{room.name}"
  # console.log "Room Password: #{room.password}"
  # console.log "Room Validity: #{room.status.valid}"
io.listen(http);
http.listen (Number(process.env.PORT || 3000)), ->
  console.log 'listening on *:3000' 
