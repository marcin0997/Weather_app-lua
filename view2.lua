-----------------------------------------------------------------------------------------
--
-- view2.lua
--
-----------------------------------------------------------------------------------------
--Deklaracja bibliotek/klas
local widget = require( "widget" )
local json = require( "json" )
local myData = require( "mydata" )
local weather = require( "api" )
local composer = require( "composer" )
local scene = composer.newScene()

--funkcja tworząca scenę
function scene:create( event )
	local sceneGroup = self.view
	--tło aplikacji
	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor(  0.306, 0.412, 0.412 )		

	--zmienna tekstowa przechowująca zaawansowane dane, jak ciśnienie powietrza, wilgotność etc.
	local newTextParams = { text = "Prędkość wiatru: " .. myData.windspeed .. " km/h\n\nWidocznosc: " .. myData.vis .. " km\n\nCiśnienie: " .. myData.pressure .. " hPa\n\nWilgotność: " .. myData.humidity .. " %\n\nTemp. odczuwalna: " .. myData.feels .. "ºC", 
						x = display.contentCenterX/1.05, 
						y = display.contentCenterY/0.65, 
						width = 250, height = 310, 
						font = myData.fontBold, fontSize = 14, 
						align = "left" }
						
	local summary = display.newText( newTextParams )
	summary:setFillColor( 1 )
	
	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( background )
	sceneGroup:insert( summary )
end

--funkcja pokazująca elementy w grupach
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

--funkcja gdy aplikacja będzie zapauzowana (użytkownik przełączy aplikację etc.)
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

--funkcja uruchamiana, gdy przechodzimy do następnej sceny
function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
