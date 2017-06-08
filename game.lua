--dependencies
local composer = require( "composer" )
local physics = require "physics"
--Draw mode for enginen
physics.setDrawMode("normal")

local scene = composer.newScene()

--------------------------------------------------------------------------------
-- Build Camera
--------------------------------------------------------------------------------
local perspective = require("perspective")
local camera = perspective.createView()

--Set up player for on screen touch function
local player = nil
local time = nil

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
--Start the physics engine and add gravity
physics.start()
physics.setGravity( 0, 30 )

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    print("Creating game view")
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    --Lets create something here
    player = display.newRect( display.contentCenterX, 200, 15, 25 )
    local maa = display.newRect( display.contentCenterX, display.contentHeight-display.screenOriginY, display.contentWidth-display.screenOriginX, 10 )
    local kaide = display.newRect(-20,120,5,400)


    --Add physics
    physics.addBody( player,{ density = 1.0, friction = 0.1, bounce = 0.2 } )
    physics.addBody(maa, "static", {friction = 0.3})
    physics.addBody(kaide, "static", {friction = 0.3})


    time = display.newText(0,0,20)

    --add items to camera
    camera:add(player, l, true)
    camera:add(maa, 2, false)
    camera:add(kaide, 3, false)

    --camera:setBounds(0,display.contentWidth, 0, display.contentHeight-150)
    camera:setBounds(display.contentWidth/2,display.contentWidth, -1000, display.contentHeight-150)

    --Add items to scene
    sceneGroup:insert(camera)

    --End create scene
end


--Function for moving the player
local function onEnterFrame()
  if player == nil then
    return
  end

  if player.isMovingLeft then
    player.xScale = -1
    player:applyForce( -10, 0, player.x, player.y )
  end

  if player.isMovingRight then
    player.xScale = 1
    player:applyForce( 10, 0, player.x,player.y)
  end

  if player.y > 600 then
    player:setLinearVelocity( 0, 0 )
    player.x = display.contentWidth/2
    player.y = display.contentHeight/2

  end
--End enterframe
end

-- Function for screen touch
local function onScreenTouch(event)
    if event.x < display.actualContentWidth/2 then
      if event.phase == "began" then
        print("Painoit vasemmalta")
        player.isMovingLeft = true
      elseif event.phase == "ended" then
          player.isMovingLeft = false
      end
    else
      if event.phase == "began" then
        print("Painoit oikealta")
        player.isMovingRight = true
      elseif event.phase == "ended" then
        player.isMovingRight = false
      end
  end
end

--Double junp
local function tapListener( event )
 if player.canJump == true then
    if ( event.numTaps == 2 ) then
      print("Hyppy")
      player:applyLinearImpulse (0, -6, player.x, player.y)
      player.canJump = false;
    end
  end
    return true
end

--Player collision
local function onPlayerCollision ( event )
  if ( event.phase == "began" ) then
    print("Osuma")
    player.canJump = true
end
  return true
end

--Timer function
local function addTime ()
  local timer = time.text
  time.text = 1 + timer
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen


  timer.performWithDelay(1000,addTime,0)

        camera:track()
        --Event listeners
        Runtime:addEventListener( "enterFrame", onEnterFrame )
        Runtime:addEventListener( "touch", onScreenTouch )
        Runtime:addEventListener( "tap", tapListener)
        player:addEventListener( "collision", onPlayerCollision)

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        --Make screen touchable
        Runtime:removeEventListener( "enterFrame", onEnterFrame )
      --  Runtime:removeEventListener( "enterFrame", moveCamera )
        Runtime:removeEventListener( "touch", onScreenTouch )
        Runtime:removeEventListener( "tap", tapListener)
        player:removeEventListener( "collision", onPlayerCollision)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

-- -----------------------------------------------------------------------------------

return scene
