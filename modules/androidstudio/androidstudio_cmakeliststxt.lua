---
-- androidstudio/androidstudio_project.lua
---

	local p = premake
	local m = p.modules.androidstudio
	local cmake = m.cmake

	local androidstudio = p.modules.androidstudio
	local project = p.project
	local config = p.config
	local fileconfig = p.fileconfig
	local tree = p.tree

	local function getdefines(cfg, callback)
		return table.translate(cfg.defines, callback)
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


	local function getcompileflags(cfg, callback)
		return table.translate(config.mapFlags(cfg, cmake.compileflags), callback)
	end


	local function getforceincludes(cfg, callback)
		return table.translate(cfg.forceincludes, callback)
	end


	local function getwarnings(cfg, callback)
		return table.translate(cmake.warnings(cfg), callback)
	end


	local function getbuildoptions(cfg, callback)
		return table.translate(cfg.buildoptions, callback)
	end


	local function ifcondition(cfg)
		if cfg.platform then
			return 'if(%s STREQUAL "${PREMAKE_CONFIG_BUILDCFG}|${PREMAKE_CONFIG_PLATFORM}")', cmake.quoted(cfg.name)
		end
		return 'if(%s STREQUAL "${PREMAKE_CONFIG_BUILDCFG}")', cmake.quoted(cfg.buildcfg)
	end


	function m.cmake_minimum_required(prj)
		_x(0, 'cmake_minimum_required(VERSION %s)', table.concat(m.cmake.minimum_required, '.'))
		p.outln('')
	end


	function m.dependencies(prj)
		local deps = project.getdependencies(prj)
		if #deps > 0 then
			_p(0, '# dependencies')
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


	function m.target(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
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
					--table.sort(options)
					table.foreachi(options, function(opt)
						_p(2, opt)
					end)
				end
				_p(2, ')')
				_p(0, 'endif()')
			end
		else
			_x(0, 'add_custom_target(%s)', cmake.quoted(prj.name))
		end
		p.outln('')
	end


	function m.dependson(prj)
		local options = table.extract(project.getdependencies(prj, 'dependOnly'), 'name')
		if #options > 0 then
			_p(0, '# dependson')
			if #options == 1 then
				_x(0, 'add_dependencies(%s %s)', cmake.quoted(prj.name), cmake.quoted(options[1]))
			else
				_x(0, 'add_dependencies(%s', cmake.quoted(prj.name))
				--table.sort(options)
				table.foreachi(options, function(opt)
					_x(1, '%s', cmake.quoted(opt))
				end)
				_x(1, ')')
			end
			p.outln('')
		end
	end


	function m.defines(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# defines')
			for cfg in project.eachconfig(prj) do
				local options = getdefines(cfg, cmake.quoted)
				if #options > 0 then
					_p(0, ifcondition(cfg))
					if #options == 1 then
						_x(1, 'target_compile_definitions(%s PRIVATE %s)', cmake.quoted(prj.name), options[1])
					else
						_x(1, 'target_compile_definitions(%s PRIVATE', cmake.quoted(prj.name))
						--table.sort(options)
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


	function m.sysincludedirs(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# sysincludedirs')
			for cfg in project.eachconfig(prj) do
				local sysincludedirs = getsysincludedirs(cfg, cmake.quoted)
				if #sysincludedirs > 0 then
					_p(0, ifcondition(cfg))
					if #sysincludedirs > 0 then
						_x(1, 'target_include_directories(%s SYSTEM PRIVATE', cmake.quoted(prj.name))
						--table.sort(sysincludedirs)
						table.foreachi(sysincludedirs, function(opt)
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


	function m.includedirs(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# includedirs')
			for cfg in project.eachconfig(prj) do
				local includedirs = getincludedirs(cfg, cmake.quoted)
				if #includedirs > 0 then
					_p(0, ifcondition(cfg))
					if #includedirs > 0 then
						_x(1, 'target_include_directories(%s PRIVATE', cmake.quoted(prj.name))
						--table.sort(includedirs)
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


	function m.targetdir(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if prj.kind == p.STATICLIB or prj.kind == p.SHAREDLIB then
			_p(0, '# targetdir')
			for cfg in project.eachconfig(prj) do
				_p(0, ifcondition(cfg))
				_x(1, 'set_target_properties(%s PROPERTIES', cmake.quoted(prj.name))
				if prj.kind == p.STATICLIB then
					_x(2, 'ARCHIVE_OUTPUT_DIRECTORY %s', cmake.quoted(cmake.getpath(cfg.buildtarget.directory)))
				elseif prj.kind == p.SHAREDLIB then
					_x(2, 'LIBRARY_OUTPUT_DIRECTORY %s', cmake.quoted(cmake.getpath(cfg.buildtarget.directory)))
				end
				_p(2, ')')
				_p(0, 'endif()')
			end
			p.outln('')
		end
	end


	function m.dialect(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# dialect')
			for cfg in project.eachconfig(prj) do
				_p(0, ifcondition(cfg))
				_x(1, 'set_target_properties(%s PROPERTIES', cmake.quoted(prj.name))
				_x(2, 'C_STANDARD %s', cmake.cdialect(cfg))
				_x(2, 'CXX_STANDARD %s', cmake.cppdialect(cfg))
				_p(2, ')')
				_p(0, 'endif()')
			end
			p.outln('')
		end
	end


	function m.compileflags(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# compileflags')
			for cfg in project.eachconfig(prj) do
				local options = getcompileflags(cfg, cmake.quoted)
				if #options > 0 then
					_p(0, ifcondition(cfg))
					_x(1, 'set_target_properties(%s PROPERTIES', cmake.quoted(prj.name))
					--table.sort(options)
					table.foreachi(options, function(opt)
						_x(2, 'COMPILE_FLAGS %s', opt)
					end)
					_p(2, ')')
					_p(0, 'endif()')
				end
			end
			p.outln('')
		end
	end


	function m.pchheader(prj)
		_p(0, '# pchheader')
		for cfg in project.eachconfig(prj) do
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
					pch = testname
					found = true
				else
					-- else scan in all include dirs.
					for _, incdir in ipairs(cfg.includedirs) do
						testname = path.join(incdir, pch)
						if os.isfile(testname) then
							pch = testname
							found = true
							break
						end
					end
				end

				if not found then
					pch = path.getabsolute(pch)
				end

				pch = cmake.getpath(pch)

				local options = table.flatten {
					getdefines(cfg, function (opt)
						return string.gsub('"-D' .. string.gsub(opt, '[\\"()]', '\\%1') .. '"', '[\\"()]', '\\%1')
					end),
					getsysincludedirs(cfg, function (opt)
						return string.gsub('"-isystem ' .. string.gsub(opt, '[\\"()]', '\\%1') .. '"', '[\\"()]', '\\%1')
					end),
					getincludedirs(cfg, function (opt)
						return string.gsub('"-I' .. string.gsub(opt, '[\\"()]', '\\%1') .. '"', '[\\"()]', '\\%1')
					end),
					getcompileflags(cfg, function (opt)
						return string.gsub('"' .. string.gsub(opt, '[\\"()]', '\\%1') .. '"', '[\\"()]', '\\%1')
					end),
					getforceincludes(cfg, function (opt)
						return string.gsub('"-include ' .. string.gsub(opt, '[\\"()]', '\\%1') .. '"', '[\\"()]', '\\%1')
					end),
					getwarnings(cfg, function (opt)
						return string.gsub('"' .. string.gsub(opt, '[\\"()]', '\\%1') .. '"', '[\\"()]', '\\%1')
					end),
					getbuildoptions(cfg, function (opt)
						return string.gsub('"' .. string.gsub(opt, '[\\"()]', '\\%1') .. '"', '[\\"()]', '\\%1')
					end),
				}
				if not prj.language or prj.language == 'C++' then
					local cppdialect = cmake.cppdialect(cfg)
					if cppdialect then
						table.insert(options, '-std=gnu++' .. cppdialect)
					end
				elseif prj.language == 'C' then
					local cdialect = cmake.cdialect(cfg)
					if cdialect then
						table.insert(options, '-std=gnu' .. cdialect)
					end
				end
				--table.sort(options)

				local name = cmake.quoted(prj.name .. (cfg.platform or '') .. cfg.buildcfg .. 'GeneratePCH')
				local host = 'linux'
				if os.ishost('macosx') then
					host = 'darwin'
				elseif os.ishost('windows') then
					host = 'windows'
				end
				local toolchain = string.format('${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/%s-x86_64', host)
				local toolset = cfg.toolset
				local architecture = cfg.architecture or 'ARM'
				local target = ({ARM = 'armv7-none-linux-androideabi', ARM64 = 'aarch64-none-linux-android', x86 = 'i686-none-linux-android', x86_64 = 'x86_64-none-linux-android'})[architecture] .. '${ANDROID_NATIVE_API_LEVEL}'
				local language = string.lower(prj.language)
				local header = string.gsub(pch, '[\\"()]', '\\%1')
				local binary = string.gsub(cmake.getpath(path.join(cfg.objdir, os.uuid(pch) .. '.pch')), '[\\"()]', '\\%1')
				local cc = string.format('%s/bin/%s', toolchain, toolset)
				local cxx = string.format('%s/bin/%s++', toolchain, toolset)
				local ccorcxx = iif(prj.language == 'C', cc, cxx)
				local sysroot = string.format('%s/sysroot', toolchain)

				_p(0, ifcondition(cfg))

				_p(1, 'add_custom_target(%s', name)
				_p(2, 'COMMAND')
				_x(3, 'mkdir -p \\"%s\\"', path.getdirectory(binary))
				_p(2, 'COMMAND')
				_x(3, '%s --gcc-toolchain=%s --sysroot=%s --target=%s -DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-addrsig %s -Wformat -Werror=format-security %s -x %s-header \\"%s\\" -o \\"%s\\"', ccorcxx, toolchain, sysroot, target, iif(architecture == 'ARM', '-march=armv7-a -m${ANDROID_ARM_MODE}', ''), table.concat(options, ' '), language, header, binary)
				_p(2, 'BYPRODUCTS')
				_x(3, '%s', cmake.quoted(binary))
				_p(2, 'WORKING_DIRECTORY')
				_p(3, cmake.quoted(cmake.getpath(prj.location)))
				_p(2, ')')
				_x(1, 'add_dependencies(%s %s)', cmake.quoted(prj.name), name)

				_x(1, 'target_compile_options(%s PRIVATE', cmake.quoted(prj.name))
				_x(2, '-include-pch %s', cmake.quoted(binary))
				_p(2, ')')

				_p(0, 'endif()')
			end
		end
		_p(0, '')
	end


	function m.forceincludes(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# forceincludes')
			for cfg in project.eachconfig(prj) do
				local options = getforceincludes(cfg, function (opt)
					return cmake.quoted('-include ' .. cmake.getpath(opt))
				end)
				if #options > 0 then
					_p(0, ifcondition(cfg))
					_x(1, 'target_compile_options(%s PRIVATE', cmake.quoted(prj.name))
					--table.sort(options)
					table.foreachi(options, function (opt) 
						_p(2, opt)
					end)
					_p(2, ')')
					_p(0, 'endif()')
				end
			end
			p.outln('')
		end
	end


	function m.warnings(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# warnings')
			for cfg in project.eachconfig(prj) do
				local options = getwarnings(cfg, cmake.quoted)
				if #options > 0 then
					_p(0, ifcondition(cfg))
					_x(1, 'target_compile_options(%s PRIVATE', cmake.quoted(prj.name))
					--table.sort(options)
					table.foreachi(options, function (opt) 
						_p(2, opt)
					end)
					_p(2, ')')
					_p(0, 'endif()')
				end
			end
			p.outln('')
		end
	end


	function m.buildoptions(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# buildoptions')
			for cfg in project.eachconfig(prj) do
				local options = getbuildoptions(cfg, cmake.quoted)
				if #options > 0 then
					_p(0, ifcondition(cfg))
					_x(1, 'target_compile_options(%s PRIVATE', cmake.quoted(prj.name))
					--table.sort(options)
					table.foreachi(options, function (opt) 
						_p(2, opt)
					end)
					_p(2, ')')
					_p(0, 'endif()')
				end
			end
			p.outln('')
		end
	end


	function m.libdirs(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# libdirs')
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
						--table.sort(options)
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
						--table.sort(options)
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

	function m.links(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# links')
			for cfg in project.eachconfig(prj) do
				local options = table.unique(table.join(
					config.getlinks(cfg, 'siblings', 'name'),
					config.getlinks(cfg, 'system', 'name')
				))
				options = table.translate(options, function(opt)
					if string.sub(opt, 1, 3) == 'lib' then
						if string.sub(opt, -2) == '.a' then
							opt = string.sub(opt, 4, -3)
						elseif string.sub(opt, -3) == '.so' then
							opt = string.sub(opt, 4, -4)
						end
					end
					return cmake.quoted(opt)
				end)
				if #options > 0 then
					_p(0, ifcondition(cfg))
					_x(1, 'target_link_libraries(%s PRIVATE', cmake.quoted(prj.name))
					--table.sort(options)
					table.insert(options, 1, cmake.quoted('-Wl,--start-group'))
					table.insert(options, cmake.quoted('-Wl,--end-group'))
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


	function m.linkoptions(prj)
		local cmakekind = cmake.getkind(prj.kind)
		if cmakekind then
			_p(0, '# linkoptions')
			for cfg in project.eachconfig(prj) do
				local options = table.translate(cfg.linkoptions, cmake.quoted)
				if #options > 0 then
					_p(0, ifcondition(cfg))
					_x(1, 'target_link_libraries(%s PRIVATE', cmake.quoted(prj.name))
					--table.sort(options)
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


	function m.buildcommands(prj)
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

		_p(0, '# buildcommands')
		for cfg in project.eachconfig(prj) do
			if #buildcommands[cfg] > 0 then
				_p(0, ifcondition(cfg))
				local prevname = cmake.quoted(prj.name)
				for i = #buildcommands[cfg], 1, -1 do
					local info = buildcommands[cfg][i]
					local name = cmake.quoted(prj.name .. (cfg.platform or '') .. cfg.buildcfg .. 'Buildcommand' .. i)
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

		p.outln('')
	end

	local function buildevent(prj, target)
		local when = ({prebuild = 'PRE_BUILD', prelink = 'PRE_LINK', postbuild = 'POST_BUILD' })[target]

		_x(0, '# %scommands', target)
		for cfg in project.eachconfig(prj) do
			local commands = cfg[target .. 'commands']
			local message = cfg[target .. 'message']	
			if #commands > 0 then
				_p(0, ifcondition(cfg))
				_p(1, 'add_custom_command(')
				_x(2, 'TARGET %s', cmake.quoted(prj.name))
				_p(2, when)
				table.foreachi(commands, function(command)
					_p(2, 'COMMAND')
					_x(3, '%s', string.gsub(command, '[\\\"()]', '\\%1'))
				end)
				_p(2, 'WORKING_DIRECTORY')
				_p(3, cmake.quoted(cmake.getpath(prj.location)))
				if message then
					_p(2, 'COMMENT')
					_x(3, '%s', message)
				end
				_p(2, ')')
				_p(0, 'endif()')
			end
		end
		p.outln('')
	end


	function m.prebuildcommands(prj)
		buildevent(prj, 'prebuild')
	end


	function m.prelinkcommands(prj)
		buildevent(prj, 'prelink')
	end


	function m.postbuildcommands(prj)
		buildevent(prj, 'postbuild')
	end


	m.elements = {}

	m.elements.project_cmakeliststxt = function(prj)
		return {
			m.cmake_minimum_required,
			m.dependencies,
			m.project,
			m.target,
			m.dependson,
			m.defines,
			m.sysincludedirs,
			m.includedirs,
			m.targetdir,
			m.dialect,
			m.compileflags,
			m.pchheader,
			m.forceincludes,
			m.warnings,
			m.buildoptions,
			m.libdirs,
			m.links,
			m.linkoptions,
			m.buildcommands,
			m.prebuildcommands,
			m.prelinkcommands,
			m.postbuildcommands,
		}
	end


	function m.generate_project_cmakeliststxt(prj)
		p.utf8()
		p.callArray(m.elements.project_cmakeliststxt, prj)
	end
