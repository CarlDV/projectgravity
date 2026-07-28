--!optimize 2
-- The interface scales itself to the device now, so the mobile build simply
-- loads the shared one instead of maintaining a second copy of it.

return function(context)
	local builder = context.load_module("UI.lua")
	if type(builder) ~= "function" then
		error("Failed to load UI")
	end
	return builder(context)
end
