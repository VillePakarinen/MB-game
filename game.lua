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
local backgrondMusic
local introText


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
    time = display.newText(0,10,20)
    time_icon = display.newImageRect("img/clock.png",20,20)
    time_icon.x = time.x-30
    time_icon.y = time.y
    time_icon.isVisible = false

    --Add points to right corner
    points = display.newText(0,display.contentWidth-20,20)
    points_icon = display.newImageRect("img/coin_icon.png",20,20)
    points_icon.x = points.x-30
    points_icon.y = time.y
    points.isVisible = false
    points_icon.isVisible = false

    --Make bg sound
    local backgroundMusicFile = audio.loadStream("sounds/bgMusic.mp3")
    local options = {channel = 3, loops = -1, fadein = 2000 }
    audio.setVolume( 0.4, { channel=3 } )
    backgrondMusic = audio.play(backgroundMusicFile,options)


    --Intro text
    local introOptions =
    {
        text = "Young traveler is looking for his uncels tent in the wilderness\n\nCollect all the coins and make haste!!",
        x = hero.x+60,
        y = hero.y-50,
        width = 300,
        font = "go3v2.ttf",
        fontSize = 18,
        align = "left"  -- Alignment parameter
    }
    introText = display.newText( introOptions )

    --add items to camera
    camera:add(hero,l, true)
    camera:add(coinGroup,2,false)
    camera:add(introText,3,false)
    camera:add(map,5,false)

    --Set camera bounds
    camera:setBounds(display.contentWidth/2-display.screenOriginX/2,map.designedWidth-display.contentWidth/2-80,0,map.designedHeight-160)

    --Add items to scene
    sceneGroup:insert(camera)
    sceneGroup:insert(time_icon)
    sceneGroup:insert(points_icon)
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
  local center = display.actualContentWidth/2 + display.screenOriginX

    if event.x < center then
      if event.phase == "began" then
        print("You clicked left")
        hero.isMovingLeft = true
        playSheet("run")
      elseif event.phase == "moved" then
        if event.x > center then
          hero.isMovingRight = true
          hero.isMovingleft = false
        end
      elseif event.phase == "ended" then
          hero.isMovingLeft = false
          hero.isMovingRight = false
          playSheet("idle")
      end
    else
      if event.phase == "began" then
        print("You clicked right")
        hero.isMovingRight = true
        playSheet("run")
      elseif event.phase == "moved" then
        if event.x < center then
          hero.isMovingRight = false
          hero.isMovingleft = true
        end
      elseif event.phase == "ended" then
        hero.isMovingRight = false
        hero.isMovingLeft = false
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
  --One coin is x points
  points.text = score + 40

  local sound = audio.loadSound( "sounds/NFF-coin-04.wav" )
  audio.setVolume( 0.08, { channel=1 } )
  local play = audio.play(sound, {channel = 1})
end

-- -------------------------------------------
--hero collision and end game
-- -------------------------------------------
local function onheroCollision ( event )
  if ( event.phase == "began" ) then
    if event.other.name == "ground" then
    hero.canJump = true
    elseif event.other.name == "goal" then
      print("Hero hit the goal")
      game = false
    elseif event.other.name == "water" then
      local sound = audio.loadSound( "sounds/water.wav" )
      audio.setVolume( 1 , {channel = 2})
      local play = audio.play(sound, {channel = 2})
    elseif event.other.name == "coin" then
      print("Coin collected")
      event.other:removeSelf()
      addScore()
    end
  elseif event.phase == "ended" then
      if event.other.name == "intro" then
        --introText.isVisible = false
        transition.to( introText, { time=1500, alpha=0} )
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
        audio.resume(backgrondMusic)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        myTimer = timer.performWithDelay(1000,addTime,0)
        points.isVisible = true
        time_icon.isVisible = true
        points_icon.isVisible = true


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
      audio.stop(backgrondMusic)


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
