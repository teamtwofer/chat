socket  = io()
chatter = document.querySelector '.message-form'
message = document.querySelector '.message-input'
messages_holder = document.querySelector '.messages-holder'

new_message_template = document.querySelector '#new-message'
new_message_template.createShadowRoot()

chatter.addEventListener 'submit', (e) ->
  unless message.value.length < 1
    socket.emit 'chat message', message.value
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
