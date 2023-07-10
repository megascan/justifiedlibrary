--[[
	This is a method of ensuring that the player is loaded in, so we can network stuff to them (PlayerInitialSpawn is unreliable)
--]]
hook.Add("HUDPaint", "jlib.OnClientFullyLoad", function()
	if IsValid(LocalPlayer()) then
		jnet.send("jlib.Authenticate", {})
		hook.Remove("HUDPaint", "jlib.OnClientFullyLoad")
	end
end)