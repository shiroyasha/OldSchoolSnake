
input        = require('input/input')
InputContext = require('input/InputContext')

mod  = (a, n) -> a - (n * Math.floor(a/n))
rint = (a, b) -> a + Math.floor( Math.random()*b )
add  = (a, b) -> [a[0]+b[0], a[1]+b[1]]
zero = (a) -> a[0] == 0 and a[1] == 0


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
  @UP    : [ 0,-1]
  @DOWN  : [ 0, 1]
  @LEFT  : [-1, 0]
  @RIGHT : [ 1, 0]

  constructor: (@parent)->
    @parts = []
    @speed = $('#snakeSpeed').val()

    $('#snakeSpeed').on 'change', (e) =>
      console.log('here')
      @speed = $(e.currentTarget).val()


    @toMove = 0
    @direction = Snake.DOWN

  _headOnFood: ->
    head = @parts[@parts.length-1]
    food = @parent.food.pos
    return head.x == food[0] and head.y == food[1]

  addPart: (x, y, type = SnakePart.BODY ) ->
    @parts.push new SnakePart(x, y, type)

  turn: ( dir ) ->
    res = add( dir, @direction )
    if not zero( res ) then @direction = dir

  render: (c) -> p.render(c) for p in @parts

  update: (delta) ->
    @toMove += (delta / 1000) * @speed

    while @toMove > 1


      head = @parts[@parts.length-1]
      @addPart( head.x + @direction[0], head.y + @direction[1], SnakePart.HEAD)
      head.type = SnakePart.BODY

      if not @_headOnFood()
        @parts.shift()
        @parts[0].type = SnakePart.TAIL
      else
        @parent.food.pos = null

      @toMove -= 1




class Food
  constructor: (@game)->
    @pos = null

  _onSnake: ->
    if @pos == null then return true

    for p in @game.snake.parts
      if p.x == @pos[0] and p.y == @pos[1] then return true

    return false

  update: ->
    if @pos == null
      @pos = [ rint(0, 44), rint(0, 30) ] while @_onSnake()


  render: (ctx) ->
    console.log @pos
    if @pos == null then return

    ctx.fillStyle = '#ff0'
    ctx.fillRect( @pos[0]*20 + 1, @pos[1]*20 + 1, 18, 18 )



class Game extends Timer
  constructor: (@ctx, @el) ->
    super()
    @snake = new Snake( this )
    @food  = new Food( this )
    @fps   = new FPSCounter()

    @snake.addPart(3, 4, SnakePart.TAIL )
    @snake.addPart(3, 5)
    @snake.addPart(3, 6)
    @snake.addPart(4, 6)
    @snake.addPart(5, 6, SnakePart.HEAD )

  step: (delta)->
    @ctx.clearRect(0,0, @el[0].width,@el[0].height )
    @fps.update(delta)
    @snake.update(delta)
    @food.update(delta)

    @snake.render(@ctx)
    @food.render(@ctx)


class GameScreen extends Screen
  constructor: (@el) ->
    super(@el, {37: 'left', 38: 'up', 39: 'right', 40: 'down', 27: 'esc' })

    @el[0].width = @el.parent().width()
    @el[0].height = @el.parent().height()
    @ctx = @el[0].getContext '2d'

    @game = new Game(@ctx, @el)

  show: ->
    @ctx.clearRect(0,0,@el[0].width,@el[0].height)
    @game.start()
    super()

  left: -> @game.snake.turn( Snake.LEFT ) ; true
  right: -> @game.snake.turn( Snake.RIGHT ); true
  up: -> @game.snake.turn( Snake.UP ); true
  down: -> @game.snake.turn( Snake.DOWN ); true

  esc: ->
    @game.pause()
    true


drawBgPattern = ->
  el = document.getElementById('bg')

  el.width = $('.container').width()
  el.height = $('.container').height()

  ctx = el.getContext('2d')

  ctx.fillStyle = '#ddd'
  ctx.fillRect( 0 , 0, el.width, el.height )

  ctx.strokeStyle = '#fff'

  for y in [0..Math.floor(el.height/20)] by 1
    ctx.beginPath()
    ctx.moveTo( 0, y*20 )
    ctx.lineTo( el.width , y*20 )
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo( 0, y*20+19 )
    ctx.lineTo( el.width, y*20+19 )
    ctx.stroke()

  for x in [0..Math.floor(el.width/20)] by 1
    ctx.beginPath()
    ctx.moveTo( x*20, 0 )
    ctx.lineTo( x*20, el.height )
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo( x*20+19, 0 )
    ctx.lineTo( x*20+19, el.height )
    ctx.stroke()



$ ->
  $('.menu').each -> new Menu( $(this) )
  $('.optionScreen').each -> new OptionScreen( $(this) )

  $('#soundController').each -> new SoundController( $(this) )
  $('#colorController').each -> new ColorController( $(this) )
  $('#game').each -> new GameScreen( $(this) )

  $('#mainMenu').data('handler').show()

  drawBgPattern()