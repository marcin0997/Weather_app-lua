
display.setStatusBar( display.DefaultStatusBar )

--deklaracja komponentów
local widget = require "widget"
local composer = require "composer"
local json = require "json"

--wywołanie klas/bibliotek
local myData = require( "mydata" )
local widgetExtras = require( "libs.widget-extras" )

--mydata.lua przechowuje zmienne globalne, tu deklaracja najważniejszych z nich
myData.font = "fonts/Roboto-Thin.ttf" 
myData.fontBold = "fonts/Roboto-Regular.ttf"	--odpowiednie czcionki tzw. fontsy
myData.API = "727396621d82cdbb4609536eb161c21f"	--API do aplikacji pogodowej
myData.lastRefresh = 0							--do odświeżania strony co 15s
myData.miastoAPI = "Gdańsk"						-- miasto początkowe/domyślne
myData.first_run = 0							--do odświeżania (czy pierwszy raz uruchomiono appkę


--Funkcja przechowująca event zmiany sceny po kliknięciu w TabBar
local function onFirstView( event )
	composer.gotoScene( "view1" )
end

--Funkcja przechowująca event zmiany sceny w TabBar
local function onSecondView( event )
	composer.gotoScene( "view2" )
end

-- Stworzenie TabBaru (dolny pasek menu) z dwoma przyciskami
local tabButtons = {
	{
		--Przycisk 1
		label = "Podstawowe info",
		defaultFile = "images/weather_default.png",
		overFile = "images/weather_selected.png",
		width = 32,
		height = 32,
		onPress = onFirstView,
		selected = true,
	},
	{
		--Przycisk 2
		label = "Zaawansowane",
		defaultFile = "images/forecast.png",
		overFile = "images/forecast.png",
		width = 32,
		height = 32,
		onPress = onSecondView,
	},
}

-- Stworzenie TabBaru jako widget
local tabBar = widget.newTabBar{
	top = display.contentHeight - 50,	-- 50 jest domyślne dla TabBar
	buttons = tabButtons
}

onFirstView()	-- Inicjacja głównego okna jako Przycisk1
