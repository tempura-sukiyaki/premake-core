---
-- androidstudio/androidstudio.lua
---

	local p = premake

	if not p.modules.androidstudio then
		require('android')

		p.modules.androidstudio = {}

		local m = p.modules.androidstudio
		m._VERSION = p._VERSION

		include("androidstudio_cmakeliststxt.lua")
		include("androidstudio_gradle.lua")
		include("androidstudio_properties.lua")
		include("androidstudio_utility.lua")
	end

	return p.modules.androidstudio
