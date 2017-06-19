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
local game = true
local goal
local time
local points

--Load spritesheets
local HeroSheetData1 = { width = 64, height= 64, numFrames = 8, sheetContentWidth=192, sheetContentHeight=192 }
local HeroSpriteSheet1 = graphics.newImageSheet("map/hero/SPR_M_TRAVELER_WALK_ANIM.png" , HeroSheetData1)

local HeroSheetData2 = { width=64, height=64, numFrames=8, sheetContentWidth=192, sheetContentHeight=192 }
local HeroSpriteSheet2 = graphics.newImageSheet( "map/hero/SPR_M_TRAVELER_IDLE_ANIM.png", HeroSheetData2 )

local CoinSheetData = { width = 152, height= 150, numFrames = 8, sheetContentWidth=456, sheetContentHeight=450 }
local CoinSpriteSheet = graphics.newImageSheet("map/points/COIN.png" , CoinSheetData)

local HeroSequenceData =
{
  {name = "run", sheet=HeroSpriteSheet1, frames={1,2,3,4,5,6,7,8}, time=1000, loopCount=0 },
  {name = "idle", sheet=HeroSpriteSheet2, frames={1,2,3,4,5,6,7,8}, time=1000, loopCount=0 },
}

local CoinSequenceData = {
  {name = "rotate", sheet=CoinSpriteSheet, frames={1,2,3,4,5,6,7,8}, time=1000, loopCount=0 }
}

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


    --Load the map
    local mapData = json.decodeFile(system.pathForFile("map/level.json", system.ResourceDirectory))  -- load from json export
    local map = tiled.new(mapData, "map")

    --Find hero from the map
    local heroSettings = map:findObject("heroLocation")

    --Make visuals for the hero
    hero = display.newSprite (HeroSpriteSheet2, HeroSequenceData)
    hero:play()

    local offsetRectParams = { halfWidth=20, halfHeight=22, x=0, y=10}
    physics.addBody( hero, "dynamic", { density=0.28, friction=1,  box=offsetRectParams } )
    hero.isFixedRotation = true
    hero.x = heroSettings.x
    hero.y = heroSettings.y

    --Make coins
    local coins = map:listTypes( "coin" )
    local coinGroup = display.newGroup()

    for i = 1,#coins do
      coin = display.newSprite (CoinSpriteSheet, CoinSequenceData)
      coin:play()

      coin.name = "coin"
      coin.x = coins[i].x
      coin.y = coins[i].y
      coin:scale(0.5,0.5)

      local coinSize = { halfWidth=20, halfHeight=22, x=0, y=0}
      physics.addBody( coin, "static", { isSensor = true, box=coinSize } )

      coinGroup:insert(coin)
    end

    --Find goal
    goal = map:findObject("goal")

    --Add timer to the left corner
    time = display.newText(0,0,20)
    points = display.newText(0,display.contentWidth-20,20)


    --add items to camera
    camera:add(hero,l, true)
    camera:add(coinGroup,2,false)
    camera:add(map,5,false)

    --Set camera bounds
    camera:setBounds(display.contentWidth/2,map.designedWidth-display.contentWidth/2-80,0,map.designedHeight-160)

    --Add items to scene
    sceneGroup:insert(camera)
    sceneGroup:insert(time)
    --End create scene
end


-----------------------------------------
--Function for hero animation
-----------------------------------------
local function playSheet(param)
  hero:setSequence(param)
  hero:play()
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

  if hero.y > 700 then
    hero:setLinearVelocity( 0, 0 )
    hero.x = 32
    hero.y = 400
  end

  if game == false then
    composer.gotoScene("endGame","fade",800)
  end
--End enterframe
end


-- -------------------------------------------
-- -- Function for screen touch
-- -------------------------------------------
local function onScreenTouch(event)

  --Divide the screen and make it so that u cant touch both sides at once
  local left = display.actualContentWidth/2 + display.screenOriginX + 5
  local right = display.actualContentWidth/2 + display.screenOriginX - 5

    if event.x < left then
      if event.phase == "began" then
        print("You clicked left")
        hero.isMovingLeft = true
        playSheet("run")
      elseif event.phase == "ended" or event.phase  == "moved"  then
          hero.isMovingLeft = false
          playSheet("idle")
      end
    elseif right then
      if event.phase == "began" then
        print("You clicked right")
        hero.isMovingRight = true
        playSheet("run")
      elseif event.phase == "ended" or event.phase  == "moved" then
        hero.isMovingRight = false
        playSheet("idle")
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

-------------------------------------------
--Score function
-------------------------------------------
local function addScore()
  local score = points.text
  points.text = score + 20

  local sound = audio.loadSound( "sounds/NFF-coin-04.wav" )
  audio.setVolume( 0.1 )
  local play = audio.play(sound)
end

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
    elseif event.other.name == "coin" then
      print("Coin collected")
      event.other:removeSelf()
      addScore()
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
        game = true

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

      --Send time to next scene and hide timer
      composer.setVariable("time",time.text)
      composer.setVariable("score",points.text)
      time.isVisible = false
      points.isVisible = false

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
