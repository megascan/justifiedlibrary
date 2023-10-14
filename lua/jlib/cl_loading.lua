--[[
	This is a method of ensuring that the player is loaded in, so we can network stuff to them (PlayerInitialSpawn is unreliable)
--]]
timer.Create("jlib.InitializePlayer", 1, 0, function()
	if IsValid(LocalPlayer()) and istable(jnet) then
		jnet.send("jlib.Authenticate", {})
		hook.Run("jlib.Authenticate")
		timer.Remove("jlib.InitializePlayer")
	end
end)