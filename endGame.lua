local composer = require( "composer" )
local widget = require( "widget" )


local scene = composer.newScene()

local yourTime
local yourScore
local totalScoreTxt
local time = ""
local score = ""
local totalScore = ""


local prevScene = composer.getSceneName( "previous" )
    if prevScene == "game" then
      time = composer.getVariable("time")
      score = composer.getVariable("score")
    end
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function handleButtonEvent( event )
  local button = event.target.id
    if ( "ended" == event.phase ) then
      if button == "play_again" then
        print( "Button was pressed and released" )
        print("Moving to the game")
        composer.gotoScene("game","fade",800)
      elseif button == "highscore" then
        --highscore scene
        composer.gotoScene("highscore","fade",800)
      end
    end
end

--Function for writing to highscore.txt
local function saveToFile(value,writeType)
  local path = system.pathForFile( "highscore.txt", system.DocumentsDirectory )

  -- Open the file handle
  local file, errorString = io.open( path, writeType )
  if not file then
    -- Error occurred; output the cause
    print( "File error: " .. errorString )
  else
    file:write( value .. "\n")
    io.close( file )
  end
  file = nil
end
--function for reading from highscore.txt
local function readFromFile()
  local path = system.pathForFile( "highscore.txt", system.DocumentsDirectory )
  local file = io.open( path, "r" )
  local tbl = {}

  if file then
    -- Output lines
    for line in file:lines() do
        table.insert(tbl,tonumber(line))
    end
  io.close( file )
  end
  file = nil
  return tbl
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    --Background
    local bg = display.newImageRect("img/sky.png",display.contentWidth*2,display.contentHeight-display.screenOriginY)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    --Lets create endgame text here
    local endText = display.newText( "Great Job!", display.contentCenterX, display.contentCenterY - 100, native.systemFont, 30 )
    endText:setFillColor( 1, 1, 1 )

    --Display time
    yourTime = display.newText( "Your time: " .. time, display.contentCenterX, endText.y + 40, native.systemFont, 30 )
    yourTime:setFillColor( 1, 1, 1 )

    yourScore = display.newText( "Your Score: " .. score, display.contentCenterX, yourTime.y + 40, native.systemFont, 30 )
    yourScore:setFillColor( 1, 1, 1 )

    totalScoreTxt = display.newText(totalScore,display.contentCenterX,yourScore.y+60,native.systemFont, 35)
    totalScoreTxt:setFillColor(1,1,1)




    --Add button to move us into the game
    local playAgainButton = widget.newButton(
    {
        defaultFile = "img/button_normal.png",
        overFile = "img/button_down.png",
        width = 200,
        height = 75,
        id = "play_again",
        label = "Play again",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0 } },
        onEvent = handleButtonEvent
    }
)

    --Add button to move us into highscores
    local highscoreButton = widget.newButton(
    {
        defaultFile = "img/button_normal.png",
        overFile = "img/button_down.png",
        width = 200,
        height = 75,
        id = "highscore",
        label = "Highscores",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0 } },
        onEvent = handleButtonEvent
    }
    )


    playAgainButton.x = display.contentCenterX - display.contentCenterX/2
    playAgainButton.y = totalScoreTxt.y + 80
    highscoreButton.x = display.contentCenterX + display.contentCenterX/2
    highscoreButton.y = totalScoreTxt.y + 80




    --Add graohics to the sceneGroup
    sceneGroup:insert(bg)
    sceneGroup:insert(endText)
    sceneGroup:insert(yourTime)
    sceneGroup:insert(yourScore)
    sceneGroup:insert(totalScoreTxt)
    sceneGroup:insert(playAgainButton)
    sceneGroup:insert(highscoreButton)


end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase


    if ( phase == "will" ) then
      --Get and show game time
      local prevScene = composer.getSceneName( "previous" )
          if prevScene == "game" then
            time = composer.getVariable("time")
            score = composer.getVariable("score")
            yourTime.text = "Your time: " .. time
            yourScore.text = "Your score: " .. score
            totalScore = score-time
            totalScoreTxt.text = totalScore
          end


          ------------------------
          --This is for wrting the game score into a file
          ------------------------
          if totalScore ~= nil then
            local highscoreList = readFromFile()
            local top = 5
            local count = table.maxn(highscoreList)

            if count < top then
              local writer = saveToFile(totalScore,"a")
            else
              table.insert(highscoreList,tonumber(totalScore))
              table.sort(highscoreList)

              --Check that file always has only 5 scores
              for i=top,#highscoreList do
                if #highscoreList > top then
                  table.remove(highscoreList,1)
                end
              end
              --after updating the list lets w deletes all the old stuff and then append to the file
              for i=1,#highscoreList do
                if i == 1 then
                  writer = saveToFile(highscoreList[i], "w")
                else
                  writer = saveToFile(highscoreList[i], "a")
                end
              end
            end
          end
          --- End of filewrite





    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end
end



-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        time = nil
        score = nil
        totalScore = nil

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
