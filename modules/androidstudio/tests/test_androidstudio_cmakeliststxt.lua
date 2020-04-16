---
-- androidstudio/tests/test_androidstudio_properties.lua
-- Automated test suite for Android Studio project generation.
---

	local suite = test.declare("androidstudio_project_cmakeliststxt")
	local p = premake
	local androidstudio = p.modules.androidstudio

---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local wks, prj1, prj2

	function suite.setup()
		_TARGET_OS = 'android'
		p.action.set('androidstudio')
		--p.escaper(androidstudio.esc)
		--p.indent("  ")
		io.eol = '\n'
		wks = test.createWorkspace()
		test.createproject(wks, 2)
		test.createproject(wks, 3)
	end

	local function prepare()
		project '*'
		location 'Workspace'
		project 'MyProject'
		location 'Workspace/MyProject'
		project 'MyProject2'
		location 'Workspace/MyProject2'
		kind 'StaticLib'
		project 'MyProject3'
		location 'Workspace/MyProject3'
		kind 'SharedLib'
		wks = p.oven.bakeWorkspace(wks)
		prj1 = test.getproject(wks, 1)
		prj2 = test.getproject(wks, 2)
		prj3 = test.getproject(wks, 3)
	end

--
--
--

-- cmake_minimum_required

	function suite.OnProjectCMakeListsTxt_cmake_minimum_required()
		prepare()
		androidstudio.cmake_minimum_required(prj1)
		test.capture [[
cmake_minimum_required(VERSION 3.6.4)
		]]
	end

-- dependencies

	function suite.OnProjectCMakeListsTxt_dependencies()
		prepare()
		androidstudio.dependencies(prj1)
		test.isemptycapture()
	end

	function suite.OnProjectCMakeListsTxt_add_subdirectory_OnDependson()
		project 'MyProject'
		dependson { 'MyProject2' }
		prepare()
		androidstudio.dependencies(prj1)
		test.capture [[
# dependencies
if(NOT TARGET "MyProject2")
	add_subdirectory(
		"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject2"
		"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject2"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_dependencies_OnLinks()
		project 'MyProject'
		kind 'WindowedApp'
		links { 'MyProject2' }
		prepare()
		androidstudio.dependencies(prj1)
		test.capture [[
# dependencies
if(NOT TARGET "MyProject2")
	add_subdirectory(
		"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject2"
		"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject2"
		)
endif()
		]]
	end

-- project

	function suite.OnProjectCMakeListsTxt_project_OnLanguageC()
		project 'MyProject'
		language 'C'
		prepare()
		androidstudio.project(prj1)
		test.capture [[
# project
project("MyProject" LANGUAGES C)
		]]
	end

	function suite.OnProjectCMakeListsTxt_project_OnLanguageCpp()
		prepare()
		language 'C++'
		androidstudio.project(prj1)
		test.capture [[
# project
project("MyProject" LANGUAGES CXX C)
		]]
	end

	-- target

	function suite.OnProjectCMakeListsTxt_target_OnKindSharedLib()
		project 'MyProject'
		kind 'SharedLib'
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindSharedLibFiles()
		project 'MyProject'
		kind 'SharedLib'
		files { 'file.cpp' }
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindSharedLibFilesLanguageC()
		project 'MyProject'
		kind 'SharedLib'
		language 'C'
		files { 'file.h', 'file.hh', 'file.hpp', 'file.hxx', 'file.h++', 'file.c', 'file.cc', 'file.cpp', 'file.cxx', 'file.c++' }
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.c"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindSharedLibFilesLanguageCpp()
		project 'MyProject'
		kind 'SharedLib'
		language 'C++'
		files { 'file.h', 'file.hh', 'file.hpp', 'file.hxx', 'file.h++', 'file.c', 'file.cc', 'file.cpp', 'file.cxx', 'file.c++' }
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.c"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cc"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cxx"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.c++"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindSharedLibFilesPlatforms()
		project 'MyProject'
		kind 'SharedLib'
		platforms { 'ARM', 'ARM64' }
		files { 'file.cpp' }
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindStaticLib()
		project 'MyProject'
		kind 'StaticLib'
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" STATIC
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindStaticLibFiles()
		project 'MyProject'
		kind 'StaticLib'
		files { 'file.cpp' }
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" STATIC
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindStaticLibFilesPlatforms()
		project 'MyProject'
		kind 'StaticLib'
		platforms { 'ARM', 'ARM64' }
		files { 'file.cpp' }
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" STATIC
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindWindowedApp()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindWindowedAppFiles()
		project 'MyProject'
		kind 'WindowedApp'
		files { 'file.cpp' }
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindWindowedLibFilesPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		files { 'file.cpp' }
		prepare()
		androidstudio.target(prj1)
		test.capture [[
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_OnKindUtililty()
		prepare()
		kind 'Utility'
		androidstudio.target(prj1)
		test.capture [[
add_custom_target("MyProject")
		]]
	end

	-- dependson

	function suite.OnProjectCMakeListsTxt_dependson()
		prepare()
		androidstudio.dependson(prj1)
		test.isemptycapture()
	end

	function suite.OnProjectCMakeListsTxt_dependson_OnDependson()
		project 'MyProject'
		dependson { 'MyProject2' }
		prepare()
		androidstudio.dependson(prj1)
		test.capture [[
# dependson
add_dependencies("MyProject" "MyProject2")
		]]
	end

	function suite.OnProjectCMakeListsTxt_dependson_OnDependson2()
		project 'MyProject'
		dependson { 'MyProject2', 'MyProject3' }
		prepare()
		androidstudio.dependson(prj1)
		test.capture [[
# dependson
add_dependencies("MyProject"
	"MyProject2"
	"MyProject3"
	)
		]]
	end


	-- includedirs

	function suite.OnProjectCMakeListsTxt_includedirs()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.includedirs(prj1)
		test.capture [[
# includedirs
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_sysincludedirs_OnSysincludedirs()
		project 'MyProject'
		kind 'WindowedApp'
		sysincludedirs { 'sysinclude' }
		prepare()
		androidstudio.sysincludedirs(prj1)
		test.capture [[
# sysincludedirs
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_sysincludedirs_OnSysincludedirsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		sysincludedirs { 'sysinclude' }
		prepare()
		androidstudio.sysincludedirs(prj1)
		test.capture [[
# sysincludedirs
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_includedirs_OnIncludedirs()
		project 'MyProject'
		kind 'WindowedApp'
		includedirs { 'include' }
		prepare()
		androidstudio.includedirs(prj1)
		test.capture [[
# includedirs
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_includedirs_OnIncludedirsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		includedirs { 'include' }
		prepare()
		androidstudio.includedirs(prj1)
		test.capture [[
# includedirs
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
		]]
	end

	-- defines

	function suite.OnProjectCMakeListsTxt_defines()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.defines(prj1)
		test.capture [[
# defines
		]]
	end

	function suite.OnProjectCMakeListsTxt_defines_OnDefines()
		project 'MyProject'
		kind 'WindowedApp'
		defines { 'DEFINE' }
		prepare()
		androidstudio.defines(prj1)
		test.capture [[
# defines
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_definitions("MyProject" PRIVATE "DEFINE")
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_defines_OnDefinesPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		defines { 'DEFINE' }
		prepare()
		androidstudio.defines(prj1)
		test.capture [[
# defines
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_definitions("MyProject" PRIVATE "DEFINE")
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_defines_OnDefines2()
		project 'MyProject'
		kind 'WindowedApp'
		defines { 'DEFINE1', 'DEFINE2' }
		prepare()
		androidstudio.defines(prj1)
		test.capture [[
# defines
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_definitions("MyProject" PRIVATE
		"DEFINE1"
		"DEFINE2"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_defines_OnDefinesFilterBuildcfg()
		project 'MyProject'
		kind 'WindowedApp'
		filter 'configurations:Release' do
			defines { 'NDEBUG' }
		end filter {}
		prepare()
		androidstudio.defines(prj1)
		test.capture [[
# defines
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_definitions("MyProject" PRIVATE "NDEBUG")
endif()
		]]
	end

	-- targetdir

	function suite.OnProjectCMakeListsTxt_targetdir()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.targetdir(prj1)
		test.isemptycapture()
	end

	function suite.OnProjectCMakeListsTxt_targetdir_OnKindSharedLib()
		project 'MyProject'
		kind 'SharedLib'
		prepare()
		androidstudio.targetdir(prj1)
		test.capture [[
# targetdir
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	set_target_properties("MyProject" PROPERTIES
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject/bin/Debug"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_targetdir_OnKindSharedLibPlatforms()
		project 'MyProject'
		kind 'SharedLib'
		platforms { 'ARM', 'ARM64' }
		prepare()
		androidstudio.targetdir(prj1)
		test.capture [[
# targetdir
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject/bin/ARM/Debug"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_targetdir_OnKindStaticLib()
		project 'MyProject'
		kind 'StaticLib'
		prepare()
		androidstudio.targetdir(prj1)
		test.capture [[
# targetdir
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	set_target_properties("MyProject" PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject/bin/Debug"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_targetdir_OnKindStaticLibPlatforms()
		project 'MyProject'
		kind 'StaticLib'
		platforms { 'ARM', 'ARM64' }
		prepare()
		androidstudio.targetdir(prj1)
		test.capture [[
# targetdir
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject/bin/ARM/Debug"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_targetdir_OnKindWindowedApp()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.targetdir(prj1)
		test.isemptycapture()
	end

	function suite.OnProjectCMakeListsTxt_targetdir_OnKindWindowedAppPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		prepare()
		androidstudio.targetdir(prj1)
		test.isemptycapture()
	end

	function suite.OnProjectCMakeListsTxt_compileflags_OnKindWindowedAppVectorExtensionsARM()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM' }
		vectorextensions 'NEON'
		prepare()
		androidstudio.compileflags(prj1)
		test.capture [[
# compileflags
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		COMPILE_FLAGS "-mfpu=neon"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_compileflags_OnKindWindowedAppVectorExtensionsARM64()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM64' }
		vectorextensions 'NEON'
		prepare()
		androidstudio.compileflags(prj1)
		test.capture [[
# compileflags

		]]
	end

	-- forceincludes

	function suite.OnProjectCMakeListsTxt_forceincludes()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.forceincludes(prj1)
		test.capture [[
# forceincludes

		]]
	end

	function suite.OnProjectCMakeListsTxt_forceincludes_OnForceincludes()
		project 'MyProject'
		kind 'WindowedApp'
		forceincludes { 'file.h' }
		prepare()
		androidstudio.forceincludes(prj1)
		test.capture [[
# forceincludes
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	set_target_properties("MyProject" PROPERTIES
		COMPILE_FLAGS "-include ${PREMAKE_MAIN_SCRIPT_DIR}/file.h"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_forceincludes_OnForceincludesPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		forceincludes { 'file.h' }
		prepare()
		androidstudio.forceincludes(prj1)
		test.capture [[
# forceincludes
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		COMPILE_FLAGS "-include ${PREMAKE_MAIN_SCRIPT_DIR}/file.h"
		)
endif()
		]]
	end


	-- pchheader

	function suite.OnProjectCMakeListsTxt_pchheader_OnPchheader()
		project 'MyProject'
		kind 'WindowedApp'
		pchheader 'header.h'
		prepare()
		androidstudio.pchheader(prj1)
		test.capture [[
# pchheader
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_custom_target("MyProjectDebugGeneratePCH"
		COMMAND
			mkdir -p \"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject/obj/Debug\"
		COMMAND
			${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/bin/gcc++ --gcc-toolchain=${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64 --sysroot=${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot --target=armv7-none-linux-androideabi${ANDROID_NATIVE_API_LEVEL} -DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-addrsig -march=armv7-a -m${ANDROID_ARM_MODE} -Wformat -Werror=format-security  -x c++-header \"${PREMAKE_MAIN_SCRIPT_DIR}/header.h\" -o \"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject/obj/Debug/4A2EAAF3-B6E7-149E-3F47-2F78ABFFCA0D.pch\"
		BYPRODUCTS
			"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject/obj/Debug/4A2EAAF3-B6E7-149E-3F47-2F78ABFFCA0D.pch"
		WORKING_DIRECTORY
			"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject"
		)
	add_dependencies("MyProject" "MyProjectDebugGeneratePCH")
	target_compile_options("MyProject" PRIVATE
		-include-pch "${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject/obj/Debug/4A2EAAF3-B6E7-149E-3F47-2F78ABFFCA0D.pch"
		)
endif()
		]]
	end


	-- warnings

	function suite.OnProjectCMakeListsTxt_warnings_OnDisablearnings()
		project 'MyProject'
		kind 'WindowedApp'
		disablewarnings { 'warning' }
		prepare()
		androidstudio.warnings(prj1)
		test.capture [[
# warnings
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_options("MyProject" PRIVATE
		"-Wno-warning"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_warnings_OnDisablewarningsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		disablewarnings { 'warning' }
		prepare()
		androidstudio.warnings(prj1)
		test.capture [[
# warnings
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"-Wno-warning"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_warnings_OnEnablearnings()
		project 'MyProject'
		kind 'WindowedApp'
		enablewarnings { 'warning' }
		prepare()
		androidstudio.warnings(prj1)
		test.capture [[
# warnings
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_options("MyProject" PRIVATE
		"-Wwarning"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_warnings_OnEnablewarningsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		enablewarnings { 'warning' }
		prepare()
		androidstudio.warnings(prj1)
		test.capture [[
# warnings
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"-Wwarning"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_warnings_OnFagalwarnings()
		project 'MyProject'
		kind 'WindowedApp'
		fatalwarnings { 'warning' }
		prepare()
		androidstudio.warnings(prj1)
		test.capture [[
# warnings
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_options("MyProject" PRIVATE
		"-Werror=warning"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_warnings_OnFatalwarningsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		fatalwarnings { 'warning' }
		prepare()
		androidstudio.warnings(prj1)
		test.capture [[
# warnings
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"-Werror=warning"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_buildoptions_OnBuildoptions()
		project 'MyProject'
		kind 'WindowedApp'
		buildoptions { 'buildoption' }
		prepare()
		androidstudio.buildoptions(prj1)
		test.capture [[
# buildoptions
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_options("MyProject" PRIVATE
		"buildoption"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_buildoptions_OnBuildoptionsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		buildoptions { 'buildoption' }
		prepare()
		androidstudio.buildoptions(prj1)
		test.capture [[
# buildoptions
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"buildoption"
		)
endif()
		]]
	end

	-- libdirs

	function suite.OnProjectCMakeListsTxt_libdirs()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.libdirs(prj1)
		test.capture [[
# libdirs

		]]
	end

	function suite.OnProjectCMakeListsTxt_libdirs_OnSyslidirs()
		project 'MyProject'
		kind 'WindowedApp'
		syslibdirs { 'syslibdir' }
		prepare()
		androidstudio.libdirs(prj1)
		test.capture [[
# libdirs
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/syslibdir"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_libdirs_OnSyslidirsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		syslibdirs { 'syslibdir' }
		prepare()
		androidstudio.libdirs(prj1)
		test.capture [[
# libdirs
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/syslibdir"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_libdirs_OnLidirs()
		project 'MyProject'
		kind 'WindowedApp'
		libdirs { 'libdir' }
		prepare()
		androidstudio.libdirs(prj1)
		test.capture [[
# libdirs
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/libdir"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_libdirs_OnLidirsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		libdirs { 'libdir' }
		prepare()
		androidstudio.libdirs(prj1)
		test.capture [[
# libdirs
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/libdir"
		)
endif()
		]]
	end

	-- links

	function suite.OnProjectCMakeListsTxt_links_libraries()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.links(prj1)
		test.capture [[
# links

		]]
	end

	function suite.OnProjectCMakeListsTxt_links_OnLinks()
		project 'MyProject'
		kind 'WindowedApp'
		links { 'link' }
		prepare()
		androidstudio.links(prj1)
		test.capture [[
# links
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_link_libraries("MyProject" PRIVATE
		"-Wl,--start-group"
		"link"
		"-Wl,--end-group"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_links_OnLinksPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		links { 'link' }
		prepare()
		androidstudio.links(prj1)
		test.capture [[
# links
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-Wl,--start-group"
		"link"
		"-Wl,--end-group"
		)
endif()
		]]
	end

	-- buildcommands

	function suite.OnProjectCMakeListsTxt_buildcommands_OnBuildcommands()
		project 'MyProject'
		kind 'WindowedApp'
		files { 'input.txt', }
		filter { 'files:input.txt' } do
			buildcommands {
				'cp -rf input.txt output.txt',
			}
			buildmessage 'input -> output'
			buildinputs {
			}
			buildoutputs {
				'output.txt',
			}
		end filter {}
		prepare()
		androidstudio.buildcommands(prj1)
		test.capture [[
# buildcommands
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	# input -> output
	add_custom_target("MyProjectDebugBuildcommand1"
		COMMAND
			cp -rf input.txt output.txt
		BYPRODUCTS
			"${PREMAKE_MAIN_SCRIPT_DIR}/output.txt"
		WORKING_DIRECTORY
			"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject"
		COMMENT "input -> output"
		SOURCES
			"${PREMAKE_MAIN_SCRIPT_DIR}/input.txt"
		)
	add_dependencies("MyProject" "MyProjectDebugBuildcommand1")
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_buildcommands_OnBuildcommandsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		files { 'input.txt', }
		filter { 'files:input.txt' } do
			buildcommands {
				'cp -rf input.txt output.txt',
			}
			buildmessage 'input -> output'
			buildinputs {
			}
			buildoutputs {
				'output.txt',
			}
		end filter {}
		prepare()
		androidstudio.buildcommands(prj1)
		test.capture [[
# buildcommands
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	# input -> output
	add_custom_target("MyProjectARMDebugBuildcommand1"
		COMMAND
			cp -rf input.txt output.txt
		BYPRODUCTS
			"${PREMAKE_MAIN_SCRIPT_DIR}/output.txt"
		WORKING_DIRECTORY
			"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject"
		COMMENT "input -> output"
		SOURCES
			"${PREMAKE_MAIN_SCRIPT_DIR}/input.txt"
		)
	add_dependencies("MyProject" "MyProjectARMDebugBuildcommand1")
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_buildcommands_OnBuildcommands2()
		project 'MyProject'
		kind 'WindowedApp'
		files { 'input.txt', 'intermidiate.txt', }
		filter { 'files:input.txt' } do
			buildcommands {
				'cp -rf input.txt intermidiate.txt',
			}
			buildmessage 'input -> intermidiate'
			buildinputs {
			}
			buildoutputs {
				'intermidiate.txt',
			}
		end filter {}
		filter { 'files:intermidiate.txt' } do
			buildcommands {
				'cp -rf intermidiate.txt output.txt',
			}
			buildmessage 'intermidiate -> output'
			buildinputs {
			}
			buildoutputs {
				'output.txt',
			}
		end filter {}
		prepare()
		androidstudio.buildcommands(prj1)
		test.capture [[
# buildcommands
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	# intermidiate -> output
	add_custom_target("MyProjectDebugBuildcommand2"
		COMMAND
			cp -rf intermidiate.txt output.txt
		BYPRODUCTS
			"${PREMAKE_MAIN_SCRIPT_DIR}/output.txt"
		WORKING_DIRECTORY
			"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject"
		COMMENT "intermidiate -> output"
		SOURCES
			"${PREMAKE_MAIN_SCRIPT_DIR}/intermidiate.txt"
		)
	add_dependencies("MyProject" "MyProjectDebugBuildcommand2")
	# input -> intermidiate
	add_custom_target("MyProjectDebugBuildcommand1"
		COMMAND
			cp -rf input.txt intermidiate.txt
		BYPRODUCTS
			"${PREMAKE_MAIN_SCRIPT_DIR}/intermidiate.txt"
		WORKING_DIRECTORY
			"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject"
		COMMENT "input -> intermidiate"
		SOURCES
			"${PREMAKE_MAIN_SCRIPT_DIR}/input.txt"
		)
	add_dependencies("MyProjectDebugBuildcommand2" "MyProjectDebugBuildcommand1")
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_prebuildcommands_OnPrebuildcommands()
		project 'MyProject'
		kind 'WindowedApp'
		prebuildcommands {
			'cp -rf input.txt output.txt',
		}
		prepare()
		androidstudio.prebuildcommands(prj1)
		test.capture [[
# prebuildcommands
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_custom_command(
		TARGET "MyProject"
		PRE_BUILD
		COMMAND
			cp -rf input.txt output.txt
		WORKING_DIRECTORY
			"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_prelinkcommands_OnPrelinkcommands()
		project 'MyProject'
		kind 'WindowedApp'
		prelinkcommands {
			'cp -rf input.txt output.txt',
		}
		prepare()
		androidstudio.prelinkcommands(prj1)
		test.capture [[
# prelinkcommands
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_custom_command(
		TARGET "MyProject"
		PRE_LINK
		COMMAND
			cp -rf input.txt output.txt
		WORKING_DIRECTORY
			"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_postbuildcommands_OnPostbuildcommands()
		project 'MyProject'
		kind 'WindowedApp'
		postbuildcommands {
			'cp -rf input.txt output.txt',
		}
		prepare()
		androidstudio.postbuildcommands(prj1)
		test.capture [[
# postbuildcommands
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_custom_command(
		TARGET "MyProject"
		POST_BUILD
		COMMAND
			cp -rf input.txt output.txt
		WORKING_DIRECTORY
			"${PREMAKE_MAIN_SCRIPT_DIR}/Workspace/MyProject"
		)
endif()
		]]
	end

