--!optimize 2
-- Kept only so an older cached entry point still resolves; the widget library
-- is shared between desktop and mobile and lives at the repository root.

return function(context)
	local builder = context.load_module("UI_elements.lua")
	if type(builder) ~= "function" then
		error("Failed to load UI_elements")
	end
	return builder(context)
end
