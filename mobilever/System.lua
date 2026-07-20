-- mobilever/System.lua
-- Thin shim. The physics engine is shared with desktop and lives in the
-- root System.lua; platform-specific behavior branches on context.is_mobile
-- inside that file. This shim exists only so the loader's
-- `load_module(SUB_DIR .. "System.lua")` call resolves on mobile.
--
-- Do NOT fork engine logic here. If you need a mobile-only change, gate it
-- on `context.is_mobile` in the root System.lua so the two platforms can
-- never drift again.

return function(context)
	local root_system = context.load_module("System.lua")
	if not root_system then
		error("mobilever/System.lua: failed to load root System.lua")
	end
	return root_system(context)
end
