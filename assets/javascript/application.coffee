class Model 
  # a model has to have 4 things:
  # 1) A stateObj method
  # 2) A title variable
  # 3) A Path method (since it can return a dynamic path)
  # 4) A Render Function, that renders the initial view
  contructor: (title, templateId) ->
    @title    = title
    @template = document.querySelector templateId
    @template.createShadowRoot()
  path: ->
    "/"
  stateObj: ->
    {}
  render: ->
    return false

class FindRoom extends Model
  constructor: ->
    @title    = 'Find A Chatroom'
    @template = document.querySelector '#new-room-form'
    @template.createShadowRoot()
  path: -> 
    return "#!/find-room"
  checkRoom: (roomName) ->
    xhr = new XMLHttpRequest()
    xhr.open("POST", "/rooms")
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");

     # send the collected data as JSON
    xhr.send(JSON.stringify({"room":roomName}));
    # xhr.send("room=#{roomName}")

    xhr.onloadend = (data) ->

      console.log("Checked the room and this is the result: #{JSON.stringify(this)}")
      # console.log("Also this: #{JSON.stringify(data)}")
      routeTo('room', JSON.parse(this.response).room.name)

  render: ->
    findRoomDOM = @template.content.querySelector(".room-finder").cloneNode(true)
    console.log findRoomDOM

    findButton = findRoomDOM.querySelector(".room-search")

    findForm = findRoomDOM.querySelector(".find-room")

    findForm.addEventListener "submit", (evt) =>
      evt.preventDefault()

      room = @checkRoom(document.querySelector(".input-room-name").value)
      # if room?
      #   routeTo('room', room)
      # return false

    return findRoomDOM

class Room extends Model
  constructor: (type, roomName)->
    @title = "Welcome to, #{roomName}"
    @template = document.querySelector '#room'
    @template.createShadowRoot()

    @name = roomName
  path: ->
    console.log("Path is: #!/rooms/#{@name}")
    return "#!/rooms/#{@name}"
  stateObj: ->
    'room':
      'name': @name
  render: ->
    newRoomDom = @template.content.querySelector(".chatroom")

    socket  = io()
    chatter = newRoomDom.querySelector '.message-form'
    message = newRoomDom.querySelector '.message-input'
    messages_holder = newRoomDom.querySelector '.messages-holder'

    new_message_template = document.querySelector '#new-message'
    new_message_template.createShadowRoot()

    socket.emit('join-room', @name)

    chatter.addEventListener 'submit', (e) ->
      unless message.value.length < 1
        socket.emit 'chat message', 
          'message':  message.value,
          'chatroom': @name
        
        message.value = ''
      e.preventDefault()
      return false

    socket.on 'receive-chat', (message_text) ->
      console.log "is this working?"
      new_message = new_message_template.content
                      .querySelector(".message").cloneNode(true);
      console.log message_text
      new_message.textContent = message_text.message
      messages_holder.appendChild new_message 


    return newRoomDom

router = 
  'root': 
    'path': ''
    'matcher': /^\/?$/
    'name': 'root'
  'find-room':
    'path': '/find-room'
    'matcher': /^#!\/find-room$/
  'rooms':
    'path': '/rooms'
    'matcher': /^\#!\/rooms\/?$/
    'name': 'view rooms'
  'room':
    'path': '/rooms/:name'
    'matcher': /^\#!\/rooms?\/([\w\d]+)\/?$/
    'name': 'view a room'

models =
  'root':      FindRoom
  'find-room': FindRoom
  'room':      Room

contentYield = document.querySelector ".yield"

routeTo = (where, match) ->
  console.log("You want to go to: #{where}.")
  TempModel = models[where]
  if TempModel?
    console.log("The Match is: #{match}")
    instance = new TempModel(where, match)
    contentYield.innerHTML = ""

    contentYield.appendChild instance.render()
    console.log(instance.title)
    history.pushState instance.stateObj(), instance.title, instance.path()
  else
    console.log 'you havent programmed that yet dawg'

# window.router = router

hash = window.location.hash

Object.keys(router).forEach (key) ->
  if router.hasOwnProperty(key)
    route = router[key]
    console.log(route)
    matched = hash.match route.matcher
    if matched? && matched.length > 0
      # history.pushState {thingie: true}, 'Whoa we are on a page!', "#!#{route.path}"
      console.log("We made it to a page! #{route.name}")
      # match.shift()
      console.log("Match really is: #{matched}")
      routeTo key, matched
      return true


window.onpopstate = (data) ->
  console.log history.state
  console.log data
  console.log 'WHO WHAT WHERE!'