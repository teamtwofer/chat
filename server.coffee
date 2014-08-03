# cs   = require 'coffee-script/register'
app  = require('express')()
bp   = require('body-parser')
http = require('http').Server(app)
io   = require('socket.io')(http);
Chatroom = require('./chatroom').Chatroom;

app.use(bp.json())

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
    console.log 'message: ' + msg

    io.to(usersRooms[this.id]).emit 'receive-chat', 
      message: msg.message

  socket.on 'join-room', (room) ->
    this.join(room)
    console.log(room)
    Chatroom.rooms[room].users.push(this.id)
    usersRooms[this.id] = room
    # small change to restart heroku
    

  # room = Chatroom.newChatroom 'potato'
  # console.log "Room Name: #{room.name}"
  # console.log "Room Password: #{room.password}"
  # console.log "Room Validity: #{room.status.valid}"

app.listen (Number(process.env.PORT || 5000);), ->
  console.log 'listening on *:3000' 
