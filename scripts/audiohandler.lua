-----------------------------------------------------------------------------------------
--
-- audiohandler.lua
-- Handles all audio playback
--
-----------------------------------------------------------------------------------------

-- modular class
local audiohandler = {}
local prefSound = system.getPreference( "app", "prefSound", "boolean" )

-- sounds
local jumpSound = audio.loadSound( "./audio/jump.mp3" )
local coinSound = audio.loadSound( "./audio/coin.mp3" )
local gameOverSound = audio.loadSound( "./audio/gameover.mp3" )
local introSound = audio.loadSound( "./audio/intro.mp3" )

function audiohandler.update()
  prefSound = system.getPreference( "app", "prefSound", "boolean" )
end

function audiohandler.jump()
  print('prefSound ' .. tostring(prefSound))
  if prefSound == true then
    audio.play( jumpSound )
  end
end

function audiohandler.coin()
  if prefSound == true then
    audio.play( coinSound )
  end
end

function audiohandler.gameover()
  if prefSound == true then
    audio.play( gameOverSound )
  end
end

function audiohandler.intro()
  if prefSound == true then
    audio.play( introSound )
  end
end

function audiohandler.dispose()
  -- dispose audio
end

-- return audiohandler
return audiohandler