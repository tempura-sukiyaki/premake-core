---
-- androidstudio/tests/test_androidstudio_properties.lua
-- Automated test suite for Android Studio project generation.
---


	local suite = test.declare("androidstudio_properties")
	local p = premake
	local androidstudio = p.modules.androidstudio

---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj

	function suite.setup()
		_TARGET_OS = 'android'
		p.action.set('androidstudio')
		--p.escaper(androidstudio.esc)
		--p.indent("  ")
		io.eol = '\n'
		wks = test.createWorkspace()
	end

	local function prepare()
		androidstudio.generate_workspace_gradleproperties(wks)
		--prj = test.getproject(wks, 1)
	end

--
--
--

	function suite.OnGradleProperty_Empty()
		prepare()
		test.capture [[

		]]
	end

	function suite.OnGradleProperty_NotEmpty()
		gradleproperties {
			['org.gradle.parallel'] = true,
		}
		prepare()
		test.capture [[
'qqqqqq'
		]]
	end

