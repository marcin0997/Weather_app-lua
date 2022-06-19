--Deklaracja bibliotek/klas
-- tu użycie json do komunikacji klient-serwer
local json = require( "json" )
local myData = require( "mydata" )
--przywołanie tablicy M, do której program przepisze odczytane i przekonwertowane dane pobrane z serwera
local M = {}

--funkcja odpowiedzialna za przetworzenie danych z serwera i przekazanie ich do globalnej tablicy zmiennych myData
local function processWeatherRequest( event )
	--zakomentowane sprawdza poprawność połączenia z serwerem
	--print( json.prettify( event ) )
	
	--Za pomocą wtyczki JSON dane są przetwarzane na postać zmienna lub grupa.zmienna (np. sys.sunrise)
	myData.currentWeatherData = json.decode(event.response)
	--zmienna dla sprawdzenia poprawności odczytanych danych
	local cur = myData.currentWeatherData
	
	
	
	myData.lastRefresh = os.time()
	--funkcja zdarzenia, to samo co eventlistener
	if M.callBack then
		M.callBack()
	end
end

--funkcja odpowiedzialna za wysłanie zapytania do serwera
function M.fetchWeather( callBack )
	--to samo co event
	M.callBack = callBack

	--zapytanie, które korzysta z nazwy miasta wprowadzonej przez użytkownika, klucza API oraz wyświetlające metryki europejskie
	local forecastIOURL = "https://api.openweathermap.org/data/2.5/weather?q=" .. myData.miastoAPI .. "&appid=" .. myData.API .. "&units=metric"
	print( "*** Fetching Weather ", forecastIOURL)

	--wysłanie zapytania do serwera openweathermap
	network.request( forecastIOURL, "GET", processWeatherRequest )

end

return M