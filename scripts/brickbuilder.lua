-----------------------------------------------------------------------------------------
--
-- brickbuilder.lua
-- Handles all bricklaying
-- 
-----------------------------------------------------------------------------------------

-- modular class
local brickbuilder = {}

local gameGr

function brickbuilder.layBricks( game )
    gameGr = game

    for i = 0, -800, -400 do
        layBrickWidth(i)
    end
end

function layBrickWidth( y ) 
    local brickWidth = display.contentWidth / 5
    for i = 0, display.contentWidth, brickWidth do
       if (i < 50 or i > 150) then
            layBrick(i, y, brickWidth)
        end
    end
end


function layBrick( x, y, width ) 
    local brick = display.newImageRect( "sprites/spikes-wood.png", width, 40 )
    brick.x, brick.y = x, y
    physics.addBody( brick, "static", { density = 0, friction = 0, bounce = 0 } )

    gameGr:insert( brick )
    brick:toFront()
end

-- return brickbuilder
return brickbuilder