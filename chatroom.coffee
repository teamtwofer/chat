random_word_url = 'randomword.setgetgo.com'

http = require 'http'

options = 
  host: random_word_url
  port: 80
  path: '/get.php'


class Chatroom
  @rooms = {}
  constructor: (name, password)->
    if !password? || !name?
      @name     = name
      @password = password
      @status   = 
        valid: true
      console.log 'New Chatroom made'
    else 
      @status = 
        valid:  false
        reason: 'A Room Must have a Password and Name.'
    if Chatroom.rooms[room.name]?
      # there's already a chatroom with this name
      @status = 
        valid:  false
        reason: 'There is already a room with this name.'

  @new_chatroom: (name) ->
    password = ''
    [1..3].forEach (i) ->
      http.get options, (resp) ->
        resp.on 'data', (chunk) ->
          console.log('BODY: ' + chunk);
          password += chunk
        resp.on 'end', ->
          if i == 3
            room = new Chatroom name, password

            if room.status.valid == true
              Chatroom.rooms[room.name] = room
              console.log room.status.reason
            else 
            return room



exports.Chatroom = Chatroom
