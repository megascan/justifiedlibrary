--[[
	This is a method of ensuring that the player is loaded in, so we can network stuff to them (PlayerInitialSpawn is unreliable)
--]]
local function Evolution_IsPlayerLoadedIn()
	if IsValid( LocalPlayer() ) then
		jnet.send("jlib_Net_HUDPaintLoad", {})
		
		hook.Remove( "HUDPaint", "Evolution_IsPlayerLoadedIn" )
	end
end
hook.Add( "HUDPaint", "Evolution_IsPlayerLoadedIn", Evolution_IsPlayerLoadedIn )