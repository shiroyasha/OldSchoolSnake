
input        = require('input/input')
InputContext = require('input/InputContext')

mod = (a, n) -> a - (n * Math.floor(a/n))


class Screen extends InputContext
  constructor: (@el, @keyMap ) ->
    super( @keyMap )
    @el.data('handler', this )

  show: () ->
    input.contexts().clear()
    input.contexts().add( this )
    @el.show()

  hide: () ->
    @el.hide()

  goto: (id) ->
    if not id? then return
    @hide()
    $(id).data('handler').show()






class Menu extends Screen
  constructor: ( @menu ) ->
    super( @menu, { 38: 'up', 40: 'down', 13: 'enter'})

    @count = @menu.find('ul.items > li').length

  show: () ->
    @_switchTo(0)
    super()

  _switchTo: ( @current )->
    @menu.find('ul.items > li.active').removeClass('active')
    @menu.find('ul.items > li').eq( @current ).addClass('active')

  up: -> @_switchTo( mod( @current - 1, @count ) )
  down: -> @_switchTo( mod( @current + 1, @count ) )
  enter: -> @goto( @menu.find('ul.items > li').eq(@current).attr('data-goto') )





class OptionScreen extends Screen
  constructor: (@el)->
    super(@el, {37: 'left', 39: 'right', 13: 'enter'})

  left: -> true
  right: -> true
  enter: -> @goto( @el.find('[data-action]').attr('data-goto') )




class SoundController extends OptionScreen
  constructor: (@el) ->
    super( @el )

    @value = 1

  _updateFill: (@value)->
    @el.find('.fill').css('width', @value + '%')

  show: ->
    @_updateFill( @value )
    super()

  left: -> @_updateFill( Math.max(0, @value-5) )
  right: -> @_updateFill( Math.min(100, @value+5) )



class ColorController extends OptionScreen
  constructor: (@el) ->
    super( @el )

    @value = 0
    @count = @el.find('.color').length

  _switchTo: (@value)->
    @el.find('.color').removeClass('active')
    @el.find('.color').eq(@value).addClass('active')

  show: ->
    @_switchTo( @value )
    super()

  left: -> @_switchTo( mod( @value-1, @count) )
  right: -> @_switchTo( mod( @value+1, @count) )


class FPSCounter
  constructor: (@update_constant = 3000)->
    console.log 'start'
    @_reset()

  _reset: ->
    @_frames = 0

    @_min = Number.POSITIVE_INFINITY
    @_avg = 0
    @_max = Number.NEGATIVE_INFINITY

  update: ( delta ) ->
    @_frames += 1
    @_avg += delta

    @_min = Math.min( @_min, ~~(1000/delta) )
    @_max = Math.max( @_max, ~~(1000/delta) )

    @_fps = @_avg / @_frames

    if @_avg > @update_constant
      console.log 'fps:', ~~@_fps, 'min:', @_min, 'max:', @_max
      @_reset()



fps = new FPSCounter()


class Timer
  constructor: ->
    @_timer = null

  _loop: ->
    now = Date.now()
    dt = if @_last < 0 then 0 else now - @_last

    @step( dt )
    @_last = now

  start: ->
    @_last = -1
    @_timer = setInterval @_loop.bind(this), 20

  pause: ->
    clearTimeout @_timer

  step: (delta) ->
    fps.update(delta)



class SnakePart
  @BODY: 0
  @HEAD: 1
  @TAIL: 2

  constructor: (@x, @y, @type) ->

  setType: (@type) ->

  render: (c)->
    switch @type
      when SnakePart.BODY then c.fillStyle = '#36c'
      when SnakePart.HEAD then c.fillStyle = '#c36'
      when SnakePart.TAIL then c.fillStyle = '#63c'

    c.fillRect(@x * 20 + 1, @y * 20 + 1, 18, 18 )



class Snake
  constructor: ->
    @parts = []

  addPart: (x, y, type = SnakePart.BODY ) ->
    @parts.push new SnakePart(x, y, type)

  render: (c) -> p.render(c) for p in @parts





class GameScreen extends Screen
  constructor: (@el) ->
    super(@el, {37: 'left', 38: 'up', 39: 'right', 40: 'down', 27: 'esc' })

    @el[0].width = @el.parent().width()
    @el[0].height = @el.parent().height()
    @ctx = @el[0].getContext '2d'

    @snake = new Snake()
    @timer = new Timer()

  show: ->
    @ctx.clearRect(0,0,@el[0].width,@el[0].height)

    @snake.addPart(3, 4, SnakePart.TAIL )
    @snake.addPart(3, 5)
    @snake.addPart(3, 6)
    @snake.addPart(4, 6)
    @snake.addPart(5, 6, SnakePart.HEAD )

    @snake.render(@ctx)

    @timer.start()

    super()

  left: -> @ctx.fillRect(100, 100, 10, 10); true
  right: -> console.log 'right'; true
  up: -> console.log 'up'; true
  down: -> console.log 'down'; true
  esc: -> console.log 'esc'; true





$ ->
  $('.menu').each -> new Menu( $(this) )
  $('.optionScreen').each -> new OptionScreen( $(this) )

  $('#soundController').each -> new SoundController( $(this) )
  $('#colorController').each -> new ColorController( $(this) )
  $('#game').each -> new GameScreen( $(this) )

  $('#mainMenu').data('handler').show()