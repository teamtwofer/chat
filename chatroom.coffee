http = require 'http'

class Chatroom
  @rooms = {}
  
  constructor: (name, password)->
    if password? && name?
      @name     = name
      @password = password
      @users    = []
      @status   = 
        valid: true
      console.log 'New Chatroom made'
    else 
      @status = 
        valid:  false
        reason: 'A Room Must have a Password and Name.'
    if Chatroom.rooms[@name]?
      # there's already a chatroom with this name
      @status = 
        valid:  false
        reason: 'There is already a room with this name.'

  @hasRoom: (name) ->
    console.log("Chatroom.rooms[name] = #{Chatroom.rooms[name]}")
    if Chatroom.rooms[name]?
      return true
    else 
      return false

  @newChatroom: (name) ->
    password = ''
    console.log("Creating a new chatroom!")
    room = new Chatroom(name, "potato")
    console.log("room = #{name}")
    Chatroom.rooms[room.name] = room



exports.Chatroom = Chatroom
