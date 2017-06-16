--dependencies
local composer = require( "composer" )
local physics = require "physics"
local json = require "json"
tiled = require "com.ponywolf.ponytiled"


local scene = composer.newScene()


--------------------------------------------------------------------------------
-- Build Camera
--------------------------------------------------------------------------------
local perspective = require("perspective")
local camera = perspective.createView()


--Set up stuff for the game
local hero
local game
local goal
local time




-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local sceneGroup = self.view
    print("Creating game view")
    --Start the physics engine and add gravity
    physics.start()
    physics.setGravity( 0, 30 )
    physics.setDrawMode("normal")

    game = true

    --Load the map
    local mapData = json.decodeFile(system.pathForFile("map/level.json", system.ResourceDirectory))  -- load from json export
    local map = tiled.new(mapData, "map/")

    --Find objects from the map
    hero = map:findObject("hero")
    goal = map:findObject("goal")

    --Add timer to the left corner
    time = display.newText(0,0,20)

    --add items to camera
    camera:add(hero,l, true)
    camera:add(map,6,false)

    --Set camera bounds
    camera:setBounds(display.contentWidth/2,map.designedWidth-display.contentWidth/2-80,0,map.designedHeight-160)

    --Add items to scene
    sceneGroup:insert(camera)
    sceneGroup:insert(time)



    --End create scene
end





-----------------------------------------
--Function for moving the hero and other hero interactions
-----------------------------------------
local function onEnterFrame()
  if hero == nil then
    return
  end

  if hero.isMovingLeft then
    hero.xScale = -1
    hero:applyForce( -10, 0, hero.x, hero.y )
  end

  if hero.isMovingRight then
    hero.xScale = 1
    hero:applyForce( 10, 0, hero.x,hero.y)
  end

  if hero.y > 600 then
    hero:setLinearVelocity( 0, 0 )
    hero.x = 32
    hero.y = 400
  end

  if game == false then
    composer.gotoScene("endGame","fade",800)
  end
--End enterframe
end
--
--
--
-- -------------------------------------------
-- -- Function for screen touch
-- -------------------------------------------
local function onScreenTouch(event)
    if event.x < display.actualContentWidth/2 then
      if event.phase == "began" then
        print("You clicked left")
        hero.isMovingLeft = true
      elseif event.phase == "ended" then
          hero.isMovingLeft = false
      end
    else
      if event.phase == "began" then
        print("You clicked right")
        hero.isMovingRight = true
      elseif event.phase == "ended" then
        hero.isMovingRight = false
      end
  end
-- end screen touch
end
--
-- -------------------------------------------
-- --Junp
-- -------------------------------------------
local function tapListener( event )
 if hero.canJump == true then
    if ( event.numTaps == 2 ) then
      print("Jump")
      hero:applyLinearImpulse (0, -8, hero.x, hero.y)
      hero.canJump = false;
    end
  end
    return true
--end screen tap
end
--
-- -------------------------------------------
-- --hero collision and end game
-- -------------------------------------------
local function onheroCollision ( event )
  if ( event.phase == "began" ) then
    print("Hit")
    hero.canJump = true
    if event.other.name == "goal" then
      print("Hero hit the goal")
      game = false
    end
end
  return true
--end hero collision
end

-------------------------------------------
--Timer function
-------------------------------------------
local function addTime ()
  local timer = time.text
  time.text = 1 + timer
--end timer
end




-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        camera:track()
        --Make hero able to jump after the creation
        hero.canJump = true

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        myTimer = timer.performWithDelay(1000,addTime,0)


        --Event listeners
        physics.start()
        Runtime:addEventListener( "enterFrame", onEnterFrame )
        Runtime:addEventListener( "touch", onScreenTouch )
        Runtime:addEventListener( "tap", tapListener)
        hero:addEventListener( "collision", onheroCollision)

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
      --Code here runs when the scene is on screen (but is about to go off screen)
      composer.setVariable("time",time.text)
      time.isVisible = false

      --Stop auto-tracking
      camera:cancel()
      physics.stop()
      --Remove eventlisteners
      Runtime:removeEventListener( "enterFrame", onEnterFrame )
      Runtime:removeEventListener( "touch", onScreenTouch )
      Runtime:removeEventListener( "tap", tapListener)
      hero:removeEventListener( "collision", onheroCollision)

      composer.removeScene( "game" )

    elseif ( phase == "did" ) then

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
