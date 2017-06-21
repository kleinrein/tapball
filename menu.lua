-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local physics = require( "physics" )

-- include Corona's "widget" library
local widget = require "widget"

-- local scripts
local btnanimations = require( "scripts.btnanimations" )
local audiohandler = require( "scripts.audiohandler" )

--------------------------------------------

-- forward declarations and other locals
local playBtn
local myBallBtn
local soundBtn

local imgSoundOn
local imgSoundOff

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
  -- go to level1.lua scene
  composer.gotoScene( "level1", "crossFade", 250 )

  return true -- indicates successful touch
end

local function onMyBallBtnRelease()

end

local function onMyBallBtnTouch( event )
  btnanimations.shrinkBtnAnimation( event, myBallBtn )
end

local function onPlayBtnTouch( event )
  btnanimations.shrinkBtnAnimation( event, playBtn )
end

local function onSoundBtnTouch( event )
  btnanimations.shrinkBtnAnimation( event, soundBtn )
end

local function onSoundOnBtnTap( event )
  -- turn off sound
  if soundBtn.sound then
    soundBtn.sound = false
    soundBtn.fill = imgSoundOff
  else
    soundBtn.sound = true
    soundBtn.fill = imgSoundOn
  end

  local appPreferences = {
    prefSound = soundBtn.sound
  }

  system.setPreferences( "app", appPreferences )
  
  return true
end

function scene:create( event )
  local sceneGroup = self.view

  physics.start()
  physics.pause()
  physics.setScale( 60 )
  --physics.setDrawMode("hybrid")

  -- Called when the scene's view does not exist.
  --
  -- INSERT code here to initialize the scene
  -- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

  -- display a background image
  local background = display.newImageRect( "graphics/intro-bg.png", display.actualContentWidth, display.actualContentHeight )
  background.anchorX = 0
  background.anchorY = 0
  background.x = 0 + display.screenOriginX
  background.y = 0 + display.screenOriginY

  -- create a logo
  local titleLogo = display.newImageRect( "graphics/logo.png", 170, 25 )
  titleLogo.x = display.contentCenterX
  titleLogo.y = 150
  titleLogo.alpha = 0

  transition.to( titleLogo, { time = 1500, xScale = 1.2, yScale = 1.1, alpha = 1 } )

  -- create a widget button (which will loads level1.lua on release)
  playBtn = widget.newButton{
    label="",
    labelAlign="center",
    labelColor = { default={255}, over={128} },
    defaultFile="graphics/play-btn.png",
    overFile="graphics/play-btn.png",
    width=140, height=40,
    onRelease = onPlayBtnRelease -- event listener function
  }
  playBtn.x = display.contentCenterX
  playBtn.y = display.contentHeight - 125
  playBtn.name = "playBtn"
  playBtn:addEventListener( "touch", onPlayBtnTouch )

  myBallBtn = widget.newButton{
    label="",
    labelAlign="center",
    labelColor = { default={255}, over={128} },
    defaultFile="graphics/my-ball-btn.png",
    overFile="graphics/my-ball-btn.png",
    width=140, height=40,
    onRelease = onMyBallBtnRelease -- event listener function
  }
  myBallBtn.x, myBallBtn.y = display.contentCenterX, display.contentHeight - 70
  myBallBtn.name = "myBallBtn"
  myBallBtn:addEventListener( "touch", onMyBallBtnTouch )

  -- create sound on & off buttons
  imgSoundOn = { type="image", filename="graphics/btn-sound-on.png" }
  imgSoundOff = { type="image", filename="graphics/btn-sound-off.png" }

  soundBtn = display.newRect( display.contentWidth - 30, 20, 30, 30 )
  soundBtn.fill = system.getPreference( "app", "prefSound", "boolean" ) and imgSoundOn or imgSoundOff
  soundBtn.sound = true 

  soundBtn:addEventListener( "tap", onSoundOnBtnTap )
  soundBtn:addEventListener( "touch", onSoundBtnTouch )

  -- show highscore
  local highscore = system.getPreference( "app", "highscore_level1", "number" )
  if highscore == nil then highscore = 0 end

  local highScoreText = display.newText {
      text = "Highscore: " .. tostring(highscore),
      x = display.contentCenterX,
      y = 20,
      font = "pixelsplitter.ttf",
      fontSize = 10,
      align = "left"
    }

  -- create a physics body
  local playBtnBody = display.newRect(display.contentCenterX, display.contentHeight - 125, 135, 35)
  playBtnBody.alpha = 0
  physics.addBody( playBtnBody, "static", { density = 1, friction = 1 } )

  -- load the ball
  local ball = display.newImageRect( "graphics/ball.png", 60, 60 )
  ball.x = display.contentCenterX + math.random(-20, 20)
  ball.y = 60

  local function addBodyToBall()
    physics.addBody( ball, { bounce = 0.5, friction = 0.5, density = 1.0, radius = 20.0})
    ball:applyAngularImpulse( math.random ( -5 , 5 ) )
  end

  local function onCollision(self, event)
    local function goUp()
      if playBtn ~= nil then
        transition.to( playBtn, { time = 200, y = playBtn.y - 15 } )
        ball:applyLinearImpulse( 0, -1, ball.x, ball.y )
      end
    end
    transition.to( playBtn, { time = 50, y=playBtn.y + 15, onComplete=goUp, transition=easing.outExpo } )
  end

  ball.collision = onCollision
  ball:addEventListener( "collision" )

  timer.performWithDelay( 250, addBodyToBall )

  -- all display objects must be inserted into group
  sceneGroup:insert( background )
  sceneGroup:insert( titleLogo )
  sceneGroup:insert( playBtn )
  sceneGroup:insert( myBallBtn )
  sceneGroup:insert( ball )
  sceneGroup:insert( playBtnBody )
  sceneGroup:insert( soundBtn )
  sceneGroup:insert( highScoreText )

  -- ball in front
  ball:toFront()
end

function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase
  physics.start()

  composer.removeHidden()

  if phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
  elseif phase == "did" then
    -- Called when the scene is now on screen
    --
    -- INSERT code here to make the scene come alive
    -- e.g. start timers, begin animation, play audio, etc.
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
  elseif phase == "did" then
    -- Called when the scene is now off screen
  end
end

function scene:destroy( event )
  local sceneGroup = self.view

  -- Called prior to the removal of scene's "view" (sceneGroup)
  --
  -- INSERT code here to cleanup the scene
  -- e.g. remove display objects, remove touch listeners, save state, etc.

  if playBtn then
    playBtn:removeSelf() -- widgets must be manually removed
    playBtn = nil
  end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
