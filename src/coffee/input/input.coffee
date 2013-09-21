
class InputHandler
  constructor: ->
    $(document).on 'keydown', @handle.bind(this)
    @_contextManager = new InputContextManager()

  handle: (e) ->
    found = @_contextManager.find( e.which )
    if found then e.preventDefault()

  contexts: ->
    return @_contextManager


class InputContextManager
  constructor: ->
    @_contextList = []

  add: (c) ->
    @_contextList.push c

  clear: ->
    @_contextList = []

  pop: ->
    @_contextList.pop()

  find: ( key ) ->
    i = 0
    found = false

    while not found and i < @_contextList.length
      found = @_contextList[i].handle(key)
      i = i + 1

    return found

globalInputHandler = new InputHandler()

return globalInputHandler