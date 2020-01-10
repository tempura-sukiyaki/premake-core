---
-- androidstudio/androidstudio_project.lua
---

	local p = premake
	local m = p.modules.androidstudio

	local androidstudio = p.modules.androidstudio
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree

	local cmake = {}

	function cmake.getlanguages(str)
		local LUT = {
			['C'] = { 'C' },
			['C++'] = { 'CXX', 'C' },
		}
		return LUT[str]
	end

	function cmake.getextensions(str)
		local LUT = {
			['C'] = { '.c' },
			['C++'] = { '.c', '.c++', '.cc', '.cpp', '.cxx' },
		}
		return LUT[str]
	end


	function cmake.getkind(str)
		local LUT = {
			[p.SHAREDLIB]   = 'SHARED',
			[p.STATICLIB]   = 'STATIC',
			[p.WINDOWEDAPP] = 'SHARED',
		}
		return LUT[str]
	end

	function cmake.quoted(str)
		return '"' .. string.gsub(str, '[\\\"]', '\\%0') .. '"'
	end

	function cmake.getpath(str)
		return path.join('${PREMAKE_MAIN_SCRIPT_DIR}', path.getrelative(_MAIN_SCRIPT_DIR, str))
	end

	function cmake.cdialect(cfg)
		LUT = {
			C89 = 90,
			C90 = 90,
			C99 = 99,
			C11 = 11,
			gnu89 = 99,
			gnu90 = 90,
			gnu99 = 99,
			gnu11 = 11,
		}
		return LUT[cfg.cdialect]
	end

	function cmake.cppdialect(cfg)
		LUT = {
			['C++98'] = 98,
			['C++0x'] = 98,
			['C++11'] = 11,
			['C++1y'] = 14,
			['C++14'] = 14,
			['C++1z'] = 17,
			['C++17'] = 17,
			['gnu++98'] = 98,
			['gnu++0x'] = 98,
			['gnu++11'] = 11,
			['gnu++1y'] = 14,
			['gnu++14'] = 14,
			['gnu++1z'] = 17,
			['gnu++17'] = 17,
		}
		return LUT[cfg.cppdialect]
	end

	function cmake.warnings(cfg)
		local enablewarnings = table.translate(cfg.enablewarnings, function(opt)
			return '-W' .. opt
		end)
		local disablewarnings = table.translate(cfg.disablewarnings, function(opt)
			return '-Wno-' .. opt
		end)
		local fatalwarnings = table.translate(cfg.fatalwarnings, function(opt)
			return '-Wno-' .. opt
		end)
		return table.join(enablewarnings, disablewarnings, fatalwarnings)
	end

	cmake.compileflags = {
		--architecture = {
		--	x86 = '-m32',
		--	x86_64 = '-m64',
		--},
		flags = {
			FatalCompileWarnings = '-Werror',
			LinkTimeOptimization = '-flto',
			ShadowedVariables = '-Wshadow',
			UndefinedIdentifiers = '-Wundef',
		},
		floatabi = {
			soft   = '-mfloat-abi=soft',
			softfp = '-mfloat-abi=softfp',
			hard   = '-mfloat-abi=hard',
		},
		floatingpoint = {
			Fast = '-ffast-math',
			Strict = '-ffloat-store',
		},
		isaextensions = {
			MOVBE = '-mmovbe',
			POPCNT = '-mpopcnt',
			PCLMUL = '-mpclmul',
			LZCNT = '-mlzcnt',
			BMI = '-mbmi',
			BMI2 = '-mbmi2',
			F16C = '-mf16c',
			AES = '-maes',
			FMA = '-mfma',
			FMA4 = '-mfma4',
			RDRND = '-mrdrnd',
		},
		omitframepointer = {
			[p.ON] = '-fomit-frame-pointer',
			[p.OFF] = '-fno-omit-frame-pointer'
		},
		optimize = {
			Off = '-O0',
			On = '-O2',
			Debug = '-Og',
			Full = '-O3',
			Size = '-Os',
			Speed = '-O3',
		},
		pic = {
			[p.ON] = '-fPIC',
		},
		strictaliasing = {
			Off = '-fno-strict-aliasing',
			Level1 = { '-fstrict-aliasing', '-Wstrict-aliasing=1' },
			Level2 = { '-fstrict-aliasing', '-Wstrict-aliasing=2' },
			Level3 = { '-fstrict-aliasing', '-Wstrict-aliasing=3' },
		},
		symbols = {
			On = '-g',
			FastLink = '-g',
			Full = '-g',
		},
		unsignedchar = {
			[p.ON] = '-funsigned-char',
			[p.OFF] = '-fno-unsigned-char'
		},
		vectorextensions = {
			['AVX'] = '-mavx',
			['AVX2'] = '-mavx2',
			['SSE'] = '-msse',
			['SSE2'] = '-msse2',
			['SSE3'] = '-msse3',
			['SSSE3'] = '-mssse3',
			['SSE4.1'] = '-msse4.1',
			['NEON'] = '-mfpu=neon',
		},
		warnings = {
			Extra = {'-Wall', '-Wextra'},
			High = '-Wall',
			Off = '-w',
		},
		-- cxx
		exceptionhandling = {
			[p.ON] = '-fexceptions',
			[p.OFF] = '-fno-exceptions',
		},
		flags = {
			NoBufferSecurityCheck = '-fno-stack-protector',
		},
		inlinesvisibility = {
			Hidden = '-fvisibility-inlines-hidden',
		},
		rtti = {
			[p.ON] = '-frtti',
			[p.OFF] = '-fno-rtti',
		},
		visibility = {
			Default = '-fvisibility=default',
			Hidden = '-fvisibility=hidden',
			Internal = '-fvisibility=internal',
			Protected = '-fvisibility=protected',
		},
	}

	function m.generate_project_cmakeliststxt(prj)

		-- buildcommands
		local buildcommands = {}
		local tr = project.getsourcetree(prj)
		for cfg in project.eachconfig(prj) do
			local buildcommandinfos = {}
			tree.traverse(tr, {
				onnode = function(node)
					if not node.configs then
						return
					end
					local fcfg = fileconfig.getconfig(node, cfg)
					if not fileconfig.hasCustomBuildRule(fcfg) then
						return
					end
					local info = {
						node = node,
						message = fcfg.buildmessage,
						commands = os.translateCommandsAndPaths(fcfg.buildcommands, fcfg.project.basedir, fcfg.project.location),
						inputs = { node.abspath },
						outputs = {},
						depends = {},
						transact = false,
					}
					for _, v in ipairs(fcfg.buildinputs) do
						table.insert(info.inputs, v)
					end
					for _, v in ipairs(fcfg.buildoutputs) do
						table.insert(info.outputs, v)
					end 
					table.insert(buildcommandinfos, info)
				end
			}, true)
			for _, mine in ipairs(buildcommandinfos) do
				for _, their in ipairs(buildcommandinfos) do
					if mine ~= their then
						for _, input in ipairs(mine.inputs) do
							if table.contains(their.outputs, input) then
								table.insert(mine.depends, their)
								break
							end
						end
					end
				end
			end
	
			buildcommands[cfg] = {}
			local leftover = #buildcommandinfos
			while leftover > 0 do
				local prev = leftover
				for _, info in ipairs(buildcommandinfos) do
					if not info.transact then
						local transact = true
						for _, depend in ipairs(info.depends) do
							transact = depend.transact
							if not transact then
								break
							end
						end
						if transact then
							table.insert(buildcommands[cfg], info)
							info.transact = true
							leftover = leftover - 1
						end
					end
				end
				if prev == leftover then
					p.error('detect circular reference.')
				end
			end
		end

		local cmakekind = cmake.getkind(prj.kind)

		-- cmake_minimum_required
		p.x('cmake_minimum_required(VERSION 3.6.4)')
		p.outln('')
		-- cmake_minimum_required

		-- include_cuard
		p.x('include_guard(GLOBAL)')
		p.outln('')
		-- include_cuard

		-- include
		do
			local dirs = table.extract(project.getdependencies(prj), 'location')
			if #dirs > 0 then
				table.foreachi(dirs, function(dir)
					p.x('include(%s)', cmake.quoted(path.join(cmake.getpath(dir), 'CMakeLists.txt')))
				end)
				p.outln('')
			end
		end
		-- include

		-- project
		p.outln('')
		if prj.language then
			p.x('project(%s LANGUAGES %s)', cmake.quoted(prj.name), table.concat(cmake.getlanguages(prj.language), ' '))
		else
			p.x('project(%s)', cmake.quoted(prj.name))
		end
		p.outln('')

		-- eachconfig
		for cfg in project.eachconfig(prj) do
			p.outln('')
			p.x('# %s', cfg.name)
			p.push('if(("${PREMAKE_CONFIG_PLATFORM}" STREQUAL %s) AND ("${PREMAKE_CONFIG_BUILDCFG}" STREQUAL %s))', cmake.quoted(cfg.platform), cmake.quoted(cfg.buildcfg))
			p.outln('')

			-- add_library
			if cmakekind then
				local options = table.translate(cfg.files, function(opt)
					local extensions = cmake.getextensions(prj.language)
					local ext = string.lower(path.getextension(opt))
					if table.contains(extensions, ext) then
						return cmake.quoted(cmake.getpath(opt))
					end
				end)
				if #options > 0 then
					p.push('add_library(%s %s', cmake.quoted(prj.name), cmakekind)
					table.sort(options)
					table.foreachi(options, function(opt)
						p.x('%s', opt)
					end)
					p.pop(')')
					p.outln('')
				end
			end
			-- add_library

			-- add_dependencies
			do
				local options = table.extract(project.getdependencies(prj, 'dependOnly'), 'name')
				if #options > 0 then
					if #options == 1 then
						p.x('add_dependencies(%s %s)', cmake.quoted(prj.name), cmake.quoted(options[1]))
					else
						p.push('add_dependencies(%s', cmake.quoted(prj.name))
						table.sort(options)
						table.foreachi(options, function(opt)
							p.x('%s', cmake.quoted(opt))
						end)
						p.pop(')')
					end
					p.outln('')
				end
			end
			-- add_dependencies
			
			-- target_include_directories
			if cmakekind then
				local options = table.translate(cfg.sysincludedirs, function(opt)
					return cmake.quoted(cmake.getpath(opt))
				end)
				if #options > 0 then
					p.push('target_include_directories(%s SYSTEM PRIVATE', cmake.quoted(prj.name))
					table.sort(options)
					table.foreachi(options, function(opt)
						p.x('%s', opt)
					end)
					p.pop(')')
					p.outln('')
				end
			end

			if cmakekind then
				local options = table.translate(cfg.includedirs, function(opt)
					return cmake.quoted(cmake.getpath(opt))
				end)
				if #options > 0 then
					p.push('target_include_directories(%s PRIVATE', cmake.quoted(prj.name))
					table.sort(options)
					table.foreachi(options, function(opt)
						p.x('%s', opt)
					end)
					p.pop(')')
					p.outln('')
				end
			end
			-- target_include_directories

			-- target_compile_definitions
			if cmakekind then
				local options = table.translate(cfg.defines, function(opt)
					return cmake.quoted(opt)
				end)
				if #options > 0 then
					if #options == 1 then
						p.x('target_compile_definitions(%s PRIVATE %s)', cmake.quoted(prj.name), opt)
					else
						p.push('target_compile_definitions(%s PRIVATE', cmake.quoted(prj.name))
						table.sort(options)
						table.foreachi(options, function(opt)
							p.x('%s', opt)
						end)
						p.pop(')')
					end
					p.outln('')
				end
			end
			-- target_compile_definitions

			-- set_target_properties
			if cmakekind then
				local tbl = {}
				--if cfg.flags.MultiProcessorCompile then
				--	--p.x('cmake_host_system_information(RESULT NumberOfLogicalCores QUERY NUMBER_OF_LOGICAL_CORES)')
				--	p.x('cmake_host_system_information(RESULT NumberOfPhysicalCores QUERY NUMBER_OF_PHYSICAL_CORES)')
				--	--p.x('math(EXPR ProcessMax "${NumberOfPhysicalCores} + 1")')
				--	tbl['ANDROID_PROCESS_MAX'] = '${ProcessMax}'
				--else
				--	tbl['ANDROID_PROCESS_MAX'] = '1'
				--end
				if prj.kind == p.STATICLIB then
					tbl['ARCHIVE_OUTPUT_DIRECTORY'] = cmake.quoted(cmake.getpath(cfg.buildtarget.directory))
				elseif prj.kind == p.SHAREDLIB then
					tbl['LIBRARY_OUTPUT_DIRECTORY'] = cmake.quoted(cmake.getpath(cfg.buildtarget.directory))
				end
				do
					local cdialect = cmake.cdialect(cfg)
					if cdialect then
						tbl['C_STANDARD'] = cdialect
					end
				end
				do
					local cppdialect = cmake.cppdialect(cfg)
					if cppdialect then
						tbl['CXX_STANDARD'] = cppdialect
					end
				end
				local flags = table.translate(config.mapFlags(cfg, cmake.compileflags), cmake.quoted)
				local warnings = table.translate(cmake.warnings(cfg), cmake.quoted)

				local keys = table.keys(tbl)
				local options = table.join(flags, warnings)
				if #keys > 0 or #options > 0 then
					p.push('set_target_properties(%s PROPERTIES', cmake.quoted(prj.name))
					table.sort(options)
					local outoption = false
					for key, value in spairs(tbl) do
						if not outoption and key > 'COMPILE_FLAGS' then
							table.foreachi(options, function(opt)
								p.x('COMPILE_FLAGS %s', opt)
							end)
							outoption = true
						end
						p.x('%s %s', key, value)
					end
					p.pop(')')
					p.outln('')
				end
			end
			-- set_target_properties

			-- target_compile_options
			if cmakekind then
				local forceincludes = {}
				local forceincludes = table.translate(cfg.forceincludes, function(opt)
					return '"-include" ' .. cmake.quoted(project.getrelative(prj, opt))
				end)
				local buildoptions = table.translate(cfg.buildoptions, cmake.quoted)
				local options = table.join(forceincludes, buildoptions)
				if #options > 0 then
					p.push('target_compile_options(%s PRIVATE', p.quoted(prj.name))
					table.sort(options)
					for _, opt in ipairs(options) do
						p.x('%s', opt)
					end
					p.pop(')')
					p.outln('')
				end
			end
			-- target_compile_options
 
			-- target_link_libraries
			if cmakekind then
				local libdirs = table.unique(table.join(
					config.getlinks(cfg, 'system', 'directory'),
					cfg.syslibdirs
				))
				libdirs = table.translate(libdirs, function(opt)
					local dir = iif(path.isabsolute(opt), opt, path.join(prj.location, opt)) 
					return cmake.quoted('-L' .. cmake.getpath(dir))
				end)
				local options = table.join(libdirs)
				if #options > 0 then
					p.push('target_link_libraries(%s PRIVATE', cmake.quoted(prj.name))
					table.sort(options)
					table.foreachi(options, function(opt)
						p.x('%s', opt)
					end)
					p.pop(')')
					p.outln('')
				end

				local links = table.unique(table.join(
					config.getlinks(cfg, 'siblings', 'name'),
					config.getlinks(cfg, 'system', 'name')
				))
				links = table.translate(links, function(opt)
					if string.sub(opt, 1, 3) == 'lib' then
						if string.sub(opt, -2) == '.a' then
							opt = string.sub(opt, 4, -3)
						elseif string.sub(opt, -3) == '.so' then
							opt = string.sub(opt, 4, -4)
						end
					end
					return cmake.quoted(opt)
				end)
				table.sort(links)
				if #links > 0 then
					table.insert(links, 1, cmake.quoted('-Wl,--start-group'))
					table.insert(links, cmake.quoted('-Wl,--end-group'))
				end
				local linkoptions = table.translate(cfg.linkoptions, cmake.quoted)
				table.sort(linkoptions)
				local options = table.join(links, linkoptions)
				if #options > 0 then
					p.push('target_link_libraries(%s PRIVATE', cmake.quoted(prj.name))
					table.foreachi(options, function(opt)
						if opt == cmake.quoted('-Wl,--start-group') then
							p.push(opt)
						elseif opt == cmake.quoted('-Wl,--end-group') then
							p.pop(opt)
						else
							p.x('%s', opt)
						end
					end)
					p.pop(')')
					p.outln('')
				end
			end
			-- target_link_libraries

			-- add_custom_command or add_custom_target
			if #buildcommands[cfg] > 0 then
				local useaddcustomcommand = false
				for i, info in ipairs(buildcommands[cfg]) do
					local buildcommandname = cmake.quoted(prj.name .. cfg.buildcfg .. 'Buildcommand' .. i)
					if useaddcustomcommand then
						p.push('add_custom_command(')
						p.push('OUTPUT')
						table.foreachi(info.outputs, function(file)
							p.x('%s', cmake.quoted(cmake.getpath(file)))
						end)
						p.pop()
					else
						p.push('add_custom_target(%s', buildcommandname)
					end
					table.foreachi(info.commands, function(command)
						p.push('COMMAND')
						p.x('%s', command)
						p.pop()
					end)
					if not useaddcustomcommand then
						p.push('BYPRODUCTS')
						table.foreachi(info.outputs, function(file)
							p.x('%s', cmake.quoted(cmake.getpath(file)))
						end)
						p.pop()
					end
					if info.message then
						p.x('COMMENT %s', cmake.quoted(info.message))
					end
					if useaddcustomcommand then
						p.push('DEPENDS')
					else
						p.push('SOURCES')
					end
					table.foreachi(info.inputs, function(file)
						p.x('%s', cmake.quoted(cmake.getpath(file)))
					end)
					p.pop()
					p.pop(')')
					p.outln('')
					if not useaddcustomcommand then
						if 1 < i then
							local depends = prj.name .. cfg.buildcfg .. 'Buildcommand' .. (i - 1)
							p.x('add_dependencies(%s %s)', buildcommandname, cmake.quoted(depends))
						elseif #buildcommands[cfg] == i then
							p.x('add_dependencies(%s %s)', cmake.quoted(prj.name), buildcommandname)
						end
						p.outln('')
					end
				end
			end
			-- add_custom_command or add_custom_target

			p.pop('endif()')
			p.x('# %s', cfg.name)
			p.outln('')
		end
		-- eachconfig

		-- project
	end
