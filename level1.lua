-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

-- corona libraries
local composer = require( "composer" )
local widget = require( "widget" )
local physics = require( "physics" )
local scene = composer.newScene()

-- other files
local powerups = require( "scripts.powerups" )

-- variables
local scoreTxt
local score = 0
local lost = false

-- elements
local background
local grass
local ball
local grassShape
local coin

-- tables
local coinTable = {}
local gemTable = {}

local collisionRight
local collisionLeft
local collisionTop

-- timers
local coinTimer

-- sounds
local jump = audio.loadSound( "audio/jump.mp3" )
local coinSound = audio.loadSound( "audio/coin.mp3" )
local gameOverSound = audio.loadSound( "audio/gameover.mp3" )

-- constants
local gravity = 30
local forceHit = -10

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function updateScore(s)
  score = score + s
  scoreTxt.text = "Score: " .. score
end

function spawnCoin()
  local options =
  {
    width = 20,
    height = 20,
    numFrames = 6
  }
  local coinSheet = graphics.newImageSheet( "sprites/coin.png", options )

  -- coin sprite
  local sequenceData =
  {
    name="coin",
    start=1,
    count=6,
    time=600,
    loopCount = 0,
    loopDirection = "bounce"
  }

  coin = display.newSprite( coinSheet, sequenceData )
  math.random()
  coin.x = math.random ( 10 , display.contentWidth - 10)
  coin.y = math.random (display.contentHeight - 150)

  coin:play()

  local function hitCoin(event)
    if event.other.name == 'ball' then

      -- play coin sound
      audio.play(coinSound)

      updateScore(5)
      transition.to( coin, { time=50, xScale = 1.5, yScale = 1.5 } )
      transition.dissolve( coin )

      display.remove( coin )

      -- new coin timer
      math.random()
      local randTime = math.random(1500, 4000)
      coinTimer = timer.performWithDelay( randTime, spawnCoin() )

      -- spawn gem or not
      local randNum = math.random(2)
      if randNum == 1 then
        spawnGem()
      end
    end
  end

  local function addBodyToCoin()
    physics.addBody( coin, "static", { isSensor = true, radius = 10} )
    coin:addEventListener( "collision", hitCoin )
  end

  timer.performWithDelay( 50, addBodyToCoin )

  -- add coin to table for tracking purposes
  coinTable[#coinTable+1] = coin
end

function spawnGem()
  local options =
  {
    width = 16,
    height = 16,
    numFrames = 8
  }
  local gemSheet = graphics.newImageSheet( "sprites/gem-green.png", options )

  -- gem sprite
  local sequenceData =
  {
    name="coin",
    start=1,
    count=8,
    time=500,
    loopCount = 0,
    loopDirection = "bounce"
  }

  local gem = display.newSprite( gemSheet, sequenceData )

  local function addBodyToGem()
    physics.addBody( gem, "static", { isSensor = true } )
  end

  timer.performWithDelay( 50, addBodyToGem )

  gem.x = math.random ( 10 , display.contentWidth - 10)
  gem.y = math.random ( display.contentHeight - 150 )

  gem:play()

  local function hitGem()
    display.remove( gem )
    timer.performWithDelay( 100, powerups.randGemPower() )
  end

  -- collision event
  gem:addEventListener( "collision", hitGem )

  -- add to gemTable
  gemTable[#gemTable+1] = gem
end


function scene:create( event )

  -- Called when the scene's view does not exist.
  --
  -- INSERT code here to initialize the scene
  -- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

  local sceneGroup = self.view

  -- We need physics started to add bodies, but we don't want the simulaton
  -- running until the scene is on the screen.
  physics.start()
  physics.pause()

  -- create a grey rectangle as the backdrop
  -- the physical screen will likely be a different shape than our defined content area
  -- since we are going to position the background from it's top, left corner, draw the
  -- background at the real top, left corner.
  local background = display.newImageRect( "graphics/level1-bg.png", display.actualContentWidth, display.actualContentHeight )
  background.anchorX = 0
  background.anchorY = 0
  background.x = 0 + display.screenOriginX
  background.y = 0 + display.screenOriginY

  -- make a ball (off-screen), position it, and rotate slightly
  ball = display.newImageRect( "ball.png", 80, 80 )
  ball.x, ball.y = 160, -100
  ball.name = "ball"
  ball.linearDamping = 10000

  -- add physics to the ball
  physics.addBody( ball, { bounce = 0.7, friction = 0.3, density = 1.0, radius = 40})

  local function push( event )

    local force
    if event.x < ball.x then
      force = 400
    else
      force = -400
    end

    if event.x == ball.x then
      force = 0
    end


    transition.to( ball, { time = 10, xScale = 1.1, yScale = 1.1, transition=easing.outQuad } )
    transition.from( ball, {time = 10, xScale = 0.9, yScale = 0.9, transition = easing.outQuad } )

    ball:applyForce( force, -3250, ball.x, ball.y )
    audio.play( jump )
    updateScore(1)
  end

  ball:addEventListener("tap", push)

  -- create a grass object and add physics (with custom shape)
  grass = display.newImageRect( "graphics/grass.png", screenW, 60 )
  grass.anchorX = 0
  grass.anchorY = 1
  grass.name = "grass"

  -- draw the grass at the very bottom of the screen
  grass.x, grass.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY

  local function onCollision(self, event)
    -- end game if ball collide with grass
    if event.other.name == "grass" then
      audio.play( gameOverSound )
      -- endgame()
    end
  end

  -- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
  grassShape = { -halfW,-10, halfW,-10, halfW,34, -halfW,34 }
  grassShape.name = "grassShape"
  physics.addBody( grass, "static", { density = 1, friction=0.3, shape=grassShape } )

  -- create right and left collision boxes
  collisionLeft = display.newRect( 0, display.contentCenterY, 0, display.actualContentHeight )
  collisionRight = display.newRect( display.actualContentWidth, display.contentCenterY, 0, display.actualContentHeight )
  collisionTop = display.newRect( display.contentCenterX, -100, display.actualContentWidth, 1 )

  physics.addBody( collisionRight, "static", { density = 1, friction = 0.3} )
  physics.addBody( collisionLeft, "static", { density = 1, friction = 0.3})

  -- eventlistener when ball collide with grass
  ball.collision = onCollision
  ball:addEventListener( "collision" )

  -- all display objects must be inserted into group
  sceneGroup:insert( background )
  sceneGroup:insert( grass)
  sceneGroup:insert( ball )

  -- add top body after some time
  local function addTopBody()
    physics.addBody ( collisionTop, "static", { density = 1, bounce = 0 } )
  end

  timer.performWithDelay( 1500, addTopBody )

  -- enemy test
  -- spawnEnemy()
end

function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  composer.removeHidden()

  lost = false

  if phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
  elseif phase == "did" then
    -- Called when the scene is now on screen
    --
    -- INSERT code here to make the scene come alive
    -- e.g. start timers, begin animation, play audio, etc.
    physics.start()
    physics.setGravity(0, gravity)
    physics.setPositionIterations( 16 )

    -- score label
    scoreTxt = display.newText {
      text = "Score 0",
      x = 60,
      y = 0,
      font = "8bit",
      fontSize = 12,
      align = "left"
    }

    -- random coins
    math.random()
    local randTime = math.random(1500, 4000)
    coinTimer = timer.performWithDelay( randTime, spawnCoin() )

    sceneGroup:insert( scoreTxt )
  end
end

function scene:hide( event )
  local sceneGroup = self.view

  local phase = event.phase

  if event.phase == "will" then
    -- Called when the scene is on screen and is about to move off screen
    --
    -- INSERT code here to pause the scene
    -- e.g. stop timers, stop animation, unload sounds, etc.)
    physics.stop()
  elseif phase == "did" then
    -- Called when the scene is now off screen
  end

end

function scene:destroy( event )
  -- Called prior to the removal of scene's "view" (sceneGroup)
  --
  -- INSERT code here to cleanup the scene
  -- e.g. remove display objects, remove touch listeners, save state, etc.
  local sceneGroup = self.view

  package.loaded[physics] = nil
  physics = nil
  score = nil
  lost = nil

  -- elements
  grass = nil
  ball = nil
  spikeball = nil
  background = nil
  grassShape = nil
  scoreTxt:removeSelf()

  -- dispose audio
  audio.dispose( jump )
  audio.dispose( coinSound )

  -- remove coins
  for i = 1, #coinTable do
    display.remove( coinTable[i] )
  end
  coinTable = nil

  -- remove gems
  for i = 1, #gemTable do
    display.remove( gemTable[i] )
  end
  gemTable = nil

  coinExtraTable = nil

  if coin ~= nil then display.remove(coin) end
end

function endgame()
  print( "endgame " .. tostring(lost) )

  if lost == false then
    lost = true
    for id, value in pairs(timer._runlist) do
      timer.cancel(value)
    end
    -- show you lost dialog
    lostDialog()
  end
end

function lostDialog()
  print( "lostdialog " .. tostring(lost) )
  local dialogGroup = display.newGroup()

  -- TODO fix removing event listeners properly
  -- remove event listener for ball
  ball:removeEventListener( "collision" )
  ball.name = 'ball_lost'

  -- dialog
  local dialog = display.newRect( 0, 0, display.contentWidth, display.contentHeight + 100 )
  dialog:setFillColor( 0, 0, 0, .5 )

  dialog.fill.effect = "filter.blur"
  dialog.x, dialog.y = display.contentCenterX, display.contentCenterY
  dialog.alpha = 0

  transition.to( dialog, { alpha=1, time=200, transition=easing.outExpo} )

  local function removeDialog()
    dialogGroup:removeSelf()
    dialogGroup = nil
    composer.removeScene( "level1" )
  end

  local function quitGame()
    removeDialog()
    composer.gotoScene( "menu" )
  end

  local function restartGame()
    removeDialog()
    composer.gotoScene( "level1" )
  end

  -- buttons
  local restart = widget.newButton {
    label="Restart",
    font = "8bit",
    labelColor= { default={ 255,255,255}, over={ 255, 255, 255, 0.5 } },
    emboss=true,
    width=120, height=30,
    onRelease = restartGame
  }

  local quit = widget.newButton {
    label="Quit",
    font="8bit",
    labelColor= { default={ 255,255,255}, over={ 255, 255, 255, 0.5 } },
    emboss=true,
    width=120, height=30,
    onRelease = quitGame,
    x = display.contentCenterX
  }

  restart.x = display.contentCenterX
  quit.x = display.contentCenterX

  restart.y = display.contentHeight - 180
  quit.y = display.contentHeight - 140

  -- animate restart button
  transition.to( restart, { xScale=1.05, yScale=1.05, time=500, iterations=-1 } )

  -- transition.to( restart, { xScale=1.2, yScale=1.2, time=1000, onComplete=fromAnimRestart} )

  -- score label
  local highScore = display.newText( "High: " .. 40, 100, 200, "8bit", 16 )
  local yourScore = display.newText( "Score: " .. score, 100, 200, "8bit", 14 )

  yourScore.x = display.contentCenterX
  highScore.x = display.contentCenterX

  yourScore.y = display.contentCenterY - 100
  highScore.y = display.contentCenterY - 10

  -- yourscore animation
  yourScore.alpha = 0
  transition.to( yourScore, { xScale=1.75, yScale=1.75, alpha=1.0, rotation=math.random(-5, 5), time=500} )

  -- insert objects into scenegroup
  dialogGroup:insert( dialog )
  dialogGroup:insert( restart )
  dialogGroup:insert( quit )
  dialogGroup:insert( highScore )
  dialogGroup:insert( yourScore )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
