# socket  = io()
# chatter = document.querySelector '.message-form'
# message = document.querySelector '.message-input'
# messages_holder = document.querySelector '.messages-holder'

# new_message_template = document.querySelector '#new-message'
# new_message_template.createShadowRoot()

# chatter.addEventListener 'submit', (e) ->
#   unless message.value.length < 1
#     socket.emit 'chat message', message.value
#     message.value = ''
#   e.preventDefault()
#   return false

# socket.on 'receive-chat', (message_text) ->
#   console.log "is this working?"
#   new_message = new_message_template.content
#                   .querySelector(".message").cloneNode(true);
#   console.log message_text
#   new_message.textContent = message_text.message
#   messages_holder.appendChild new_message 
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
  render: ->
    findRoomDOM = @template.content.querySelector(".room-finder").cloneNode(true)
    console.log findRoomDOM

    findButton = findRoomDOM.querySelector(".room-search")

    findForm = findRoomDOM.querySelector(".find-room")

    findForm.addEventListener "submit", (evt) ->
      room = this.checkRoom(document.querySelector(".input-room-name").value)
      if room?
        routeTo('room', room)
      evt.preventDefault()
      return false

    return findRoomDOM

class Room extends Model
  constructor: (roomName)->
    @title = "Welcome to, #{roomName}"

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

contentYield = document.querySelector ".yield"

routeTo = (where, match) ->
  console.log(where)
  TempModel = models[where]
  if TempModel?
    instance = new TempModel(where, match)
    contentYield.innerHTML = ""

    contentYield.appendChild instance.render()
    history.pushState instance.stateObj(), instance.title, instance.path()
    console.log instance.render()
  else
    console.log('you havent programmed that yet dawg')

# window.router = router

hash = window.location.hash

Object.keys(router).forEach (key) ->
  if router.hasOwnProperty(key)
    route = router[key]
    console.log(route)
    match = hash.match route.matcher
    if match? && match.length > 0
      # history.pushState {thingie: true}, 'Whoa we are on a page!', "#!#{route.path}"
      console.log("We made it to a page! #{route.name}")
      match.shift()
      routeTo key, match
      return true


window.onpopstate = (data) ->
  console.log history.state
  console.log data
  console.log 'WHO WHAT WHERE!'