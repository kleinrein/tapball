-----------------------------------------------------------------------------------------
--
-- powerups.lua
--
-----------------------------------------------------------------------------------------

-- modular class
local powerups = {}

-- tables
local coinRainTable = {}
local coinBlazeTable = {}
local timers = {}

-- groups
local coinBlazeGroup = nil

-- gem powers
local gemPowers = { "SpikedEnemy", "coinBlaze", "coinRain" }

-- sounds
local coinSound = audio.loadSound( "audio/coin.mp3" )

function powerups.randGemPower()
    local randGemPower = math.random( #gemPowers )
    local gemPower = gemPowers[randGemPower]
    chooseGemPowers( gemPower )
end

--[[
    chooseGemPowers
--]]
function chooseGemPowers( gemPower )
  
  if gemPower == "SpikedEnemy" then
    spawnEnemy()
  elseif gemPower == "coinBlaze" then
    coinBlaze()
  elseif gemPower == "coinRain" then
    coinRain()  
  end

end

--[[
    spawnEnemy
--]]
function spawnEnemy()
  displayPowerText( "WATCH OUT" )

  -- warn player
  local spikeballX = math.random ( 5 , display.contentWidth - 5)

  local spikeballWarn = display.newRect( spikeballX, 0, 10, 7 )
  spikeballWarn.fill = { 1, 0, 0.5 }

  local spikeball = nil

  local function spiked(event)
    if event.other.name == "ball" then
      explodeBall()
      display.remove( spikeball )
    end

    if event.other.name == "grass" then
      -- remove spikeball when it hits the grass
      local function removeSpikeball()
        display.remove( spikeball )
        spikeball = nil
      end
      transition.to( spikeball, { time=10, alpha=0, onComplete=removeSpikeball } )
    end
  end

  local function showSpikeball()
      spikeball = display.newImageRect( "graphics/spike-ball.png", 25, 25 )

      spikeball.x, spikeball.y = spikeballX, -10
      spikeball.name = "spikeball"

      physics.addBody( spikeball, { bounce = 0.6, friction = 0.3, density = 0.2, radius = 10})

      spikeball:addEventListener("collision", spiked)
  end

  -- warn enemy transition
  transition.to( spikeballWarn, { time=2000, xScale=8, alpha=0, onComplete=showSpikeball, transition=easing.inQuad } )
end

--[[
    coinRain
--]]
function coinRain()
  -- coin catch group
  local coinRainGroup = display.newGroup()

  displayPowerText( "CONRAIN" )

  -- warn player
  local coinX = math.random ( 5 , display.contentWidth - 5)

  local coinRainAlert = display.newRect( coinX, 0, 10, 7 )
  coinRainAlert.fill = { 0, 1, 0.5 }

  local function showCoinRain()
    for i=1,15 do
      timer.performWithDelay( 1, spawnExtraCoin(coinX) )
    end
  end

  -- alert coin rain transition
  transition.to( coinRainAlert, { time=2500, xScale=8, alpha=0, onComplete=showCoinRain, transition=easing.inQuad } )
end

--[[
    coinBlaze
--]]
function coinBlaze()
  -- coin rain group
  coinBlazeGroup = display.newGroup()

  displayPowerText( "COINBLAZE" )
  
  local timerVal = 5
  local timerValText = display.newText( timerVal , display.contentCenterX, 10, native.systemFont, 24 )

  local function coinBlazeBlaze()
    for i=1,15 do
      timer.performWithDelay( 1, spawnExtraCoin() )
    end
  end

  local function coinBlazeTimer()
    timerVal = timerVal - 1
    timerValText.text = timerVal

    print( timerVal )

    if timerVal == 0 then
      -- clear coins
      for i = 1, #coinBlazeTable do
        print( "remove extra coins.." )
        display.remove( coinBlazeTable[i] )
      end

      -- clear table
      coinBlazeTable = {}

      -- clear coinBlazeGroup
      if (coinBlazeGroup ~= nil) then
        coinBlazeGroup:removeSelf()
        coinBlazeGroup = nil
      end

      text = nil

      display.remove( timerValText )
      timerValText = nil
    end
  end
  timer.performWithDelay( 1000, coinBlazeTimer, 5 )
  timer.performWithDelay( 450, coinBlazeBlaze )

  -- add to group
  coinBlazeGroup:insert( timerValText )
end

function spawnExtraCoin(x)
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
    name = "coin",
    start = 1,
    count = 6,
    time = 600,
    loopCount = 0,
    loopDirection = "bounce"
  }

  local coin = display.newSprite( coinSheet, sequenceData )

  if x ~= nil then
    coin.x = x + math.random ( -5, 5)
    coin.y = math.random(-1000, -700 )
  else
    coin.x = math.random ( 10 , display.contentWidth - 10 )
    coin.y = math.random( 100, display.contentHeight - 100 )
  end

  coin:play()

  local function hitCoin(event)
    if event.other.name == 'ball' then
      -- play coin sound
      audio.play(coinSound)

      updateScore(5)
      transition.to( coin, { time=50, xScale = 1.5, yScale = 1.5 } )
      transition.dissolve( coin )

      display.remove( coin )
    end
  end

  local function addBodyToCoin()
    if x ~= nil then
      physics.addBody( coin, { isSensor = true, friction = 0.3, density = .001, radius = 10}  )
    else
      physics.addBody( coin, "static", { isSensor = true, radius = 10} )
    end
    coin:addEventListener( "collision", hitCoin )
  end

  timer.performWithDelay( 1, addBodyToCoin )

  -- add coin to table for tracking purposes
  if x ~= nil then
    coinRainTable[#coinRainTable+1] = coin
  else
    coinBlazeTable[#coinBlazeTable+1] = coin
  end
  
end

function displayPowerText(text)
local paint = {
    type = "gradient",
    color1 = { 0, 0, 1, 1 },
    color2 = { 0, 1, 0, 1 },
    direction = "down"
}
  local powerText = display.newText( text , display.contentCenterX, 200, native.systemFont, 22 )
  powerText:setFillColor( paint )

  local function removePowerText()
    display.remove( powerText )
  end

  transition.scaleTo( powerText, { xScale = 3, yScale = 3, alpha=0, time = 600, transition = easing.inOutExpo, onComplete=removePowerText } )
end

function powerups.clearDisplay()
  print(coinRainGroup)
  if coinBlazeGroup ~= nil then
      -- clear coins
      for i = 1, #coinBlazeTable do
        print( "remove extra coins.." )
        display.remove( coinBlazeTable[i] )
      end
      
      -- clea timers
      for id, value in pairs(timer._runlist) do
        timer.cancel(value)
      end

      -- clear table
      coinBlazeTable = nil

      coinBlazeGroup:removeSelf()
      coinBlazeGroup = nil

  end
end

-- return powerups
return powerups