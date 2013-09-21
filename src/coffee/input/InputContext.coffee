
class InputContext
  constructor: (@map) ->

  handle: (key) ->
    if @map[key]? then @[ @map[key] ]() else false

return InputContext