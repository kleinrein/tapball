-----------------------------------------------------------------------------------------
--
-- btnanimations.lua
-- Handles button animations
--
-----------------------------------------------------------------------------------------

-- modular class    
local btnanimations = {}

function btnanimations.shrinkBtnAnimation( event, element )
  -- shrink button on touch
  if ( event.phase == "began" ) then
    transition.to( element, { xScale = .9, yScale = .9, time = 250, transition = easing.outQuart } )
  elseif ( event.phase == "ended" ) then
    local function back()
      transition.to( element, { xScale = 1, yScale = 1, time = 150, transition = easing.outQuart } )
    end
    transition.to( element, { xScale = 1.05, yScale = 1.05, time = 150, transition = easing.outQuart, onComplete=back } )
  end
end

-- return audio
return btnanimations