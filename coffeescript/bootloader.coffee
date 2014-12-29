(($) ->

  class Board
    @objElement = null
    @arrPlayers = null
    @objBall = null
    @objScoreBoard = null
    @strColor = null

    constructor: (objElement)->
      # create/assign properties
      @arrPlayers = []
      @objElement = objElement.addClass 'board'

      @objBall = new Ball
      @objElement.append @objBall.objElement

      #style elements
      @strColor = '#000000'
      @objElement.css('background-color', @strColor)


    addPlayer: (objPlayer)->
      @arrPlayers.push objPlayer
      @objElement.append objPlayer.objPaddle.objElement if objPlayer.objPaddle.objElement?

    addScoreBoard: (objScoreBoard)->
      @objScoreBoard = objScoreBoard

      for objPlayer in @arrPlayers

        @objScoreBoard.objElement.append $('<div class="score"></div>').attr('data-player-id', objPlayer.intId)
        @objScoreBoard.objPlayerScores[objPlayer.intId] =
          intId: objPlayer.intId
          intScore: 0

      @objElement.append objScoreBoard.objElement

      @objScoreBoard.resetScoreBoard()

    startGame: ->
      @objBall.resetBall()

      for objPlayer in @arrPlayers
        objPlayer.objPaddle.resetPaddle()

      $(document).keydown (event) =>
        intKeyCode = event.keyCode
        intY = 50

        for objPlayer in @arrPlayers
          objPlayer.objPaddle.movePaddle(intY) if intKeyCode == parseInt(objPlayer.objPaddle.objControls.down)
          objPlayer.objPaddle.movePaddle(intY * -1) if intKeyCode == parseInt(objPlayer.objPaddle.objControls.up)

      @objBall.startMoving()

  class Ball
    @objElement = null
    @strColor = null
    @intXModifier = null
    @intYModifier = null
    @evtMoveBall = null

    constructor: ->
      @strColor = '#ffffff'
      @intXModifier = 1
      @intYModifier = 1

      @objElement = $('<div class="ball"></div>')
        .css('background-color', @strColor)

    resetBall: ->
      @objElement
        .css('top', (objApp.objBoard.objElement.height() / 2) - (@objElement.height() / 2))
        .css('left', (objApp.objBoard.objElement.width() / 2) - (@objElement.width() / 2))

      # flip x position
      if @intXModifier == 1
        @intXModifier = -1
      else
        @intXModifier = 1

    startMoving: ->
      @resetBall()

      @getRandomNumber(2, 15, (intX)=>
        @getRandomNumber(2, 10, (intY)->
          objApp.objBoard.objBall.evtMoveBall = setInterval ->
            objApp.objBoard.objBall.moveBall(intX, intY)
          , 10
        )
      )

    moveBall: (intX, intY)->
      @animateBall(intX, intY)

    animateBall: (intX, intY)->
      objPosition = @objElement.position()
      objPosition.right = @objElement.width() + objPosition.left
      objPosition.bottom = @objElement.height() + objPosition.top

      # check if ball is hitting wall
      objBoardPosition = objApp.objBoard.objElement.position()
      objBoardPosition.right = objApp.objBoard.objElement.width() + objBoardPosition.left
      objBoardPosition.bottom = objApp.objBoard.objElement.height() + objBoardPosition.top

      if objBoardPosition.left > objPosition.left or objPosition.right > objBoardPosition.right
        objPlayer.objPaddle.growPaddle(10) for objPlayer in objApp.objBoard.arrPlayers

        # flip x position
        if @intXModifier == 1
          @intXModifier = -1
        else
          @intXModifier = 1

      if objBoardPosition.top > objPosition.top or objPosition.bottom > objBoardPosition.bottom
        # flip x position
        if @intYModifier == 1
          @intYModifier = -1
        else
          @intYModifier = 1

      # check if ball is hitting paddle
      for objPlayer in objApp.objBoard.arrPlayers
        objPaddlePosition = objPlayer.objPaddle.objElement.position()
        objPaddlePosition.bottom = objPlayer.objPaddle.objElement.height() + objPaddlePosition.top
        objPaddlePosition.right = objPlayer.objPaddle.objElement.width() + objPaddlePosition.left

        if objPaddlePosition.top < objPosition.top and objPaddlePosition.bottom > objPosition.bottom
          if objPlayer.strPosition == 'left' and objPosition.left <= objPaddlePosition.right
            console.log('Point ' + objPlayer.strName)
            objApp.objBoard.objScoreBoard.addPoint(objPlayer.intId)
            @stopBall()
            for objPlayer in objApp.objBoard.arrPlayers
              objPlayer.objPaddle.resetPaddle()
            break

          else if objPlayer.strPosition == 'right' and objPosition.right >= objPaddlePosition.left
            console.log('Point ' + objPlayer.strName)
            objApp.objBoard.objScoreBoard.addPoint(objPlayer.intId)
            @stopBall()
            for objPlayer in objApp.objBoard.arrPlayers
              objPlayer.objPaddle.resetPaddle()
            break

      fltTop = objPosition.top + (parseFloat(intY) * @intYModifier)
      fltLeft = objPosition.left + (parseFloat(intX) * @intXModifier)

      @objElement
        .css('top', fltTop + 'px')
        .css('left', fltLeft + 'px')

    stopBall: ->
      clearInterval @evtMoveBall

      setTimeout(->
        objApp.objBoard.objBall.startMoving()
      , 3000)

    getRandomNumber: (intMin, intMax, fnCallback)->
      intRange = Math.random() * (intMax - intMin) + intMin

      fnCallback(intRange) if fnCallback?

  class Paddle
    @objElement = null
    @fltHeight = null
    @strPosition = null
    @objLocation = null
    @objControls = null
    @evtControl = null

    constructor: (objOptions)->
      @fltHeight = 50.0

      @fltHeight = objOptions.fltHeight if objOptions.fltHeight?
      @strPosition = objOptions.strPosition if objOptions.strPosition?

      @objElement = $('<div class="paddle"></div>')
        .css('height', @fltHeight)
        .css('top', 0)

      if @strPosition == 'left'
        @objElement.css('left', 0)
        @objControls =
          up: '87' # w
          down: '83' #s
      else
        @objElement.css('right', 0)
        @objControls =
          up: '38' # up arrow
          down: '40' # down arrow

      @arrEvents =
        evtUp: null
        evtDown: null

    resetPaddle: ->
      @objElement
        .css('height', @fltHeight)
        .css('top', (objApp.objBoard.objElement.height() / 2) - (@objElement.height() / 2))

    movePaddle: (intY)->
      objPosition = @objElement.position()
      objPosition.bottom = @objElement.height() + objPosition.top
      objBoardPosition = objApp.objBoard.objElement.position()
      objBoardPosition.bottom = objApp.objBoard.objElement.height() + objBoardPosition.top

      if intY < 0 and objPosition.top <= objBoardPosition.top
        return false
      else if intY > 0 and objPosition.bottom >= objBoardPosition.bottom
        return false



      @objElement
        .css('top', objPosition.top + intY)

    growPaddle: (intY)->
      objPosition = @objElement.position()
      objPosition.bottom = @objElement.height() + objPosition.top
      objBoardPosition = objApp.objBoard.objElement.position()
      objBoardPosition.bottom = objApp.objBoard.objElement.height() + objBoardPosition.top

      intGrow = intY / 2

      if objPosition.top <= objBoardPosition.top
        @objElement
          .css('height', @objElement.height() + intY)
        return false
      else if intY > 0 and objPosition.bottom >= objBoardPosition.bottom
        @objElement
          .css('top', objPosition.top - intY)
          .css('height', @objElement.height() + intY)
        return false

      @objElement
        .css('top', objPosition.top - intGrow)
        .css('height', @objElement.height() + intY)

  class Player
    @intId = null
    @strName = null
    @strColor = null
    @strPosition = null
    @objPaddle = null

    constructor: (objOptions)->
      @strColor = '#ffffff'

      @intId = objOptions.intId if objOptions.intId?
      @strName = objOptions.strName if objOptions.strName?
      @strColor = objOptions.strColor if objOptions.strColor?
      @strPosition = objOptions.strPosition if objOptions.strPosition?

      @objPaddle = new Paddle(
        strPosition: @strPosition
      )
      @objPaddle.objElement.attr 'data-player-id', @intId if @intId?
      @objPaddle.objElement.css 'background-color', @strColor

  class ScoreBoard
    @objElement = null
    @objPlayerScores = null

    constructor: ->
      @objPlayerScores = {}
      @objElement = $('<div class="scoreboard"></div>')

    resetScoreBoard: ->
      objPlayer.intScore = 0 for intPlayerId, objPlayer of @objPlayerScores
      @changed()

    changed: ->
      for objPlayerId, objPlayerScore of @objPlayerScores
        @objElement.find(".score[data-player-id=#{objPlayerScore.intId}]").html objPlayerScore.intScore

      @objElement.css('opacity', 1)

      setTimeout(->
        objApp.objBoard.objScoreBoard.objElement.css('opacity', 0)
      , 1500)

    addPoint: (intPlayerId)->
      @objPlayerScores[intPlayerId].intScore++
      @changed()


  objApp = {}

  $(document).ready ->
    objPlayer1 = new Player
      intId: 1
      strName: 'Player 1'
      strPosition: 'left'


    objPlayer2 = new Player
      intId: 2
      strName: 'Player 2'
      strPosition: 'right'

    objApp.objBoard = new Board $('.js-board')

    objApp.objBoard.addPlayer objPlayer1
    objApp.objBoard.addPlayer objPlayer2

    objApp.objBoard.addScoreBoard new ScoreBoard

    objApp.objBoard.startGame()

    console.log(objApp.objBoard)

) jQuery