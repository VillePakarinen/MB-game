--Main lua

--disable statusbar
display.setStatusBar(display.HiddenStatusBar)
system.activate( "multitouch" )

local composer = require ("composer")
composer.gotoScene("preGame")
