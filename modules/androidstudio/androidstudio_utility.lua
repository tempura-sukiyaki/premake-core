---
-- androidstudio/androidstudio_utility.lua
---

	local p = premake
	local m = p.modules.androidstudio

	-- onstart

	function m.start()
		_TARGET_OS = p.ANDROID
	end
