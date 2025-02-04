	--[[
 Task Queues! 
edit by molix 04/11/2024 ÷ 05/11/2024
se ci sono dei lavori da concludere, questi sono segnati dal tag ####################lavoro_da_concludere###
rev1= aggiunto blocco di variabili per limitare le costruzioni del comandante
rev2= aggiunto il numero random di estrattori che il comandante costruisce inizialmente

todo 
-- aggiungere la variabile di presenza di estrattori sottomarini, cosi da capire se le navi costruttori devono costruire estrattori sottomarini/
-- aggiungere sistema check risorse per gestire le costruzioni 
-- verificare se si può utilizzare l'AI nelle missioni, magari aggiungendo una variabile "skirmish" || "missions" per gestire diverse taskqueques
-- inserire lo stato di tecnologia, più è alto, più si alza il numero di unità da costruire (sia eco che battaglia)
-- in funzione della presenza di features, l'AI cerchera di resuscitarle producendo le unità resurrector
]]--

local debug_commander = true		-- debug canale commandante riferito a max costruzioni realizzate (factory, metex ecc)
local debug_riepilogo = true		-- debug riepilogo: fa un conteggio di tutte le costruzioni effettuate	
local debug_1 = true 				-- debug canale 1 riferito alla funzione func_COMbuilLabNFA
local debug_2 = true 				-- debug canale 1 riferito alla funzione func_1lvlbuilLabNFA ####################lavoro_da_concludere###  da implementare

math.randomseed( os.time() )
math.random(); math.random(); math.random()



-- local metalMake, metalUse, energyMake, energyUse = game:GetResource(idx) -- da testare

-------------------------------------------------
-------------------------------------------------
-- variabili di costruzione
-------------------------------------------------
-------------------------------------------------
local energia = 0
local metallo = 0
local min_commander_factory = 1								-- numero minimo di fabbriche che il comandante può costruire all'inizio (serve a saltare la costruzione quando ha raggiunto il n° max)
local max_commander_factory = 2								-- numero massimo di fabbriche che il comandante può costruire all'inizio (serve a saltare la costruzione quando ha raggiunto il n° max)
local max_random_commander_factory=0   		-- don't modify -- numero gestito dal "blocco max_random_commander_factory" 
local tot_builded_commander_factory = 0     -- don't modify -- numero gestito dalla logica, rappresenta il numero totale di fabbriche costruite dal comandante

local min_commander_metex = 2 								-- numero minimo di estrattori che il comandante può costruire (serve a saltare la costruzione quando ha raggiunto il n° max, altrimenti costuisce solo quelli andando fino dal nemico)
local max_commander_metex = 4 								-- numero massimo di estrattori che il comandante può costruire (serve a saltare la costruzione quando ha raggiunto il n° max, altrimenti costuisce solo quelli andando fino dal nemico)
local max_random_commander_metex=0     		-- don't modify -- numero gestito dal "blocco max_random_commander_metex" 
local tot_builded_commander_metex = 0  		-- don't modify	-- gestito dalla logica: conta quanti estrattori sono stati costruiti dal comandante

local min_commander_powerplants = 3							-- numero minimo di powerplants (solari o eoliche) che il comandante può costruire (serve a saltare la costruzione quando ha raggiunto il n° max, altrimenti costuisce solo quelli andando fino dal nemico)
local max_commander_powerplants = 6							-- numero massimo di powerplants (solari o eoliche) che il comandante può costruire (serve a saltare la costruzione quando ha raggiunto il n° max, altrimenti costuisce solo quelli andando fino dal nemico)
local max_random_commander_powerplants=0   	-- don't modify -- numero gestito dal "blocco max_random_commander_powerplants"  -- da fare!!   ####################lavoro_da_concludere### 
local tot_builded_commander_powerplants = 0	-- don't modify	-- gestito dalla logica: conta quante powerplant (solari o eoliche) sono stati costruiti dal comandante

local tot_1lvl_metex = 0					-- don't modify -- gestito dalla logica: conta quanti estrattori sono stati costruiti
local max_1lvl_metex = 5 									-- numero max iniziale di estrattori che l'AI si impegna a costruire. Man mano che ci sarà necessità, questa variabile aumenta (gestita dalla logica)

local tot_1lvl_factory = 0					-- don't modify -- gestito dalla logica: conta quante factory sono state costruite
local max_1lvl_factory = 2 									-- numero max iniziale di factory che l'AI si impegna a costruire. Man mano che ci sarà necessità, questa variabile aumenta (gestita dalla logica)


-- "blocco max_random_commander_metex" -- definisce, in maniera random, tra il numero minimo e massimo precedentemente impostati, quanti estrattori max il comandante può costruire: 
local r = math.random(0,max_commander_metex-min_commander_metex-1)
max_random_commander_metex = min_commander_metex +r  

-- "blocco max_random_commander_factory" -- definisce, in maniera random, tra il numero minimo e massimo precedentemente impostati, quante fabbriche max il comandante può costruire: 
local r = math.random(0,max_commander_factory-min_commander_factory-1)
max_random_commander_factory = min_commander_factory +r  

local team_ID = 0
local metallino = 199
local fabbricazionemetallo = 0
local metalUse = 0
local energyMake = 0 
local energyUse = 0

--[[function dioboia()
fabbricazionemetallo Spring.GetTeamResources ( 1, "metal" )
Spring.Echo(fabbricazionemetallo)
end 
]]--

-------------------------------------------------
-------------------------------------------------
-- NFA side
-------------------------------------------------
-------------------------------------------------
function func_riepilogo() -- eseguo un riepilogo al riavvio dei Tasks
 
	if debug_riepilogo then
	--	self.id = u:ID()
--		 team_ID = game:GetTeamID() -- determino il team della SHARD
--		 fabbricazionemetallo = game:GetResourceByName("storage")
		 game:SendToConsole("RIEPILOGO: fabbricazionemetallo:"..fabbricazionemetallo.." metaluse:"..metalUse.." energyMake:"..energyMake.." energyUse:"..energyUse)
		 game:SendToConsole("RIEPILOGO: SHARD è attribuita al team: "..team_ID)
		 game:SendToConsole("RIEPILOGO: il comandante ha costruito: "..tot_builded_commander_metex.." estrattori su un max di:"..max_random_commander_metex.." che può costruire")
		 game:SendToConsole("RIEPILOGO: sulla mappa sono presenti: "..tot_1lvl_metex.." estrattori di metallo su un max di:"..max_1lvl_metex.." ammessi allo stato attuale")
		 game:SendToConsole("RIEPILOGO: sulla mappa sono presenti: "..tot_1lvl_factory.." factory su un max di:"..max_1lvl_factory.." ammesse allo stato attuale")
		  end
	return ""
end

-- funzione comandante per costruzione estrattori di metallo se ne ha costruiti meno di quelli iniziali che deve costruire oppure se il numero totale degli estrattori è inferiore al massimo consentito
function func_NFA_com_metex()
	if tot_builded_commander_metex < max_random_commander_metex and tot_1lvl_metex < max_1lvl_metex then
	tot_builded_commander_metex = tot_builded_commander_metex+1 -- ####################lavoro_da_concludere### questa azione deve esistere quando il costruttore è stato effettivamente costruito!!
	tot_1lvl_metex = tot_1lvl_metex +1 							-- ####################lavoro_da_concludere### questa azione deve esistere quando il costruttore è stato effettivamente costruito!!
		 if debug_commander then
		 game:SendToConsole("DEBUG_COMM: il comandante costruisce l'estrattore numero: "..tot_builded_commander_metex.." di un max di:"..max_random_commander_metex.." che può costruire")
		 end
    return "cormex"
	else
		 if debug_commander then
		 game:SendToConsole("DEBUG_COMM: il comandante ha gia costruito il suo massimo massimo di "..tot_builded_commander_metex.."estrattori. In generale sulla mappa sono presenti "..tot_1lvl_metex.." su un totale di "..max_1lvl_metex.." estrattori. il comandante questa costruzione")
		 end
	return "" -- fare in modo che il sistema non dica tutte le volte che non esiste questa unità ####################lavoro_da_concludere###
	end
end

function func_NFAWindSolar() -- funzione verifica il valore medio del vento nella mappa, in base al vento ritorna come valore il generatore eolico o solare
	if map:AverageWind() > 10 then
	-- test scrivo il valore medio del vento, stando al codice --> game:SendToConsole("Shard by AF - playing:"..game:GameName().." on:"..game.map:MapName())" la stringa corretta potrebbe essere game.map:AverageWind()
	 if debug_1 then
	 game:SendToConsole("DEBUG_1:fabbrica eolica") 
	 game:SendToConsole("DEBUG_1: il valore del vento è:"..game.map:AverageWind()) 
	end
		return "corwin"
	else
		return "corsolar"
	end
end

-- funzione randomlab, restituisce il valore di una fabbrica a caso
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

-- in funzione della mappa, e della quantità di fabbriche che il comandante ha costruito, gestisco il task di costruzione delle factory da parte del comandante ( cantieri navali, fabbriche aeree o di terra per la fazione NFA)
function func_COMbuilLabNFA() -- comandante - costruzione factory
	if tot_builded_commander_factory >= max_random_commander_factory then -- se il comandante ha già costruito un numero massimo di fabbriche, salta questo blocco e non costruire niente
	if debug_commander then -- se è attivo il debug, scrivilo in chat
		game:SendToConsole("DEBUG_COMM: il comandante ha costruito il massimo di "..max_random_commander_factory.." factory ammissibili e pertanto non ne costruisce altre")
		end
	return ""
	end
		if debug_1 then
		game:SendToConsole("DEBUG_1: il nome della mappa è:"..game.map:MapName())
		end
-- 1 se la mappa fa parte de gruppo "terra e aria" ####################lavoro_da_concludere### spostare questa condizione il "else" cosi le mappe  non "listate" vanno in automatico in questo gruppo. Sostituire questo gruppo con "solo ARIA".
	if game.map:MapName()== "Akilon" or game.map:MapName()== "Titan" or game.map:MapName()== "TMA-0 v1_1" or game.map:MapName()== "The Rock" or game.map:MapName()== "Stronghold_beta" or game.map:MapName()== "Alone" or game.map:MapName()== "Port Island Dry Center" or game.map:MapName()== "Port Island Dry" or game.map:MapName()== "Orbital Station One" or game.map:MapName()== "Nuclear Winter" or game.map:MapName()== "Lava Island" or game.map:MapName()== "Folsom Dam" or game.map:MapName()== "Desert of Sninon" then
	-- a questo punto creo una condizione random delle fabbriche di terra / aria
		if debug_1 then
		game:SendToConsole("DEBUG_1: il gruppo della mappa è terra e aria")
		end
	
		local r = math.random(0,2)
			if r == 0 then
			return "corlab"  -- lab
			elseif r == 1 then
			return "corvp"   -- veicoli
			else
			return "corap"   -- aerei
			end
-- 2 se la mappa fa parte de gruppo "terra mare e aria"
	elseif game.map:MapName()== "Eridlon Island" or game.map:MapName()== "Tropical" or game.map:MapName()== "Tabula" or game.map:MapName()== "Port Island Water" or game.map:MapName()== "Dworld_V1" or game.map:MapName()== "Battlefield" or game.map:MapName()== "Delta Siege dry" or game.map:MapName()== "Delta Siege dry duo" then
	-- a questo punto creo una condizione random delle fabbriche di terra / aria
			if debug_1 then
		game:SendToConsole("DEBUG_1: il gruppo della mappa è terra mare e aria")
		end
		local r = math.random(0,3)
			if r == 0 then
			return "corlab"  -- robot
			elseif r == 1 then
			return "corvp"   -- veicoli
			elseif r == 2 then
			return "corap"   -- aerei			
			else
			return "corsy"   -- navi
			end
-- 3 se la mappa fa parte de gruppo "mare e aria"
	elseif game.map:MapName()== "definire 1" or game.map:MapName()== "definire 2" then
			if debug_1 then
		    game:SendToConsole("DEBUG_1: il gruppo della mappa è mare e aria")
		    end
		local r = math.random(0,1)
			if r == 0 then
			return "corap"  -- aerei
			else
			return "corsy"   -- navi
			end
-- 4 se la mappa fa parte de gruppo "solo mare"
	elseif game.map:MapName()== "definire 3" or game.map:MapName()== "definire 4" then
		if debug_1 then
		game:SendToConsole("DEBUG_1: il gruppo della mappa è solo mare")
		end
		return "corsy"
-- 5 se il nome della mappa non appare nell'elenco rimaniamo sullo standard "terra e aria"	 -- ############### inserire la variante solo AIR (per le mappe spaziali)
	else
-- se si gioca su una mappa che non appare nel suddetto elenco, si gioca con le impostazioni di default
-- ############### inserire le costruzioni di default

		if debug_1 then
		game:SendToConsole("DEBUG_1: questa mappa non rientra in alcun gruppo. aggiungerla in taskqueques.lua")
		end
	end

end

-- in funzione della mappa, e della quantità di fabbriche che il comandante ha costruito, gestisco il task di costruzione delle factory da parte del comandante ( cantieri navali, fabbriche aeree o di terra per la fazione NFA)
function func_1lvlbuilLabNFA() -- costruttori di terra
	if tot_1lvl_factory >= max_1lvl_factory then -- se il comandante ha già costruito un numero massimo di fabbriche, salta questo blocco e non costruire niente
	if debug_2 then -- se è attivo il debug, scrivilo in chat
		game:SendToConsole("DEBUG_2: un costruttore vorrebbe costruire una factory ma la fazione le ha già costruite tutte e "..max_1lvl_factory.." e pertanto salto questa costruzione")
		end
	return ""
	end
		if debug_2 then
		game:SendToConsole("DEBUG_2: il nome della mappa è:"..game.map:MapName())
		end
-- 1 se la mappa fa parte de gruppo "terra e aria" ####################lavoro_da_concludere### spostare questa condizione il "else" cosi le mappe  non "listate" vanno in automatico in questo gruppo. Sostituire questo gruppo con "solo ARIA".
	if game.map:MapName()== "Akilon" or game.map:MapName()== "Titan" or game.map:MapName()== "TMA-0 v1_1" or game.map:MapName()== "The Rock" or game.map:MapName()== "Stronghold_beta" or game.map:MapName()== "Alone" or game.map:MapName()== "Port Island Dry Center" or game.map:MapName()== "Port Island Dry" or game.map:MapName()== "Orbital Station One" or game.map:MapName()== "Nuclear Winter" or game.map:MapName()== "Lava Island" or game.map:MapName()== "Folsom Dam" or game.map:MapName()== "Desert of Sninon" then
	-- a questo punto creo una condizione random delle fabbriche di terra / aria
		if debug_2 then
		game:SendToConsole("DEBUG_2: il gruppo della mappa è terra e aria")
		end
	
		local r = math.random(0,2)
			if r == 0 then
			tot_1lvl_factory = tot_1lvl_factory + 1
			return "corlab"  -- lab
			elseif r == 1 then
			tot_1lvl_factory = tot_1lvl_factory + 1			
			return "corvp"   -- veicoli
			else
			tot_1lvl_factory = tot_1lvl_factory + 1			
			return "corap"   -- aerei
			end
-- 2 se la mappa fa parte de gruppo "terra mare e aria"
	elseif game.map:MapName()== "Eridlon Island" or game.map:MapName()== "Tropical" or game.map:MapName()== "Alos" or game.map:MapName()== "Tabula" or game.map:MapName()== "Port Island Water" or game.map:MapName()== "Dworld_V1" or game.map:MapName()== "Battlefield" or game.map:MapName()== "Delta Siege dry" or game.map:MapName()== "Delta Siege dry duo" then
	-- a questo punto creo una condizione random delle fabbriche di terra / aria
			if debug_2 then
		game:SendToConsole("DEBUG_2: il gruppo della mappa è terra mare e aria")
		end
		local r = math.random(0,3)
			if r == 0 then
			tot_1lvl_factory = tot_1lvl_factory + 1			
			return "corlab"  -- robot
			elseif r == 1 then
			tot_1lvl_factory = tot_1lvl_factory + 1			
			return "corvp"   -- veicoli
			elseif r == 2 then
			tot_1lvl_factory = tot_1lvl_factory + 1			
			return "corap"   -- aerei			
			else
			tot_1lvl_factory = tot_1lvl_factory + 1			
			return "corsy"   -- navi
			end
-- 3 se la mappa fa parte de gruppo "mare e aria"
	elseif game.map:MapName()== "definire 1" or game.map:MapName()== "definire 2" then
			if debug_2 then
		    game:SendToConsole("DEBUG_2: il gruppo della mappa è mare e aria")
		    end
		local r = math.random(0,1)
			if r == 0 then
			tot_1lvl_factory = tot_1lvl_factory + 1			
			return "corap"  -- aerei
			else
			tot_1lvl_factory = tot_1lvl_factory + 1			
			return "corsy"   -- navi
			end
-- 4 se la mappa fa parte de gruppo "solo mare"
	elseif game.map:MapName()== "definire 3" or game.map:MapName()== "definire 4" then
		if debug_2 then
		game:SendToConsole("DEBUG_2: il gruppo della mappa è solo mare")
		end
		return "corsy"
-- 5 se il nome della mappa non appare nell'elenco rimaniamo sullo standard "terra e aria"	 -- ############### inserire la variante solo AIR (per le mappe spaziali)
	else
-- se si gioca su una mappa che non appare nel suddetto elenco, si gioca con le impostazioni di default
-- ############### inserire le costruzioni di default

		if debug_1 then
		game:SendToConsole("DEBUG_1: questa mappa non rientra in alcun gruppo. aggiungerla in taskqueques.lua")
		end
	end

end


local task_nfa_comm = {
	func_riepilogo,
	func_NFAWindSolar,
	func_NFA_com_metex,
	func_NFA_com_metex,
	func_NFA_com_metex,
	func_NFAWindSolar,
	func_NFAWindSolar,	
	func_COMbuilLabNFA,
	func_NFAWindSolar,		
--	randomLab,
	"corllt",
	"corrad",
	func_NFAWindSolar,
	func_NFAWindSolar,
	func_NFAWindSolar,
	func_NFAWindSolar,
	func_NFAWindSolar,
}
local task_nfa_kbot = {  -- task costruzione kbot, air e vehicle 1 lvl
	func_NFAWindSolar,
	func_1lvlbuilLabNFA,
	"cormex",
	"cormex",
	"corllt",
	"corrad",
}

local task_icu_comm = {
	"armsolar",
	"icumetex",
	"armsolar",
	"icumetex",
	"icumetex",
	"armlab",
	"iculighlturr",
	"armrad",
	"armsolar",
	"armsolar",
	"armsolar",
	"armsolar",
	"icumetex",
	"armsolar",
	"icumetex",
	"icumetex",
	"iculighlturr",
	"armlab",
	"armrad",
	"armsolar",
	"armsolar",
	"armsolar",
}

local task_icu_kbot = {
	"armsolar",
	"icumetex",
	"armsolar",
	"icumetex",
	"icumetex",
	"armlab",
	"iculighlturr",
	"armrad",
	"armsolar",
	"armsolar",
	"armsolar",
	"armsolar",
	"icumetex",
	"armsolar",
	"icumetex",
	"icumetex",
	"iculighlturr",
	"armlab",
	"armrad",
	"armsolar",
	"armsolar",
	"armsolar",
}

local task_nfa_kbot_lab = {
	"corck",
	"corck",
	"corak",
	"corak",
	"corak",
	"corak",
	"corstorm",
	"corstorm",
	"corthud",
	"corthud",
	"corthud",
	"corcrash",
	"corcrash",
	"corthud",
	"corthud",
	"corstorm",
	"corstorm",
	"corstorm",
}

local task_nfa_vehicle_plant = {
	"corcv",
	"corcv",
	"corfav",
	"corfav",
	"corgator",
	"corgator",
	"corgarp",
	"corraid",
	"corraid",
	"corlevlr",
	"corlevlr",
	"corwolv",
	"cormist",
	"cormist",	
}

local task_icu_kbot_lab = {
	"icuck",
	"icuck",
	"icuck",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
	"icupatroller",
}

-- test lab and
local task_and_hovercraft_lab = {
     "andgaso",
	 "andlipo",
	 "andmisa",
}

taskqueues = {
	-- unittype = tasklist,
-- task per commander 
	nfacom = task_nfa_comm,
	icucom = task_icu_comm,

-- we can assign 1 list, to multiple unit types, here a construction kbot (corck) gets the construction kbot tasklist, but then we assign it to the construction vehicle too (corcv))
	corck = task_nfa_kbot,
	corcv = task_nfa_kbot,
	icuck = task_icu_kbot,
-- task per fabbriche
	corlab = task_nfa_kbot_lab,
	corvp = task_nfa_vehicle_plant,
	armlab = task_icu_kbot_lab,
	andhp = task_and_hovercraft_lab,
}
