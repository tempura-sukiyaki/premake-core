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
	end

	local function prepare()
		wks = p.oven.bakeWorkspace(wks)
		prj1 = test.getproject(wks, 1)
		project 'MyProject'
		location 'MyProject'
		prj2 = test.createproject(wks, 2)
		project 'MyProject2'
		location 'MyProject2'
		kind 'StaticLib'
		prj3 = test.createproject(wks, 3)
		project 'MyProject3'
		location 'MyProject3'
		kind 'SharedLib'
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

-- add_subdirectory

	function suite.OnProjectCMakeListsTxt_add_subdirectory()
		prepare()
		androidstudio.add_subdirectory(prj1)
		test.capture [[
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_subdirectory_OnDependson()
		project 'MyProject'
		dependson { 'MyProject2' }
		prepare()
		androidstudio.add_subdirectory(prj1)
		test.capture [[
# add_subdirectory
if(NOT TARGET "MyProject2")
	add_subdirectory(
		"${PREMAKE_MAIN_SCRIPT_DIR}/MyProject2"
		"${PREMAKE_MAIN_SCRIPT_DIR}/MyProject2"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_subdirectory_OnLinks()
		project 'MyProject'
		kind 'WindowedApp'
		links { 'MyProject2' }
		prepare()
		androidstudio.add_subdirectory(prj1)
		test.capture [[
# add_subdirectory
if(NOT TARGET "MyProject2")
	add_subdirectory(
		"${PREMAKE_MAIN_SCRIPT_DIR}/MyProject2"
		"${PREMAKE_MAIN_SCRIPT_DIR}/MyProject2"
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

	-- add_library

	function suite.OnProjectCMakeListsTxt_add_library_OnKindSharedLib()
		project 'MyProject'
		kind 'SharedLib'
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindSharedLibFiles()
		project 'MyProject'
		kind 'SharedLib'
		files { 'file.cpp' }
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindSharedLibFilesLanguageC()
		project 'MyProject'
		kind 'SharedLib'
		language 'C'
		files { 'file.h', 'file.hh', 'file.hpp', 'file.hxx', 'file.h++', 'file.c', 'file.cc', 'file.cpp', 'file.cxx', 'file.c++' }
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.c"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.c"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindSharedLibFilesLanguageCpp()
		project 'MyProject'
		kind 'SharedLib'
		language 'C++'
		files { 'file.h', 'file.hh', 'file.hpp', 'file.hxx', 'file.h++', 'file.c', 'file.cc', 'file.cpp', 'file.cxx', 'file.c++' }
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.c"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.c++"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cc"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cxx"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.c"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.c++"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cc"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cxx"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindSharedLibFilesPlatforms()
		project 'MyProject'
		kind 'SharedLib'
		platforms { 'ARM', 'ARM64' }
		files { 'file.cpp' }
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindStaticLib()
		project 'MyProject'
		kind 'StaticLib'
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" STATIC
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" STATIC
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindStaticLibFiles()
		project 'MyProject'
		kind 'StaticLib'
		files { 'file.cpp' }
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" STATIC
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" STATIC
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindStaticLibFilesPlatforms()
		project 'MyProject'
		kind 'StaticLib'
		platforms { 'ARM', 'ARM64' }
		files { 'file.cpp' }
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" STATIC
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" STATIC
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" STATIC
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" STATIC
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindWindowedApp()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindWindowedAppFiles()
		project 'MyProject'
		kind 'WindowedApp'
		files { 'file.cpp' }
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindWindowedLibFilesPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		files { 'file.cpp' }
		prepare()
		androidstudio.add_library(prj1)
		test.capture [[
# add_library
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	add_library("MyProject" SHARED
		"${PREMAKE_MAIN_SCRIPT_DIR}/file.cpp"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_library_OnKindUtililty()
		prepare()
		kind 'Utility'
		androidstudio.add_library(prj1)
		test.capture [[
# add_custom_target
add_custom_target("MyProject")
		]]
	end

	-- add_dependencies

	function suite.OnProjectCMakeListsTxt_add_dependencies()
		prepare()
		androidstudio.add_dependencies(prj1)
		test.capture [[
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_dependencies_OnDependson()
		project 'MyProject'
		dependson { 'MyProject2' }
		prepare()
		androidstudio.add_dependencies(prj1)
		test.capture [[
# add_dependencies
add_dependencies("MyProject" "MyProject2")
		]]
	end

	function suite.OnProjectCMakeListsTxt_add_dependencies_OnDependson2()
		project 'MyProject'
		dependson { 'MyProject2', 'MyProject3' }
		prepare()
		androidstudio.add_dependencies(prj1)
		test.capture [[
# add_dependencies
add_dependencies("MyProject"
	"MyProject2"
	"MyProject3"
	)
		]]
	end


	-- target_include_directories

	function suite.OnProjectCMakeListsTxt_target_include_directories()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.target_include_directories(prj1)
		test.capture [[
# target_include_directories
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_include_directories_OnSysincludedirs()
		project 'MyProject'
		kind 'WindowedApp'
		sysincludedirs { 'sysinclude' }
		prepare()
		androidstudio.target_include_directories(prj1)
		test.capture [[
# target_include_directories
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_include_directories_OnSysincludedirsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		sysincludedirs { 'sysinclude' }
		prepare()
		androidstudio.target_include_directories(prj1)
		test.capture [[
# target_include_directories
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_include_directories_OnIncludedirs()
		project 'MyProject'
		kind 'WindowedApp'
		includedirs { 'include' }
		prepare()
		androidstudio.target_include_directories(prj1)
		test.capture [[
# target_include_directories
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_include_directories_OnIncludedirsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		includedirs { 'include' }
		prepare()
		androidstudio.target_include_directories(prj1)
		test.capture [[
# target_include_directories
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_include_directories_OnSysincludedirsIncludedirs()
		project 'MyProject'
		kind 'WindowedApp'
		sysincludedirs { 'sysinclude' }
		includedirs { 'include' }
		prepare()
		androidstudio.target_include_directories(prj1)
		test.capture [[
# target_include_directories
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_include_directories_OnSysincludedirsIncludedirsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		sysincludedirs { 'sysinclude' }
		includedirs { 'include' }
		prepare()
		androidstudio.target_include_directories(prj1)
		test.capture [[
# target_include_directories
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_include_directories("MyProject" SYSTEM PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/sysinclude"
		)
	target_include_directories("MyProject" PRIVATE
		"${PREMAKE_MAIN_SCRIPT_DIR}/include"
		)
endif()
		]]
	end

	-- target_compile_definitions

	function suite.OnProjectCMakeListsTxt_target_compile_definitions()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.target_compile_definitions(prj1)
		test.capture [[
# target_compile_definitions
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_compile_definitions_OnDefines()
		project 'MyProject'
		kind 'WindowedApp'
		defines { 'DEFINE' }
		prepare()
		androidstudio.target_compile_definitions(prj1)
		test.capture [[
# target_compile_definitions
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_definitions("MyProject" PRIVATE "DEFINE")
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_definitions("MyProject" PRIVATE "DEFINE")
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_compile_definitions_OnDefinesPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		defines { 'DEFINE' }
		prepare()
		androidstudio.target_compile_definitions(prj1)
		test.capture [[
# target_compile_definitions
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_definitions("MyProject" PRIVATE "DEFINE")
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_definitions("MyProject" PRIVATE "DEFINE")
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_definitions("MyProject" PRIVATE "DEFINE")
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_definitions("MyProject" PRIVATE "DEFINE")
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_compile_definitions_OnDefines2()
		project 'MyProject'
		kind 'WindowedApp'
		defines { 'DEFINE1', 'DEFINE2' }
		prepare()
		androidstudio.target_compile_definitions(prj1)
		test.capture [[
# target_compile_definitions
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_definitions("MyProject" PRIVATE
		"DEFINE1"
		"DEFINE2"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_definitions("MyProject" PRIVATE
		"DEFINE1"
		"DEFINE2"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_compile_definitions_OnDefinesFilterBuildcfg()
		project 'MyProject'
		kind 'WindowedApp'
		filter 'configurations:Release'
		defines { 'NDEBUG' }
		prepare()
		androidstudio.target_compile_definitions(prj1)
		test.capture [[
# target_compile_definitions
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_definitions("MyProject" PRIVATE "NDEBUG")
endif()
		]]
	end

	-- set_target_properties

	function suite.OnProjectCMakeListsTxt_set_target_properties()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.set_target_properties(prj1)
		test.capture [[
# set_target_properties
		]]
	end

	function suite.OnProjectCMakeListsTxt_set_target_properties_OnKindSharedLib()
		project 'MyProject'
		kind 'SharedLib'
		prepare()
		androidstudio.set_target_properties(prj1)
		test.capture [[
# set_target_properties
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	set_target_properties("MyProject" PROPERTIES
		COMPILE_FLAGS "-fPIC"
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/Debug"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	set_target_properties("MyProject" PROPERTIES
		COMPILE_FLAGS "-fPIC"
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/Release"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_set_target_properties_OnKindSharedLibPlatforms()
		project 'MyProject'
		kind 'SharedLib'
		platforms { 'ARM', 'ARM64' }
		prepare()
		androidstudio.set_target_properties(prj1)
		test.capture [[
# set_target_properties
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		COMPILE_FLAGS "-fPIC"
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM/Debug"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		COMPILE_FLAGS "-fPIC"
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM64/Debug"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		COMPILE_FLAGS "-fPIC"
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM/Release"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		COMPILE_FLAGS "-fPIC"
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM64/Release"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_set_target_properties_OnKindStaticLib()
		project 'MyProject'
		kind 'StaticLib'
		prepare()
		androidstudio.set_target_properties(prj1)
		test.capture [[
# set_target_properties
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	set_target_properties("MyProject" PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/Debug"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	set_target_properties("MyProject" PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/Release"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_set_target_properties_OnKindStaticLibPlatforms()
		project 'MyProject'
		kind 'StaticLib'
		platforms { 'ARM', 'ARM64' }
		prepare()
		androidstudio.set_target_properties(prj1)
		test.capture [[
# set_target_properties
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM/Debug"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM64/Debug"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM/Release"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM64/Release"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_set_target_properties_OnKindWindowedApp()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.set_target_properties(prj1)
		test.capture [[
# set_target_properties
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	set_target_properties("MyProject" PROPERTIES
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/Debug"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	set_target_properties("MyProject" PROPERTIES
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/Release"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_set_target_properties_OnKindWindowedAppPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		prepare()
		androidstudio.set_target_properties(prj1)
		test.capture [[
# set_target_properties
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM/Debug"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM64/Debug"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM/Release"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	set_target_properties("MyProject" PROPERTIES
		LIBRARY_OUTPUT_DIRECTORY "${PREMAKE_MAIN_SCRIPT_DIR}/bin/ARM64/Release"
		)
endif()
		]]
	end

	-- target_compile_options

	function suite.OnProjectCMakeListsTxt_target_compile_options()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.target_compile_options(prj1)
		test.capture [[
# target_compile_options
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_compile_options_OnForceincludes()
		project 'MyProject'
		kind 'WindowedApp'
		forceincludes { 'file.h' }
		prepare()
		androidstudio.target_compile_options(prj1)
		test.capture [[
# target_compile_options
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_options("MyProject" PRIVATE
		"-include" "file.h"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_options("MyProject" PRIVATE
		"-include" "file.h"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_compile_options_OnForceincludesPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		forceincludes { 'file.h' }
		prepare()
		androidstudio.target_compile_options(prj1)
		test.capture [[
# target_compile_options
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"-include" "file.h"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"-include" "file.h"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"-include" "file.h"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"-include" "file.h"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_compile_options_OnBuildoptions()
		project 'MyProject'
		kind 'WindowedApp'
		buildoptions { 'buildoption' }
		prepare()
		androidstudio.target_compile_options(prj1)
		test.capture [[
# target_compile_options
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_options("MyProject" PRIVATE
		"buildoption"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_compile_options("MyProject" PRIVATE
		"buildoption"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_compile_options_OnBuildoptionsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		buildoptions { 'buildoption' }
		prepare()
		androidstudio.target_compile_options(prj1)
		test.capture [[
# target_compile_options
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"buildoption"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"buildoption"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"buildoption"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_compile_options("MyProject" PRIVATE
		"buildoption"
		)
endif()
		]]
	end

	-- target_link_directories

	function suite.OnProjectCMakeListsTxt_target_link_directories()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.target_link_directories(prj1)
		test.capture [[
# target_link_directories
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_link_directories_OnSyslidirs()
		project 'MyProject'
		kind 'WindowedApp'
		syslibdirs { 'syslibdir' }
		prepare()
		androidstudio.target_link_directories(prj1)
		test.capture [[
# target_link_directories
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/syslibdir"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/syslibdir"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_link_directories_OnSyslidirsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		syslibdirs { 'syslibdir' }
		prepare()
		androidstudio.target_link_directories(prj1)
		test.capture [[
# target_link_directories
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/syslibdir"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/syslibdir"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/syslibdir"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/syslibdir"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_link_directories_OnLidirs()
		project 'MyProject'
		kind 'WindowedApp'
		libdirs { 'libdir' }
		prepare()
		androidstudio.target_link_directories(prj1)
		test.capture [[
# target_link_directories
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/libdir"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/libdir"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_link_directories_OnLidirsPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		libdirs { 'libdir' }
		prepare()
		androidstudio.target_link_directories(prj1)
		test.capture [[
# target_link_directories
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/libdir"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/libdir"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/libdir"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-L${PREMAKE_MAIN_SCRIPT_DIR}/libdir"
		)
endif()
		]]
	end

	-- target_link_libraries

	function suite.OnProjectCMakeListsTxt_target_link_libraries()
		project 'MyProject'
		kind 'WindowedApp'
		prepare()
		androidstudio.target_link_libraries(prj1)
		test.capture [[
# target_link_libraries
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_link_libraries_OnLinks()
		project 'MyProject'
		kind 'WindowedApp'
		links { 'link' }
		prepare()
		androidstudio.target_link_libraries(prj1)
		test.capture [[
# target_link_libraries
if("Debug" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_link_libraries("MyProject" PRIVATE
		"-Wl,--start-group"
		"link"
		"-Wl,--end-group"
		)
endif()
if("Release" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")
	target_link_libraries("MyProject" PRIVATE
		"-Wl,--start-group"
		"link"
		"-Wl,--end-group"
		)
endif()
		]]
	end

	function suite.OnProjectCMakeListsTxt_target_link_libraries_OnLinksPlatforms()
		project 'MyProject'
		kind 'WindowedApp'
		platforms { 'ARM', 'ARM64' }
		links { 'link' }
		prepare()
		androidstudio.target_link_libraries(prj1)
		test.capture [[
# target_link_libraries
if("Debug|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-Wl,--start-group"
		"link"
		"-Wl,--end-group"
		)
endif()
if("Debug|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-Wl,--start-group"
		"link"
		"-Wl,--end-group"
		)
endif()
if("Release|ARM" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-Wl,--start-group"
		"link"
		"-Wl,--end-group"
		)
endif()
if("Release|ARM64" STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")
	target_link_libraries("MyProject" PRIVATE
		"-Wl,--start-group"
		"link"
		"-Wl,--end-group"
		)
endif()
		]]
	end

	-- add_custom_command

	function suite.OnProjectCMakeListsTxt_add_custom_command()
		prepare()
		androidstudio.add_custom_command(prj1)
		test.capture [[
		]]
	end
