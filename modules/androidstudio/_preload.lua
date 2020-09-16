---
-- androidstudio/_preload.lua
---

	local p = premake


--
-- Register Android Studio workspace API.
--

	-- build.gradle
	p.api.register {
		name = "workspacebuildgradle",
		scope = "workspace",
		kind = "key-array",
	}

	-- gradle.properties
	p.api.register {
		name = "gradleproperties",
		scope = "workspace",
		kind = "keyed:string",
	}

	-- local.properties
	p.api.register {
		name = "localproperties",
		scope = "workspace",
		kind = "keyed:string",
	}

--
-- Register Android Studio project API.
--

	-- build.gradle
	p.api.register {
		name = "projectbuildgradle",
		scope = "project",
		kind = "key-array",
	}

--
-- Register Android Studio action.
--

	newaction {
		trigger = "androidstudio",
		shortname = "Google Android Studio",
		description = "Generate Google Android Studio project files",

		toolset = "gcc",

		valid_kinds = { "WindowedApp", "SharedLib", "StaticLib", "Utility", "AssetPack", "None" },
		valid_languages = { "C", "C++" },
		valid_tools = {
			cc = { "clang", 'gcc' },
		},

		onStart = function()
			p.modules.androidstudio.start()
		end,

		onWorkspace = function(wks)
			p.generate(wks, "build.gradle", p.modules.androidstudio.generate_workspace_buildgradle)
			p.generate(wks, "gradle.properties", p.modules.androidstudio.generate_workspace_gradleproperties)
			if #table.keys(wks.localproperties) > 0 then
				p.generate(wks, "local.properties", p.modules.androidstudio.generate_workspace_localproperties)
			end
			p.generate(wks, "settings.gradle", p.modules.androidstudio.generate_workspace_settingsgradle)
			p.generate(wks, "CMakeLists.txt", p.modules.androidstudio.generate_workspace_cmakeliststxt)
		end,

		onProject = function(prj)
			if prj.kind == p.WINDOWEDAPP
			or prj.kind == p.ASSETPACK then
				p.generate(prj, "build.gradle", p.modules.androidstudio.generate_project_buildgradle)
			end
			if prj.kind == p.SHAREDLIB
			or prj.kind == p.STATICLIB
			or prj.kind == p.UTILITY
			or prj.kind == p.WINDOWEDAPP then
				p.generate(prj, "CMakeLists.txt", p.modules.androidstudio.generate_project_cmakeliststxt)
			end
		end,
	}

	return function(cfg)
		return (_ACTION == "androidstudio")
	end
