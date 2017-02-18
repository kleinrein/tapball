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

-- master group
local game = display.newGroup()
game.x = 0

-- other files
local powerups
local audiohandler = require( "scripts.audiohandler" )
local btnanimations = require( "scripts.btnanimations" )

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
  coin.y = math.random (display.contentHeight - 450)

  coin:play()

  local function hitCoin(event)
    if event.other.name == 'ball' then

      -- play coin sound
      audiohandler.coin()

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

  game:insert(coin)
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
  gem.y = math.random ( display.contentHeight - 450 )

  gem:play()

  local function hitGem(event)
    if event.other.name == 'ball' then
      display.remove( gem )
      timer.performWithDelay( 100, powerups.randGemPower(game) )
    end
  end

  -- collision event
  gem:addEventListener( "collision", hitGem )

  -- add to gemTable
  gemTable[#gemTable+1] = gem

  game:insert(gem)
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
  physics.setGravity( 0, 12 )

  print('level1 create')

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
  ball = display.newImageRect( "graphics/ball.png", 80, 80 )
  ball.x, ball.y = math.random(display.contentWidth - 50), 100
  ball.name = "ball"
  ball.linearDamping = 10
  ball.angularAcceleration = 1.05
  ball.angularMax = 10
  ball.linearDamping = 0.5
  ball.angularDamping = 0.9
  ball.rotation = math.random(-5, 5)
  
  -- add physics to the ball
  physics.addBody( ball, { bounce = 0.75, friction = 0.3, density = 1.0, radius = 40})

  ball:addEventListener("touch", pushBall)

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
      audiohandler.gameover()
      endgame()
    end
  end

  -- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
  grassShape = { -halfW,-10, halfW,-10, halfW,34, -halfW,34 }
  grassShape.name = "grassShape"
  physics.addBody( grass, "static", { density = 1, friction=0.3, shape=grassShape } )

  -- create right and left collision boxes
  collisionLeft = display.newRect( 0, display.contentCenterY, 0, display.actualContentHeight * 5000 )
  collisionRight = display.newRect( display.actualContentWidth, display.contentCenterY, 0, display.actualContentHeight * 5000 )
  collisionTop = display.newRect( display.contentCenterX, -500, display.actualContentWidth, 0 )

  local aurora = display.newImageRect("graphics/aurora.png", display.contentWidth, 600)
  aurora.x, aurora.y = display.contentCenterX, -500

  aurora.fill.effect = "filter.linearWipe"
  aurora.fill.effect.direction = { 0, 1 }
  aurora.fill.effect.smoothness = 1
  aurora.fill.effect.progress = 0.5

  physics.addBody( collisionRight, "static", { density = 0, friction = 0, bounce = 0 } )
  physics.addBody( collisionLeft, "static", { density = 0, friction = 0, bounce = 0 })

  -- eventlistener when ball collide with grass
  ball.collision = onCollision
  ball:addEventListener( "collision" )

  -- lay bricks
  --local brickBuilder = require( "scripts.brickbuilder" )
  --brickBuilder.layBricks(game)

  -- all display objects must be inserted into group
  sceneGroup:insert( background )
  game:insert( grass)
  game:insert( collisionLeft )
  game:insert( collisionRight )
  game:insert( collisionTop )
  game:insert( aurora )
  game:insert( ball )

  -- add top to body
  physics.addBody ( collisionTop, "static", { density = 0, bounce = 0, friction = 0 } )
  game:insert( collisionTop )

end

function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  composer.removeHidden()

  lost = false

  -- update audio pref
  audiohandler.update()
  
  powerups = nil

  -- init powerups
  powerups = require( "scripts.powerups" )

  if phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
  elseif phase == "did" then
    -- Called when the scene is now on screen
    --
    -- INSERT code here to make the scene come alive
    -- e.g. start timers, begin animation, play audio, etc.
    physics.start(true)

    -- score label
    scoreTxt = display.newText {
      text = "Score 0",
      x = 60,
      y = 0,
      font = "pixelsplitter.ttf",
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


function pushBall( event )
  if (ball ~= nil and event.phase == "began") then
    local force
    local xMin, xMax = event.x - 10, event.x + 10

    print(xMin .. "|" .. xMax .. "|" .. event.x .. "|" .. ball.x)
    force = (event.x < ball.x) and 3 or -3

    if (xMin <= ball.x and xMax >= ball.x) then
      force = 0
    end

    transition.to( ball, { time = 10, xScale = 1.1, yScale = 1.1, transition=easing.outQuad } )
    transition.from( ball, {time = 10, xScale = 0.9, yScale = 0.9, transition = easing.outQuad } )

    -- apply gravity linear impulse
    ball:applyLinearImpulse( force, -15, ball.x, ball.y )

    -- apply gravity angular impulse
    ball:applyAngularImpulse( force )
    
    audiohandler.jump()
    updateScore(1)
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

  game:removeSelf()

  score = nil
  lost = nil

  -- elements
  grass = nil

  -- remove ball and top collision
  display:remove(ball)
  ball = nil

  spikeball = nil
  background = nil
  grassShape = nil
  scoreTxt:removeSelf()

  -- physics clear
  physics.stop()
  package.loaded[physics] = nil
  physics = nil

  -- dispose audio
  audiohandler.dispose()

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

function explodeBall()
  transition.to( ball, { time=300, xScale= 1.5, yScale=1.5, alpha=0 } )

  endgame()
end

function endgame()
  print( "endgame " .. tostring(lost) )

  if lost == false then
    lost = true
    for id, value in pairs(timer._runlist) do
      timer.cancel(value)
      Runtime:removeEventListener( "enterFrame", moveCamera )
    end
    -- show you lost dialog
    lostDialog()
  end
end

function lostDialog()
  -- clear powerups display
  powerups.clearDisplay() 

  print( "lostdialog " .. tostring(lost) )
  local dialogGroup = display.newGroup()

  -- TODO fix removing event listeners properly
  -- remove event listener for ball
  ball:removeEventListener( "collision" )
  ball.name = 'ball_lost'

  -- dialog
  local dialog = display.newRect( 0, 0, display.contentWidth, display.contentHeight + 100 )
  dialog:setFillColor( 0, 0, 0, .5 )
  dialogGroup:insert( dialog )

  dialog.fill.effect = "filter.blur"
  dialog.x, dialog.y = display.contentCenterX, display.contentCenterY
  dialog.alpha = 0

  -- show lost dialog
  local lostDialog = display.newImageRect( "graphics/lost-dialog-frame.png", display.contentWidth - 50, display.contentHeight / 1.5 )
  lostDialog.x, lostDialog.y = display.contentCenterX, display.contentCenterY
  dialogGroup:insert( lostDialog )

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
    defaultFile = "graphics/restart-btn.png",
    width=120, height=35,
    onRelease = restartGame
  }

  local quit = widget.newButton {
    defaultFile = "graphics/quit-btn.png",
    width=120, height=35,
    onRelease = quitGame,
    x = display.contentCenterX
  }

  restart.x = display.contentCenterX
  quit.x = display.contentCenterX

  restart.y = display.contentHeight - 180
  quit.y = display.contentHeight - 130

  local function onRestartBtnTouch( event )
    btnanimations.shrinkBtnAnimation( event, restart )
  end

  local function onQuitBtnTouch( event )
    btnanimations.shrinkBtnAnimation( event, quit )
  end

  -- btn touch transitions
  restart:addEventListener( "touch", onRestartBtnTouch )
  quit:addEventListener( "touch", onQuitBtnTouch )

  -- animate restart button
 -- transition.to( restart, { y= restart.y - 2, xScale=1.1, yScale=1.1, time=1000, iterations=-1 } )

  -- score label
  -- show highscore
  local highscore = system.getPreference( "app", "highscore_level1", "number" )
  local appPreferences = {
    highscore_level1 = score
  }

  local function newHighScore()
    local newHighScore = display.newImageRect( "graphics/lost-dialog-new-highscore.png", 200, 20 )
    newHighScore.x, newHighScore.y = display.contentCenterX, display.contentCenterY - 125
    transition.blink(newHighScore)

    dialogGroup:insert( newHighScore )
  end

  if highscore ~= nil then
    if score > highscore then
      system.setPreferences( "app", appPreferences )
      highscore = score
      newHighScore()
    end
  else
    system.setPreferences( "app", appPreferences )
    highscore = score
    newHighScore()
  end
  
  local highScore = display.newText( "High: " .. highscore, 100, 200, "pixelsplitter.ttf", 16 )

  -- show your score
  local yourScore = display.newText( "Score: " .. score, 100, 200, "pixelsplitter.ttf", 14 )

  yourScore.x, yourScore.y = display.contentCenterX, display.contentCenterY - 75
  highScore.x, highScore.y = display.contentCenterX, display.contentCenterY - 10

  -- yourscore animation
  yourScore.alpha = 0
  transition.to( yourScore, { xScale=1.75, yScale=1.75, alpha=1.0, rotation=math.random(-5, 5), time=500} )

  -- insert objects into scenegroup
  dialogGroup:insert( restart )
  dialogGroup:insert( quit )
  dialogGroup:insert( highScore )
  dialogGroup:insert( yourScore )
end

local function moveCamera()
  
  if ball == nil then
    Runtime:removeEventListener( "enterFrame", onFrame )
  end
  if (ball ~= nil and ball.y < 200) then
    game.y = -ball.y + 200
  end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

Runtime:addEventListener( "enterFrame", moveCamera )

-----------------------------------------------------------------------------------------

return scene
