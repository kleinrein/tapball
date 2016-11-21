-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )


-- include the Corona "composer" module
local composer = require "composer"
local highscores = require( "highscores" )

highscores = { 0 }
highscores = loadHighscores()

math.randomseed( os.time() )

-- load menu screen
composer.gotoScene( "menu" )
