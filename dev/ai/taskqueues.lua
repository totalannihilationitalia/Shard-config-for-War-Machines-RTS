--[[
 Task Queues!
]]--
-- 26/02/2025 importato "econhandler.lua"				-- molixx
-- 26/02/2025 settati i moduli in "modules.lua"			-- molixx

math.randomseed( os.time() )
math.random(); math.random(); math.random()

function CoreWindSolar()
	if map:AverageWind() > 10 then
		return "corwin"
	else
		return "corsolar"
	end
end
function randomLab()
	local r = math.random(0,2)
	if r == 0 then
		return "corlab"
	elseif r == 1 then
		return "corvp"
	else
		return "corap"
	end
end
--[[
function debugcostr()

	 game:SendToConsole("estrazione di metallo: ".. ai.Metal.income) -- restituisce il valore di metallo estratto
	 game:SendToConsole("metallo utilizzato: ".. ai.Metal.usage) -- restituisce il valore di metallo utilizzato
 	 game:SendToConsole("capacita magazzino di metallo in scala da 0 a 1 (0 - 100%): ".. ai.Metal.full) -- restituisce valori da 0 a 1 esprime la quantità di metallo da 0 al 100%
	 game:SendToConsole("capacita magazzino metallo: ".. ai.Metal.capacity) -- restituisce il valore del magazzino totale disponibile
	 game:SendToConsole("un altra variabile per la capacità di magazzino metallo: ".. ai.Metal.reserves) -- come precedente, verificare se include anche gli alleati
	 -- lo stesso per energia, sostituire Metal con Energy
	 game:SendToConsole("capacita magazzino energia: ".. ai.Energy.capacity) -- restituisce il valore del magazzino totale disponibile	 
	 return "cormex"
--	 game:SendToConsole("capacita magazzino energia: ".. ai.mexCount) -- NON FUNZIONA!!!!!! probabilmente bisogna aggiungere il modulo counthandler ###############################################################
 end
]]--

local nfacommanderlist = {
--	CoreWindSolar,
	debugcostr, -- mettiamo tutte le funzioni possibili per il test
}

-- andronians hovercraft
local task_and_hovercraft_lab = {
   	 "andgaso",
	 "andlipo",
	 "andmisa",
}

-- andronians kbot lab
local task_and_kbot_lab = {
"andbrskr",
"anddauber",
}

-- andronians adv kbot lab
local task_and_kbot_adv_lab = {
"walker",
"andogre",
"exxec",
}

-- andronians adv. hovercraft
local task_and_adv_hovercraft_lab = {
   	 "androck",
	 "andtanko",
	 "andtesla",
	 "andnikola",
}

taskqueues = {
	-- unittype = tasklist,
	nfacom = nfacommanderlist,
	andhp = task_and_hovercraft_lab,
	andlab = task_and_kbot_lab,	
	andahp = task_and_adv_hovercraft_lab,
	andalab = task_and_kbot_adv_lab,
	
	-- we can assign 1 list, to multiple unit types, here a construction kbot (corck) gets the construction kbot tasklist, but then we assign it to the construction vehicle too (corcv))

}
