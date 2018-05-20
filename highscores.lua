local json = require "json"

function loadHighscores()
  local base = system.pathForFile( "highscores.json", system.DocumentsDirectory)
  local jsoncontents = ""
  local highscoresArray = {}
  local file = io.open( base, "r" )
  if file then
    local jsoncontents = file:read( "*a" )
    highscoresArray = json.decode(jsoncontents);
    io.close( file )
    return highscoresArray
  end
  return highscores
end

function saveHighscores()
  local base = system.pathForFile( "highscores.json", system.DocumentsDirectory)
  local file = io.open(base, "w")
  local jsoncontents = json.encode(highscores)
  file:write( jsoncontents )
  io.close( file )
end