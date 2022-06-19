-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

--Deklaracja bibliotek/klas
local widget = require( "widget" )
local json = require( "json" )
local composer = require( "composer" )
local myData = require( "mydata" )
local weather = require( "api" )

--definicja sceny
local scene = composer.newScene()

--zmienne pogodowe
local wind
local visibility
local pressure
local humidity
local feel_temp
local weatherIcon
local miasto

--zmienna API pobrana z mydata.lua
local API_key=""
API_key = myData.API

--funkcja przekształcająca dane w postaci timestamp (data i godzina w postaci tekstu) do postaci dd/MM/yy hh:mm:ss am/pm
function get_date_from_unix(unix_time)
    --podział ciągu liczbowego na dane odpowiedzialne za datę i czas oraz ustawienie strefy czasowej zgodnej z czasem serwera
	local day_count, year, days, month = function(yr) return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365 end, 1970, math.ceil(unix_time/86400)
	
	--obliczenie dni w każdym miesiącu
    while days >= day_count(year) do
        days = days - day_count(year) year = year + 1
    end
    local tab_overflow = function(seed, table) for i = 1, #table do if seed - table[i] <= 0 then return i, seed end seed = seed - table[i] end end
    --data przekształcona do właściwej postaci (w aplikacji nie wykorzystany)
	month, days = tab_overflow(days, {31,(day_count(year) == 366 and 29 or 28),31,30,31,30,31,31,30,31,30,31})
    --czas przekształcony do właściwej postaci
	local hours, minutes, seconds = math.floor(unix_time / 3600 % 24), math.floor(unix_time / 60 % 60), math.floor(unix_time % 60)
    --ustalenie czy dane są przed czy po południu
	local period = hours > 12 and "pm" or "am"
	--dopasowanie godziny do 12-godzinnego systemu
    hours = hours > 12 and hours - 12 or hours == 0 and 12 or hours
	
	--na wyjściu dane w postaci dd/MM/yy hh:mm:ss am/pm
    return string.format("%d/%d/%04d %02d:%02d:%02d %s", days, month, year, hours+2, minutes, seconds, period)
end

--funkcja tworząca scenę
function scene:create( event )
	local sceneGroup = self.view
	--stworzenie tła i dobór koloru
	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor(  0.306, 0.412, 0.412 )	
	
	--zmienne centralne ekranu
	local centerX = display.contentCenterX
	local centerY = display.contentCenterY

	--stworzenie tekstur na ekranie domyślnych
	local temperatureText = display.newText( "??º", display.contentCenterX/1.7, 150, myData.fontBold, 80 )
	temperatureText:setFillColor( 0.33, 0.66, 0.99 )	
	
	local miasto_txt = display.newText( "Miasto:", display.contentCenterX, centerY/8, myData.fontBold, 14 )
	miasto_txt:setFillColor( 1 )
	
	
	local temp_minText = display.newText( "Min: ??º", display.contentCenterX/3, 230
, myData.font, 14 )
	temp_minText:setFillColor( 1 )
	
	local temp_maxText = display.newText( "Max: ??º", display.contentCenterX/3, 265
, myData.font, 14 )
	temp_maxText:setFillColor( 1 )
	
	local wschodText = display.newText("Wschód slońca: xx:xx:xx am" , display.contentCenterX/1.43, 300, myData.font, 14 )
	local zachodText = display.newText("Zachod slońca: xx:xx:xx pm" , display.contentCenterX/1.43, 335, myData.font, 14 )
	
	--domyślna ikona pogodowa
	weatherIcon = display.newImageRect("images/Clear.png", 128, 128 )
	weatherIcon.x = display.contentCenterX/0.7  
	weatherIcon.y = 150
	
	--funkcja uruchomiona po połączeniu się z serwerem
	local function displayCurrentConditions( )
		
		--zmienna, która przechowuje dane pobrane poprzez json w api.lua
		local response = myData.currentWeatherData

		--sprawdzenie połączenia z serwerem
		if not response then
			native.showAlert("Oops!", "Brak informacji z serwera! Sprawdź połączenie z internetem", { "Okay" } )
			return false
		end
	

		-- zakomentowane sprawdza odpowiedź z serwera
		--print( json.prettify( response ) )
		
		--zmienne przechowujące odpowiednie grupy parametrów z serwera
		local currently = response.main
		local wschod = response.sys
		local img_opis = response.weather
		
		--Podano złe miasto lub miasto nieistniejące
		if response.cod == "404" then
			native.showAlert("Oops!", "Miasto, które podałeś nie istnieje lub nie ma go w naszej bazie.\n Musisz spróbować jeszcze raz!\n ", { "Okay" } )
			return false
		end
		
		--translacja timestamp na czas za pomocą funkcji
		local time_sunrise_string =  tostring(get_date_from_unix(wschod.sunrise))
		local time_sunrise =  string.sub(time_sunrise_string, 10)
		
		local time_sunset_string =  tostring(get_date_from_unix(wschod.sunset))
		local time_sunset =  string.sub(time_sunset_string, 10)
		
		--Podanie zaokrąglonych wartośći liczbowych
		temperatureText.text = math.floor( tonumber(currently.feels_like) ) .. "º"
		temp_minText.text = "Min: " .. math.floor( tonumber(currently.temp_min) ) .. "º"
		temp_maxText.text = "Max: " .. math.ceil( tonumber(currently.temp_max) ) .. "º"
		print(wschod.sunrise)
		wschodText.text = "Wschód slońca: " .. time_sunrise
		zachodText.text = "Zachod slońca: " .. time_sunset
		
		--wczytanie opisu zdjęcia z API i konwersja do istniejących zdjęć w folderze /images/
		local img = img_opis[1].main
		print(img_opis[1].main)
		
		weatherIcon:removeSelf()
		weatherIcon = nil
		weatherIcon = display.newImageRect("images/" .. img .. ".png", 128, 128)
		weatherIcon.x = display.contentCenterX/0.7  
		weatherIcon.y = 150
		
		--zaawansowane jako globalna zmienna
		myData.windspeed = response.wind.speed
		myData.pressure = currently.pressure
		myData.humidity = currently.humidity
		myData.vis = response.visibility
		myData.feels = currently.feels_like
	end
	
	--funkcja "nasłuchująca" danych z pola input i czekająca, aż użytkownik przestanie pisać lub wciśnie enter
	local function textListener( event )
	 
		if ( event.phase == "began" ) then
			-- User begins editing "defaultField"
	 
		elseif ( event.phase == "ended" or event.phase == "submitted" ) then
			-- Output resulting text from "defaultField"
			print( event.target.text )
			myData.miastoAPI = event.target.text
			weather.fetchWeather( displayCurrentConditions )
		end
	end
	
	--stworzenie pola do wprowadzania danych tekstowych
	miasto = native.newTextField( centerX, centerY/4, 200, 30 )
	miasto.size = 20
	miasto.text = "Gdańsk"
	miasto:addEventListener( "userInput", textListener )
	
	--start połączenia klient-serwer po wczytaniu wszystkich tekstur (całego interfejsu)
	--załadowanie domyślnego miasta - Gdańsk
	weather.fetchWeather( displayCurrentConditions )
	

	
	-- all objects must be added to group (e.g. self.view)
	--dodanie obiektów/tekstur do grup, aby przy zmianie sceny łatwo je usunąć/zniszczyć
	sceneGroup:insert( background )
	sceneGroup:insert( miasto )
	sceneGroup:insert( temp_minText )
	sceneGroup:insert( temp_maxText )
	sceneGroup:insert( wschodText )
	sceneGroup:insert( zachodText )
end


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
	miasto = nil
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
--wywołanie zdarzeń odpowiedzialnych za sceny
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene