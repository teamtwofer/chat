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
  stateObj: ->
    return {
      view: "find-room"
    }
  path: -> 
    return "#!/find-room"
  checkRoom: (roomName) ->
    if roomName.length > 5 
      xhr = new XMLHttpRequest()
      xhr.open("POST", "/rooms")
      xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");

       # send the collected data as JSON
      xhr.send(JSON.stringify({"room":roomName}));
      # xhr.send("room=#{roomName}")

      xhr.onloadend = (data) ->

        console.log("Checked the room and this is the result: #{JSON.stringify(this)}")
        # console.log("Also this: #{JSON.stringify(data)}")
        routeTo('room', [undefined, JSON.parse(this.response).room.name])      
    else
      return {
        error: "Room did not have a long enough name" 
      }   

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
      displayError(room) if room?

    return findRoomDOM

class Room extends Model
  constructor: (type, roomNameAry)->
    roomName = roomNameAry[1]
    @title = "Welcome to, #{roomName}"
    @template = document.querySelector '#room'
    @template.createShadowRoot()

    @name = roomName

    @your_name = "Nobody"
    @your_color = "#006699"

    @socket  = io()
    @newRoomDom = @template.content.querySelector(".chatroom").cloneNode(true)

    @chatter =         @newRoomDom.querySelector '.message-form'
    @message_input =   @newRoomDom.querySelector '.message-input'
    @message =         @newRoomDom.querySelector '.message-field'
    @messages_holder = @newRoomDom.querySelector '.messages-holder'
    @message_name =    @newRoomDom.querySelector '.message-name'
    @message_color =   @newRoomDom.querySelector '.message-color'

    @new_message_template = document.querySelector '#new-message'
    @new_message_template.createShadowRoot()

    xhr = new XMLHttpRequest()
    xhr.overrideMimeType("application/json");
    xhr.open('GET', '/assets/colors.json', true);
    xhr.onreadystatechange = () =>
      if (xhr.readyState == 4)
        data = JSON.parse(xhr.responseText)
        number = Math.floor(Math.random() * data.colors.length);
        @your_color = data.colors[number]

    xhr.send()

  path: ->
    console.log("Path is: #!/rooms/#{@name}")
    return "#!/rooms/#{@name}"
  stateObj: =>
    return {
      view: 'room',
      name: [undefined, @name]
    }
    # 'room':
    #   'name': @name
  render: ->

    @socket.emit('join-room', @name)

    isShiftDown = false

    @message_input.addEventListener "keydown", (e) =>
      if (e.shiftKey) 
        isShiftDown = true
      if (e.keyCode == 13 && isShiftDown != true) 
        @submitForm()

    @message_input.onkeyup = (e) ->
      if (e.keyCode == 16)
        isShiftDown = false

    @chatter.addEventListener 'submit',  @submitForm
    @socket.on 'receive-chat', (message_text) =>
      console.log "is this working?"
      new_message = @new_message_template.content
                      .querySelector(".message").cloneNode(true);
      console.log message_text

      tmpMessage = message_text.message

      urlRegex = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/g

      image_paths = ["jpg", "png", "gif"]
      console.log("Trying to match: #{tmpMessage}")
      tmpMessage = tmpMessage.replace urlRegex, (full_string, was_matched, base_url, base_protocol, path) ->
        console.log("SOME SHIT WAS MATCHED BRO")
        for image_path in image_paths
          if path.indexOf(image_path) != -1
            return "<a href='#{full_string}'><img style='max-width: 250px;' src='#{full_string}'></img></a>"
        return full_string

      message_body = new_message.querySelector(".message-body")

      message_body.innerHTML = tmpMessage

      # message_body.querySelectorAll("script").forEach (element, index, array)->
      #   message_body.removeChild(this)

      new_message.querySelector(".message-author").textContent = message_text.name
      new_message.querySelector(".message-author").style.color = message_text.color
      @messages_holder.appendChild new_message 


    return @newRoomDom
  submitForm: (e) =>
    @message_color.value = @your_color

    @message.value = @message_input.innerHTML

    if @message_name.value.length < 3
      displayError 
        error: "Must have a name bro"
      return false
    console.log("submitting...")
    unless @message.value.length < 1
      @socket.emit 'chat message', 
        'message':  @message.value,
        'chatroom': @name
        'name':     @message_name.value
        'color':    @message_color.value
      
      @message.value = ''
      @message_input.innerHTML = ''
    if e?
      e.preventDefault()
    @message_input.focus()
    return false


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

displayError = (err) ->
  document.querySelector(".error-display").textContent = err.error if err.error?
  setTimeout(->
    document.querySelector(".error-display").textContent = ""
  ,2000)

routeTo = (where, match, dontChangeState) ->
  console.log("You want to go to: #{where}.")
  TempModel = models[where]
  if TempModel?
    console.log("The Match is: #{match}")
    instance = new TempModel(where, match)
    contentYield.innerHTML = ""

    contentYield.appendChild instance.render()
    console.log(instance.title)
    # unless dontChangeState
    if true
      console.log(history.state)
      console.log(instance.stateObj())
      if history.state? && instance.stateObj().view != history.state.view
        history.pushState instance.stateObj(), instance.title, instance.path()
      else if !history.state?
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
  console.log "data is: "
  console.log data
  console.log 'WHO WHAT WHERE!'
  if data.state && data.state.view
    console.log("Routing to #{data.state.view}")
    routeTo(data.state.view, data.state.name, true)
  else
    hash = window.location.hash
    Object.keys(router).forEach (key) ->
      console.log(hash)
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

    # routeTo('root', true)
