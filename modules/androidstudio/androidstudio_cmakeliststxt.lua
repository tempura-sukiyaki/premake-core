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

	m.cmake = {}

	local cmake = m.cmake

	cmake.minimum_required = { 3, 6, 4 }
	cmake.buildcommands_as_add_custom_command = false


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
			gnu89 = 90,
			gnu90 = 90,
			gnu99 = 99,
			gnu11 = 11,
		}
		return LUT[cfg.cdialect]
	end


	function cmake.cppdialect(cfg)
		LUT = {
			['C++98'] = 98,
			['C++0x'] = 11,
			['C++11'] = 11,
			['C++1y'] = 14,
			['C++14'] = 14,
			['C++1z'] = 17,
			['C++17'] = 17,
			['gnu++98'] = 98,
			['gnu++0x'] = 11,
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
			return '-Werror=' .. opt
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
		floatabi = function (cfg, mappings)
			if not cfg.architecture or cfg.architecture == p.ARM then
				return {
					soft = '-mfloat-abi=soft',
					softfp = '-mfloat-abi=softfp',
					hard = '-mfloat-abi=hard',
				}
			else
				return {}
			end
		end,
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
		vectorextensions = function (cfg, mappings)
			if not cfg.architecture or cfg.architecture == p.ARM then
				return {
					['NEON'] = '-mfpu=neon',
				}
			elseif cfg.architecture == p.ARM64 then
				return {}
			elseif cfg.architecture == p.X86 or cfg.architecture == p.X86_64 then
				return {
					['AVX'] = '-mavx',
					['AVX2'] = '-mavx2',
					['SSE'] = '-msse',
					['SSE2'] = '-msse2',
					['SSE3'] = '-msse3',
					['SSSE3'] = '-mssse3',
					['SSE4.1'] = '-msse4.1',
				}
			end
		end,
		warnings = {
			Extra = {'-Wall', '-Wextra'},
			High = '-Wall',
			Off = '-w',
		},
		-- cxx
		exceptionhandling = {
			[p.OFF] = '-fno-exceptions',
		},
		flags = {
			NoBufferSecurityCheck = '-fno-stack-protector',
		},
		inlinesvisibility = {
			Hidden = '-fvisibility-inlines-hidden',
		},
		rtti = {
			[p.OFF] = '-fno-rtti',
		},
		visibility = {
			Default = '-fvisibility=default',
			Hidden = '-fvisibility=hidden',
			Internal = '-fvisibility=internal',
			Protected = '-fvisibility=protected',
		},
	}


	function m.cmake_minimum_required(prj)
		_x(0, 'cmake_minimum_required(VERSION %s)', table.concat(m.cmake.minimum_required, '.'))
		p.outln('')
	end


	function m.add_subdirectory(prj)
		local deps = project.getdependencies(prj)
		if #deps > 0 then
			_p(0, '# add_subdirectory')
			table.foreachi(deps, function(dep)
				_x(0, 'if(NOT TARGET %s)', cmake.quoted(dep.name))
				_p(1, 'add_subdirectory(')
				_p(2, cmake.quoted(cmake.getpath(dep.location)))
				_p(2, cmake.quoted(cmake.getpath(dep.location)))
				_p(2, ')')
				_p(0, 'endif()')
			end)
			p.outln('')
		end
	end


	function m.project(prj)
		_p(0, '# project')
		if prj.language then
			_x(0, 'project(%s LANGUAGES %s)', cmake.quoted(prj.name), table.concat(cmake.getlanguages(prj.language), ' '))
		else
			_x(0, 'project(%s)', cmake.quoted(prj.name))
		end
		p.outln('')
	end


	local function ifcondition(cfg)
		if cfg.platform then
			return 'if(%s STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")', cmake.quoted(cfg.name)
		end
		return 'if(%s STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")', cmake.quoted(cfg.buildcfg)
	end


	function m.add_library(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# add_library')
			for cfg in project.eachconfig(prj) do
				_p(0, ifcondition(cfg))
				_x(1, 'add_library(%s %s', cmake.quoted(prj.name), cmakekind)
				local options = table.translate(cfg.files, function(opt)
					local extensions = cmake.getextensions(prj.language)
					local ext = string.lower(path.getextension(opt))
					if table.contains(extensions, ext) then
						return cmake.quoted(cmake.getpath(opt))
					end
				end)
				if #options > 0 then
					table.sort(options)
					table.foreachi(options, function(opt)
						_p(2, opt)
					end)
				end
				_p(2, ')')
				_p(0, 'endif()')
			end
		else
			_p(0, '# add_custom_target')
			_x(0, 'add_custom_target(%s)', cmake.quoted(prj.name))
		end
		p.outln('')
	end


	function m.add_dependencies(prj)
		local options = table.extract(project.getdependencies(prj, 'dependOnly'), 'name')
		if #options > 0 then
			_p(0, '# add_dependencies')
			if #options == 1 then
				_x(0, 'add_dependencies(%s %s)', cmake.quoted(prj.name), cmake.quoted(options[1]))
			else
				_x(0, 'add_dependencies(%s', cmake.quoted(prj.name))
				table.sort(options)
				table.foreachi(options, function(opt)
					_x(1, '%s', cmake.quoted(opt))
				end)
				_x(1, ')')
			end
			p.outln('')
		end
	end


	local function getsysincludedirs(cfg, callback)
		return table.translate(cfg.sysincludedirs, function(opt)
			return callback(cmake.getpath(opt))
		end)
	end

	local function getincludedirs(cfg, callback)
		return table.translate(cfg.includedirs, function(opt)
			return callback(cmake.getpath(opt))
		end)
	end

	function m.target_include_directories(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# target_include_directories')
			for cfg in project.eachconfig(prj) do
				local sysincludedirs = getsysincludedirs(cfg, cmake.quoted)
				local includedirs = getincludedirs(cfg, cmake.quoted)
				if #sysincludedirs > 0 or #includedirs > 0 then
					_p(0, ifcondition(cfg))
					if #sysincludedirs > 0 then
						_x(1, 'target_include_directories(%s SYSTEM PRIVATE', cmake.quoted(prj.name))
						table.sort(sysincludedirs)
						table.foreachi(sysincludedirs, function(opt)
							_p(2, opt)
						end)
						_p(2, ')')
					end
					if #includedirs > 0 then
						_x(1, 'target_include_directories(%s PRIVATE', cmake.quoted(prj.name))
						table.sort(includedirs)
						table.foreachi(includedirs, function(opt)
							_p(2, opt)
						end)
						_p(2, ')')
					end
					_p(0, 'endif()')
				end
			end
			p.outln('')
		end
	end


	local function getdefines(cfg, callback)
		return table.translate(cfg.defines, callback)
	end

	function m.target_compile_definitions(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# target_compile_definitions')
			for cfg in project.eachconfig(prj) do
				local options = getdefines(cfg, cmake.quoted)
				if #options > 0 then
					_p(0, ifcondition(cfg))
					if #options == 1 then
						_x(1, 'target_compile_definitions(%s PRIVATE %s)', cmake.quoted(prj.name), options[1])
					else
						_x(1, 'target_compile_definitions(%s PRIVATE', cmake.quoted(prj.name))
						table.sort(options)
						table.foreachi(options, function(opt)
							_p(2, opt)
						end)
						_p(2, ')')
					end
					_p(0, 'endif()')
				end
			end
			p.outln('')
		end
	end


	local function getcompileflags(cfg, callback)
		return table.translate(config.mapFlags(cfg, cmake.compileflags), callback)
	end

	function m.set_target_properties(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# set_target_properties')
			for cfg in project.eachconfig(prj) do
				local tbl = {}
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
				local flags = getcompileflags(cfg, cmake.quoted)
				local keys = table.keys(tbl)
				local options = table.join(flags)
				local function outoptions()
					table.foreachi(options, function(opt)
						_x(2, 'COMPILE_FLAGS %s', opt)
					end)
					return true
				end
				if #keys > 0 or #options > 0 then
					_p(0, ifcondition(cfg))
					_x(1, 'set_target_properties(%s PROPERTIES', cmake.quoted(prj.name))
					table.sort(options)
					local isout = false
					for key, value in spairs(tbl) do
						if not isout and key > 'COMPILE_FLAGS' then
							isout = outoptions()
						end
						_x(2, '%s %s', key, value)
					end
					if not isout then
						outoptions()
					end
				_p(2, ')')
					_p(0, 'endif()')
				end
			end
			p.outln('')
		end
	end


	local function getbuildoptions(cfg, callback)
		local warnings = table.translate(cmake.warnings(cfg), callback)
		local options = table.translate(cfg.buildoptions, callback)
		return table.join(warnings, options)
	end

	function m.target_compile_options(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# target_compile_options')
			for cfg in project.eachconfig(prj) do
				local forceincludes = table.translate(cfg.forceincludes, function(opt)
					return '"-include" ' .. cmake.quoted(project.getrelative(prj, opt))
				end)
				local buildoptions = getbuildoptions(cfg, cmake.quoted)
				local options = table.join(forceincludes, buildoptions)
				if #options > 0 then
					_p(0, ifcondition(cfg))
					_x(1, 'target_compile_options(%s PRIVATE', cmake.quoted(prj.name))
					table.sort(options)
					for _, opt in ipairs(options) do
						_p(2, opt)
					end
					_p(2, ')')
					_p(0, 'endif()')
				end
			end
			p.outln('')
		end
	end


	function m.target_link_directories(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# target_link_directories')
			for cfg in project.eachconfig(prj) do
				local libdirs = table.unique(table.join(
					config.getlinks(cfg, 'system', 'directory'),
					cfg.syslibdirs
				))

				local version = m.cmake.minimum_required
				if version[1] > 4 or (version[1] == 3 and version[2] >= 12) then
					libdirs = table.translate(libdirs, function(opt)
						local dir = iif(path.isabsolute(opt), opt, path.join(prj.location, opt))
						return cmake.quoted(cmake.getpath(dir))
					end)
					local options = table.join(libdirs)
					if #options > 0 then
						_p(0, ifcondition(cfg))
						_x(1, 'target_link_directories(%s PRIVATE', cmake.quoted(prj.name))
						table.sort(options)
						table.foreachi(options, function(opt)
							_p(2, opt)
						end)
						_p(2, ')')
						_p(0, 'endif()')
					end
				else
					libdirs = table.translate(libdirs, function(opt)
						local dir = iif(path.isabsolute(opt), opt, path.join(prj.location, opt))
						return cmake.quoted('-L' .. cmake.getpath(dir))
					end)
					local options = table.join(libdirs)
					if #options > 0 then
						_p(0, ifcondition(cfg))
						_x(1, 'target_link_libraries(%s PRIVATE', cmake.quoted(prj.name))
						table.sort(options)
						table.foreachi(options, function(opt)
							_p(2, opt)
						end)
						_p(2, ')')
						_p(0, 'endif()')
					end
				end
			end
			p.outln('')
		end
	end

	function m.target_link_libraries(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# target_link_libraries')
			for cfg in project.eachconfig(prj) do
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
					_p(0, ifcondition(cfg))
					_x(1, 'target_link_libraries(%s PRIVATE', cmake.quoted(prj.name))
					table.foreachi(options, function(opt)
						_p(2, opt)
					end)
					_p(2, ')')
					_p(0, 'endif()')
				end
			end
			p.outln('')
		end
	end


	function m.add_custom_command(prj)

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

		_p(0, iif(m.cmake.buildcommands_as_add_custom_command, '# add_custom_command', '# add_custom_target'))
		for cfg in project.eachconfig(prj) do
			if #buildcommands[cfg] > 0 then
				_p(0, ifcondition(cfg))
				local prevname = cmake.quoted(prj.name)
				for i = #buildcommands[cfg], 1, -1 do
					local info = buildcommands[cfg][i]
					local name = cmake.quoted(prj.name .. cfg.buildcfg .. 'Buildcommand' .. i)
					_p(1, '# %s', info.message)
					if m.cmake.buildcommands_as_add_custom_command then
						_p(1, 'add_custom_command(')
						_p(2, 'OUTPUT')
						table.foreachi(info.outputs, function(file)
							_x(3, '%s', cmake.quoted(cmake.getpath(file)))
						end)
					else
						_x(1, 'add_custom_target(%s', name)
					end
					table.foreachi(info.commands, function(command)
						_p(2, 'COMMAND')
						_x(3, '%s', string.gsub(command, '[\\\"()]', '\\%1'))
					end)
					if not m.cmake.buildcommands_as_add_custom_command then
						_p(2, 'BYPRODUCTS')
						table.foreachi(info.outputs, function(file)
							_p(3, cmake.quoted(cmake.getpath(file)))
						end)
					end
					_p(2, 'WORKING_DIRECTORY')
					_p(3, cmake.quoted(cmake.getpath(prj.location)))
					if info.message then
						_p(2, 'COMMENT %s', cmake.quoted(info.message))
					end
					if m.cmake.buildcommands_as_add_custom_command then
						_p(2, 'DEPENDS')
					else
						_p(2, 'SOURCES')
					end
					table.foreachi(info.inputs, function(file)
						_x(3, '%s', cmake.quoted(cmake.getpath(file)))
					end)
					_p(2, ')')
					if not m.cmake.buildcommands_as_add_custom_command then
						_x(1, 'add_dependencies(%s %s)', prevname, name)
						prevname = name
					end
				end
				_p(0, 'endif()')
			end
		end

		if not m.cmake.buildcommands_as_add_custom_command then
			p.outln('')
			_p(0, '# add_custom_command')
		end

		for cfg in project.eachconfig(prj) do	
			if (cfg.pchheader and not cfg.flags.NoPCH) or #cfg.prebuildcommands > 0 or #cfg.prelinkcommands > 0 or #cfg.postbuildcommands > 0 then
				_p(0, ifcondition(cfg))

				if cfg.pchheader and not cfg.flags.NoPCH then

					-- Visual Studio requires the PCH header to be specified in the same way
					-- it appears in the #include statements used in the source code; the PCH
					-- source actual handles the compilation of the header. GCC compiles the
					-- header file directly, and needs the file's actual file system path in
					-- order to locate it.

					-- To maximize the compatibility between the two approaches, see if I can
					-- locate the specified PCH header on one of the include file search paths
					-- and, if so, adjust the path automatically so the user doesn't have
					-- add a conditional configuration to the project script.

					local pch = cfg.pchheader
					local found = false

					-- test locally in the project folder first (this is the most likely location)
					local testname = path.join(cfg.project.basedir, pch)
					if os.isfile(testname) then
						pch = project.getrelative(cfg.project, testname)
						found = true
					else
						-- else scan in all include dirs.
						for _, incdir in ipairs(cfg.includedirs) do
							testname = path.join(incdir, pch)
							if os.isfile(testname) then
								pch = project.getrelative(cfg.project, testname)
								found = true
								break
							end
						end
					end

					if not found then
						pch = project.getrelative(cfg.project, path.getabsolute(pch))
					end

					local options = table.merge(
						getdefines(cfg, function (opt)
							return tring.gsub('"-D' .. opt .. '"', '[\\()]', '\\%1')
						end),
						getsysincludedirs(cfg, function (opt)
							return tring.gsub('"-I' .. opt .. '"', '[\\()]', '\\%1')
						end),
						getincludedirs(cfg, function (opt)
							return tring.gsub('"-I' .. opt .. '"', '[\\()]', '\\%1')
						end),
						getbuildoptions(cfg, function (opt)
							return tring.gsub('"' .. opt .. '"', '[\\()]', '\\%1')
						end),
						getcompileflags(cfg, function (opt)
							return tring.gsub('"' .. opt .. '"', '[\\()]', '\\%1')
						end)
					)
					do
						local cdialect = cmake.cdialect(cfg)
						if cdialect then
							table.insert(options, '-std=' .. cdialect)
						end
						local cppdialect = cmake.cppdialect(cfg)
						if cppdialect then
							table.insert(options, '-std=' .. cppdialect)
						end
					end
					table.sort(options)

					local toolset = cfg.toolset
					local language = string.lower(prj.language)
					local pathname = string.gsub(pch, '[\\()]', '\\%1')
					_p(1, '# Generating a PCH File')
					_p(1, 'add_custom_command(')
					_x(2, 'TARGET %s', cmake.quoted(prj.name))
					_p(2, 'PRE_BUILD')
					_p(2, 'COMMAND')
					_x(3, '%s %s -x %s-header \\"%s\\" -o \\"%s.pch\\"', toolset, table.concat(options, ' '), language, pathname, pathname)
					_p(2, 'WORKING_DIRECTORY')
					_p(3, cmake.quoted(cmake.getpath(prj.location)))
					_p(2, ')')
				end

				table.foreachi({
					{
						commands = cfg.prebuildcommands,
						message = cfg.prebuildmessage,
						when = 'PRE_BUILD',
					},
					{
						commands = cfg.prelinkcommands,
						message = cfg.prelinkmessage,
						when = 'PRE_LINK',
					},
					{
						commands = cfg.postbuildcommands,
						message = cfg.postbuildmessage,
						when = 'POST_BUILD',
					},
				}, function (tbl)
					if #tbl.commands > 0 then
						_x(1, '# %s', tbl.message or tbl.when)
						_p(1, 'add_custom_command(')
						_x(2, 'TARGET %s', cmake.quoted(prj.name))
						_p(2, tbl.when)
						table.foreachi(tbl.commands, function(command)
							_p(2, 'COMMAND')
							_x(3, '%s', string.gsub(command, '[\\\"()]', '\\%1'))
						end)
						_p(2, 'WORKING_DIRECTORY')
						_p(3, cmake.quoted(cmake.getpath(prj.location)))
						if tbl.message then
							_p(2, 'COMMENT')
							_x(3, '%s', tbl.message)
						end
						_p(2, ')')
					end
				end)
				_p(0, 'endif()')
			end
		end
		p.outln('')
	end


	m.elements = {}

	m.elements.project_cmakeliststxt = function(prj)
		return {
			m.cmake_minimum_required,
			m.add_subdirectory,
			m.project,
			m.add_library,
			m.add_dependencies,
			m.target_include_directories,
			m.target_compile_definitions,
			m.set_target_properties,
			m.target_compile_options,
			m.target_link_directories,
			m.target_link_libraries,
			m.add_custom_command,
		}
	end


	function m.generate_project_cmakeliststxt(prj)
		p.utf8()
		p.callArray(m.elements.project_cmakeliststxt, prj)
	end
