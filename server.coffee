cs   = require 'coffee-script/register'
app  = require('express')()
http = require('http').Server(app)
io   = require('socket.io')(http);
Chatroom   = require('./chatroom').Chatroom;

app.get '/', (req, res) ->
  res.sendfile 'assets/html/index.html'

app.get '/application.js', (req, res) ->
  res.sendfile 'assets/javascript/application.js'

app.get '/rooms/:name', (req, res) -> 
  console.log 'whoa, something happened!'

io.on 'connection', (socket) ->
  console.log 'a user connected'
  socket.on 'disconnect', ->
    console.log 'user disconnected'

  socket.on 'chat message', (msg) ->
    console.log 'message: ' + msg
    io.emit 'receive-chat', 
      message: msg
      for:     'everyone'

  room = Chatroom.new_chatroom 'potato'
  console.log "Room Name: #{room.name}"
  console.log "Room Password: #{room.password}"
  console.log "Room Validity: #{room.status.valid}"

http.listen 3000, ->
  console.log 'listening on *:3000' 
