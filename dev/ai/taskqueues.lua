--[[
 Task Queues!
]]--


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

function testcostr()
--	 		local lotsOfMetal = ai.Metal.income > 25 
--	 local controlMetalSpots = ai.Metal.income  --ai.mexCount
--EchoDebug("metal income: " .. ai.Metal.income )

	 game:SendToConsole("totale raggiunto".. ai.Metal.income)

	 return "cormex"
	 
	 
 end

local nfacommanderlist = {
--	CoreWindSolar,
	testcostr,
}

taskqueues = {
	-- unittype = tasklist,
	nfacom = nfacommanderlist,
	
	-- we can assign 1 list, to multiple unit types, here a construction kbot (corck) gets the construction kbot tasklist, but then we assign it to the construction vehicle too (corcv))

}
