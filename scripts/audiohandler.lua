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
local jumpSound = audio.loadSound( "audio/jump.mp3" )
local coinSound = audio.loadSound( "audio/coin.mp3" )
local gameOverSound = audio.loadSound( "audio/gameover.mp3" )

function audiohandler.jump()
  if prefSound then
    audio.play( jump )
  end
end

function audiohandler.coin()
  if prefSound then
    audio.play( coinSound )
  end
end

function audiohandler.gameover()
  if prefSound then
    audio.play( gameOverSound )
  end
end

function audiohandler.dispose()
  -- dispose audio
  audio.dispose( jumpSound )
  audio.dispose( coinSound )
  audio.dispose( gameOverSound )
end

-- return audio
return audiohandler