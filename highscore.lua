local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

local scoreGroup = display.newGroup()
local bestScores
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
        print( "Button was pressed and released" )
        print("Moving to the endGame screen")
        composer.gotoScene("endGame","fade",800)
    end
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

--Reverse array
function Reverse (arr)
	local i, j = 1, #arr

	while i < j do
		arr[i], arr[j] = arr[j], arr[i]

		i = i + 1
		j = j - 1
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    print("Creating highscores")
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    --Background
    local bg = display.newImageRect("img/sky.png",display.contentWidth*2,display.contentHeight-display.screenOriginY)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    local scoreBg = display.newImageRect("img/scoreBg.png",display.contentWidth/2-display.screenOriginX,display.contentHeight+1)
    scoreBg.x = display.contentWidth/5
    scoreBg.y = display.contentHeight/2

    --Lets create bestScores text here
    bestScores = display.newText( "Best Scores", display.contentCenterX/2.4, 50, native.systemFont, 30 )
    bestScores:setFillColor( 0, 0, 0 )

    --Get highscores and sort them




    --Add button to move us into the game
    local backButton = widget.newButton(
    {
        defaultFile = "img/button_normal.png",
        overFile = "img/button_down.png",
        width = 200,
        height = 75,
        id = "back",
        label = "Back",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0 } },
        onEvent = handleButtonEvent
    }
)
    backButton.x = bestScores.x + display.contentWidth/2-display.screenOriginX
    backButton.y = display.contentHeight/2

    --Add graohics to the sceneGroup
    sceneGroup:insert(bg)
    sceneGroup:insert(scoreBg)
    sceneGroup:insert(bestScores)
    sceneGroup:insert(scoreGroup)
    sceneGroup:insert(backButton)

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        local scores = readFromFile()
        table.sort(scores)
        Reverse(scores)


        --Print scores to screen
        if #scores == 0 then
          scoreText = display.newText("No records",bestScores.x,bestScores.y+50,native.systemFont,30)
          scoreText:setFillColor( 0, 0, 0 )
          scoreGroup:insert(scoreText)
        else
          local space = bestScores.y + 60
          for i=1,#scores do
            scoreText = display.newText( scores[i], bestScores.x, space, native.systemFont, 30 )
            space = space + 40
            scoreText:setFillColor( 0, 0, 0 )
            scoreGroup:insert(scoreText)
          end
        end

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
        while scoreGroup.numChildren > 0 do
              local i = scoreGroup[1]
              if i then
                i:removeSelf()
              end
          end


    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

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
