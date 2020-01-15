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

	local wks

	function suite.setup()
		_TARGET_OS = 'android'
		p.action.set('androidstudio')
		--p.escaper(androidstudio.esc)
		--p.indent("  ")
		io.eol = '\n'
		wks = test.createWorkspace()
	end

	local function prepare_gradleproperties()
		androidstudio.generate_workspace_gradleproperties(wks)
	end

--
--
--

	function suite.OnWorkspaceGradleProperties()
		prepare_gradleproperties()
		test.capture [[
		]]
	end

	function suite.OnWorkspaceGradleProperties_org_gradle_parallel_boolean()
		project '*'
		gradleproperties {
			['org.gradle.parallel'] = true,
		}
		prepare_gradleproperties()
		test.capture [[
org.gradle.parallel=true
		]]
	end

	function suite.OnWorkspaceGradleProperties_org_gradle_parallel_number()
		project '*'
		gradleproperties {
			['org.gradle.parallel'] = 1,
		}
		prepare_gradleproperties()
		test.capture [[
org.gradle.parallel=1
		]]
	end

	function suite.OnWorkspaceGradleProperties_org_gradle_parallel_string()
		project '*'
		gradleproperties {
			['org.gradle.parallel'] = 'true',
		}
		prepare_gradleproperties()
		test.capture [[
org.gradle.parallel=true
		]]
	end

	function suite.OnWorkspaceGradleProperties_org_gradle_parallel_function()
		project '*'
		gradleproperties {
			['org.gradle.parallel'] = function () return 'true' end,
		}
		prepare_gradleproperties()
		test.capture [[
org.gradle.parallel=true
		]]
	end
