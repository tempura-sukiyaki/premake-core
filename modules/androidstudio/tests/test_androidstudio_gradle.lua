---
-- androidstudio/tests/test_androidstudio_properties.lua
-- Automated test suite for Android Studio project generation.
---

	local suite = test.declare("androidstudio_gradle")
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

	local function prepare_workspacesettingsgradle()
		project '*'
		location 'Workspace'
		project 'MyProject'
		kind 'WindowedApp'
		location 'Workspace/MyProject'
		project 'MyAssetPack'
		kind 'AssetPack'
		location 'Workspace/MyAssetPack'
		wks = p.oven.bakeWorkspace(wks)
		prj = test.getproject(wks, 1)
		androidstudio.generate_workspace_settingsgradle(wks)
	end

	local function prepare_workspacebuildgradle()
		androidstudio.generate_workspace_buildgradle(wks)
	end

	local function prepare_projectbuildgradle()
		project '*'
		location 'Workspace'
		project 'MyProject'
		kind 'WindowedApp'
		location 'Workspace/MyProject'
		wks = p.oven.bakeWorkspace(wks)
		prj = test.getproject(wks, 1)
		androidstudio.generate_project_buildgradle(prj)
	end

	local function prepare_projectbuildgradle_assetpack()
		project '*'
		location 'Workspace'
		project 'MyProject'
		kind 'WindowedApp'
		location 'Workspace/MyProject'
		project 'MyAssetPack'
		kind 'AssetPack'
		location 'Workspace/MyAssetPack'
		wks = p.oven.bakeWorkspace(wks)
		prj = test.getproject(wks, 2)
		androidstudio.generate_project_buildgradle(prj)
	end

--
--
--

-- workspace/settings.gradle

	function suite.OnWorkspaceSettingsGradle()
		project 'MyProject'
		kind 'WindowedApp'
		project 'MyAssetPack'
		kind 'AssetPack'
		prepare_workspacesettingsgradle()
		test.capture [[
include(":MyProject")
project(":MyProject").setProjectDir(file("MyProject"))

include(":MyAssetPack")
		]]
	end

-- workspace/build.gradle

	function suite.OnWorkspaceBuildGradle()
		prepare_workspacebuildgradle()
		test.capture [[
allprojects {
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}

buildscript {
	dependencies {
		classpath "com.android.tools.build:gradle:3.5.2"
	}
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}
		]]
	end

	function suite.OnWorkspaceBuildGradle_classpass1()
		project '*'
		workspacebuildgradle {
			['buildscript.dependencies.%(classpath "com.android.tools.build:gradle:3.5.1")'] = {},
		}
		prepare_workspacebuildgradle()
		test.capture [[
allprojects {
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}

buildscript {
	dependencies {
		classpath "com.android.tools.build:gradle:3.5.1"
	}
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}
		]]
	end

	function suite.OnWorkspaceBuildGradle_classpass2()
		project '*'
		workspacebuildgradle {
			['buildscript.dependencies.%(classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.61")'] = {},
		}
		prepare_workspacebuildgradle()
		test.capture [[
allprojects {
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}

buildscript {
	dependencies {
		classpath "com.android.tools.build:gradle:3.5.2"
		classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.61"
	}
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}
		]]
	end

	function suite.OnWorkspaceBuildGradle_ext_keys()
		project '*'
		workspacebuildgradle {
			['ext.dot'] = 'dot',
			['ext["bracket1"]'] = 'bracket1',
			["ext['bracket2']"] = 'bracket2',
		}
		prepare_workspacebuildgradle()
		test.capture [[
allprojects {
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}

buildscript {
	dependencies {
		classpath "com.android.tools.build:gradle:3.5.2"
	}
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}

ext {
	bracket1 = "bracket1"
	bracket2 = "bracket2"
	dot = "dot"
}
		]]
	end

	function suite.OnWorkspaceBuildGradle_ext_keys_overwrite()
		project '*'
		workspacebuildgradle {
			['ext.overwrite'] = 'overwrite',
			['ext["overwrite"]'] = 'overwrite',
			["ext['overwrite']"] = 'overwrite',
		}
		prepare_workspacebuildgradle()
		test.capture [[
allprojects {
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}

buildscript {
	dependencies {
		classpath "com.android.tools.build:gradle:3.5.2"
	}
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}

ext {
	overwrite = "overwrite"
}
		]]
	end

	function suite.OnWorkspaceBuildGradle_ext_values()
		project '*'
		workspacebuildgradle {
			['ext.boolean'] = true,
			['ext.function'] = function () return '(1 + 1)' end,
			['ext.number'] = 42,
			['ext.string'] = 'string',
			['ext.table'] = { true, function () return '(1 + 1)' end, 42, 'string' },
		}
		prepare_workspacebuildgradle()
		test.capture [[
allprojects {
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}

buildscript {
	dependencies {
		classpath "com.android.tools.build:gradle:3.5.2"
	}
	repositories {
		/* 4000 */ google()
		/* 6000 */ jcenter()
	}
}

ext {
	boolean = true
	function = (1 + 1)
	number = 42
	string = "string"
	table = true, (1 + 1), 42, "string"
}
		]]
	end

-- project/build.gradle

	function suite.OnProjectBuildGradle()
		prepare_projectbuildgradle()
		test.capture [[
apply plugin: "com.android.application"

android {
	buildTypes {
		debug {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Debug"
				}
			}
		}
		release {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Release"
				}
			}
		}
	}
	compileSdkVersion 28
	defaultConfig {
		externalNativeBuild {
			cmake {
				arguments "-DPREMAKE_MAIN_SCRIPT_DIR=${projectDir.path.tr("\\", "/")}/../.."
			}
		}
		minSdkVersion 14
		versionCode 1
		versionName "1.0"
	}
	externalNativeBuild {
		cmake {
			path "../CMakeLists.txt"
		}
	}
	flavorDimensions "premakePlatform"
}
		]]
	end

	function suite.OnProjectBuildGradle_android_buildTypes_debuggable()
		project 'MyProject'
		symbols 'On'
		filter { 'configurations:Release' } do
			optimize 'On'
		end filter {}
		prepare_projectbuildgradle()
		test.capture [[
apply plugin: "com.android.application"

android {
	buildTypes {
		debug {
			debuggable true
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Debug"
				}
			}
		}
		release {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Release"
		]]
	end

	function suite.OnProjectBuildGradle_android_buildTypes_debug_externalNativeBuild_cmake_arguments1()
		project 'MyProject'
		projectbuildgradle {
			['android.buildTypes.debug.externalNativeBuild.cmake.arguments'] = '-DDEFINE'
		}
		prepare_projectbuildgradle()
		test.capture [[
apply plugin: "com.android.application"

android {
	buildTypes {
		debug {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Debug", "-DDEFINE"
		]]
	end

	function suite.OnProjectBuildGradle_android_buildTypes_debug_externalNativeBuild_cmake_arguments2()
		project 'MyProject'
		projectbuildgradle {
			['android.buildTypes.debug.externalNativeBuild.cmake.arguments'] = {
				'-DDEFINE1',
				function () return '"-DDEFINE2"' end,
			}
		}
		prepare_projectbuildgradle()
		test.capture [[
apply plugin: "com.android.application"

android {
	buildTypes {
		debug {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Debug", "-DDEFINE1", "-DDEFINE2"
		]]
	end

	function suite.OnProjectBuildGradle_android_defaultConfig_externalNativeBuild_cmake_arguments1()
		project 'MyProject'
		projectbuildgradle {
			['android.defaultConfig.externalNativeBuild.cmake.arguments'] = '-DDEFINE'
		}
		prepare_projectbuildgradle()
		test.capture [[
apply plugin: "com.android.application"

android {
	buildTypes {
		debug {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Debug"
				}
			}
		}
		release {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Release"
				}
			}
		}
	}
	compileSdkVersion 28
	defaultConfig {
		externalNativeBuild {
			cmake {
				arguments "-DPREMAKE_MAIN_SCRIPT_DIR=${projectDir.path.tr("\\", "/")}/../..", "-DDEFINE"
		]]
	end

	function suite.OnProjectBuildGradle_android_defaultConfig_externalNativeBuild_cmake_arguments2()
		project 'MyProject'
		projectbuildgradle {
			['android.defaultConfig.externalNativeBuild.cmake.arguments'] = {
				'-DDEFINE1',
				function () return '"-DDEFINE2"' end,
			}
		}
		prepare_projectbuildgradle()
		test.capture [[
apply plugin: "com.android.application"

android {
	buildTypes {
		debug {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Debug"
				}
			}
		}
		release {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Release"
				}
			}
		}
	}
	compileSdkVersion 28
	defaultConfig {
		externalNativeBuild {
			cmake {
				arguments "-DPREMAKE_MAIN_SCRIPT_DIR=${projectDir.path.tr("\\", "/")}/../..", "-DDEFINE1", "-DDEFINE2"
		]]
	end

	function suite.OnProjectBuildGradle_android_productFlavors()
		project 'MyProject'
		platforms { 'ARM', 'ARM64', 'x86', 'x86_64' }
		prepare_projectbuildgradle()
		test.capture [[
apply plugin: "com.android.application"

android {
	buildTypes {
		debug {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Debug"
				}
			}
		}
		release {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Release"
				}
			}
		}
	}
	compileSdkVersion 28
	defaultConfig {
		externalNativeBuild {
			cmake {
				arguments "-DPREMAKE_MAIN_SCRIPT_DIR=${projectDir.path.tr("\\", "/")}/../.."
			}
		}
		minSdkVersion 14
		versionCode 1
		versionName "1.0"
	}
	externalNativeBuild {
		cmake {
			path "../CMakeLists.txt"
		}
	}
	flavorDimensions "premakePlatform"
	productFlavors {
		ARM {
			dimension "premakePlatform"
			ndk {
				abiFilters "armeabi-v7a"
			}
		}
		ARM64 {
			dimension "premakePlatform"
			ndk {
				abiFilters "arm64-v8a"
			}
		}
		All {
			dimension "premakePlatform"
			ndk {
				abiFilters "arm64-v8a", "armeabi-v7a", "x86", "x86_64"
			}
		}
		x86 {
			dimension "premakePlatform"
			ndk {
				abiFilters "x86"
			}
		}
		x86_64 {
			dimension "premakePlatform"
			ndk {
				abiFilters "x86_64"
			}
		}
	}
}
		]]
	end

	function suite.OnProjectBuildGradle_sourceSets()
		project 'MyProject'
		projectbuildgradle {
			['android.sourceSets.main.java.srcDirs'] = 'other/java',
			['android.sourceSets.main.res.srcDirs'] = { 'other/res1', 'other/res2' },
			['android.sourceSets.main.manifest.srcFile'] = 'other/AndroidManifest.xml',
		}
		prepare_projectbuildgradle()
		test.capture [[
apply plugin: "com.android.application"

android {
	buildTypes {
		debug {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Debug"
				}
			}
		}
		release {
			debuggable false
			externalNativeBuild {
				cmake {
					arguments "-DPREMAKE_CONFIG_BUILDCFG=Release"
				}
			}
		}
	}
	compileSdkVersion 28
	defaultConfig {
		externalNativeBuild {
			cmake {
				arguments "-DPREMAKE_MAIN_SCRIPT_DIR=${projectDir.path.tr("\\", "/")}/../.."
			}
		}
		minSdkVersion 14
		versionCode 1
		versionName "1.0"
	}
	externalNativeBuild {
		cmake {
			path "../CMakeLists.txt"
		}
	}
	flavorDimensions "premakePlatform"
	sourceSets {
		main {
			java {
				srcDirs "other/java"
			}
			manifest {
				srcFile "other/AndroidManifest.xml"
			}
			res {
				srcDirs "other/res1", "other/res2"
			}
		}
	}
}
		]]
	end

	function suite.OnProjectBuildGradle_AssetPack()
		project 'MyAssetPack'
		projectbuildgradle {
			['assetPack.dynamicDelivery.deliveryType'] = 'install-time',
		}
		prepare_projectbuildgradle_assetpack()
		test.capture [[
apply plugin: "com.android.asset-pack"

assetPack {
	dynamicDelivery {
		deliveryType = "install-time"
	}
	packName = "MyAssetPack"
}
		]]
	end
