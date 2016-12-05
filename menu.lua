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

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()

	-- go to level1.lua scene
	composer.gotoScene( "level1", "crossFade", 250 )

	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	physics.start()
  	physics. pause()
	physics.setGravity(0, 20)
	  -- physics.setDrawMode( "hybrid" )

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
   local titleLogo = display.newImageRect( "logo.png", 180, 25 )
   titleLogo.x = display.contentCenterX
   titleLogo.y = 120

	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="",
		labelAlign="center",
		labelColor = { default={255}, over={128} },
		defaultFile="graphics/play-btn.png",
		overFile="graphics/play-btn-hover.png",
		width=120, height=30,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight - 125
	playBtn.name = "playBtn"

	-- create a physics body 
	local playBtnBody = display.newRect(display.contentCenterX, display.contentHeight - 125, 125, 60)
	playBtnBody.alpha = 0
	physics.addBody( playBtnBody, "static", { density = 1, friction = 1} )


	-- load the ball
   local ball = display.newImageRect( "ball.png", 60, 60 )
   ball.x = display.contentCenterX + math.random(-20, 20)
   ball.y = 60

   local function addBodyToBall()
	physics.addBody( ball, { bounce = 1, friction = 0.6, density = 1.0, radius = 10.0})
   end

   local function onCollision(self, event)
   		local function goUp()
		   if playBtn ~= nil then
				transition.to( playBtn, { time=150, y=playBtn.y - 5} )
		   end
		end
      transition.to( playBtn, { time=150, y=playBtn.y + 5, onComplete=goUp, transition=easing.outExpo } )
  end

   ball.collision = onCollision
   ball:addEventListener( "collision" )

   timer.performWithDelay( 250, addBodyToBall )

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( ball )
	sceneGroup:insert( playBtnBody )
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
		playBtn:removeSelf()	-- widgets must be manually removed
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
