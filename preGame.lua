local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
        print( "Button was pressed and released" )
        print("Moving to the game")
        composer.gotoScene("game","fade",800)
    end
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    print("Creating logo text")
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    --Background
    local bg = display.newImageRect("img/sky.png",display.contentWidth*2,display.contentHeight-display.screenOriginY)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    --Lets create logo text here
    local logo = display.newText( "Simple Platformer", display.contentCenterX, display.contentCenterY - 20, native.systemFont, 30 )
    logo:setFillColor( 1, 1, 1 )

    --Add button to move us into the game
    local playButton = widget.newButton(
    {
        defaultFile = "img/button_normal.png",
        overFile = "img/button_down.png",
        width = 200,
        height = 75,
        id = "play",
        label = "Play",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0 } },
        onEvent = handleButtonEvent
    }
)
    playButton.x = display.contentCenterX
    playButton.y = logo.y + 60

    --Add graohics to the sceneGroup
    sceneGroup:insert(bg)
    sceneGroup:insert(logo)
    sceneGroup:insert(playButton)

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

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
