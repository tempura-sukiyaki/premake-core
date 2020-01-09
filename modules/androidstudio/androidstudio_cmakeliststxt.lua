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

	local gcc = p.tools.gcc

	gcc.shared.vectorextensions.NEON = '-mfpu=neon'

	function m.generate_project_cmakeliststxt(prj)
		local function getcmakelanguages(str)
			local LUT = {
				['C'] = { 'C' },
				['C++'] = { 'CXX', 'C' },
			}
			return LUT[str]
		end

		local function getcmakekind(str)
			local LUT = {
				[p.SHAREDLIB]   = 'SHARED',
				[p.STATICLIB]   = 'STATIC',
				[p.WINDOWEDAPP] = 'SHARED',
			}
			return LUT[str]
		end

		local function getcmakeoutputproperty(str)
			local LUT = {
				[p.SHAREDLIB] = 'LIBRARY_OUTPUT_DIRECTORY',
				[p.STATICLIB] = 'ARCHIVE_OUTPUT_DIRECTORY',
			}
			return LUT[str]
		end

		local function getextensions(str, header)
			local function make_lut(c, cpp)
				local x = '.' .. c
				return {
					['C'] = { x },
					['C++'] = { x, x .. c, x .. 'pp', x .. 'xx' },
				}
			end
			local CLUT = make_lut('c')
			if not header then
				return CLUT[str]
			end
			local HLUT = make_lut('h')
			return table.join(CLUT[str], HLUT[str])
		end

		local function getcorcxxflags(language, toolset, cfg)
			local flags = config.mapFlags(cfg, {
				floatabi = {
					soft   = '-mfloat-abi=soft',
					softfp = '-mfloat-abi=softfp',
					hard   = '-mfloat-abi=hard',
				},
			})
			if language == 'C' then
				return table.join(flags, toolset.getcflags(cfg))
			elseif language == 'C++' then
				return table.join(flags, cflags, toolset.getcxxflags(cfg))
			end
			return {}
		end

		local function getcmakepath(str)
			return '${PREMAKE_MAIN_SCRIPT_DIR}/' .. path.getrelative(_MAIN_SCRIPT_DIR, str)
		end


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

		local cmakekind = getcmakekind(prj.kind)

		-- cmake_minimum_required
		p.x('cmake_minimum_required(VERSION 3.4.1)')
		p.outln('')
		-- cmake_minimum_required

		-- include_cuard
		p.x('include_guard(GLOBAL)')
		p.outln('')
		-- include_cuard

		-- include
		do
			--local depends = table.translate(project.getdependencies(prj, 'dependOnly'), function(dep) return dep.location end)
			--local links = table.translate(project.getdependencies(prj, 'linkOnly'), function(dep) return dep.location end)
			local options = table.translate(project.getdependencies(prj), function(dep) return dep.location end)
			if #options > 0 then
				for _, opt in ipairs(options) do
					local cmakepath = getcmakepath(opt)
					p.x('include(%s)', p.quoted(path.join(cmakepath, 'CMakeLists.txt')))
				end
				p.outln('')
			end
		end
		-- include

		-- project
		p.outln('')
		if prj.language then
			p.x('project(%s LANGUAGES %s)', p.quoted(prj.name), table.concat(getcmakelanguages(prj.language), ' '))
		else
			p.x('project(%s)', p.quoted(prj.name))
		end
		p.outln('')

		-- eachconfig
		for cfg in project.eachconfig(prj) do
			p.outln('')
			p.x('# %s', cfg.name)
			p.push('if(("${PREMAKE_CONFIG_PLATFORM}" STREQUAL "%s") AND ("${PREMAKE_CONFIG_BUILDCFG}" STREQUAL "%s"))', cfg.platform, cfg.buildcfg)
			p.outln('')

			local toolset = p.tools[cfg.toolset or 'gcc']

			-- add_library
			if cmakekind then
				local options = table.translate(cfg.files, function (opt) return opt end)
				if #options > 0 then
					p.push('add_library(%s %s', p.quoted(prj.name), cmakekind)
					table.sort(options)
					for _, opt in ipairs(options) do
						if (path.hasextension(opt, getextensions(prj.language))) then
							local cmakepath = getcmakepath(opt)
							p.x('%s', p.quoted(cmakepath))
						end
					end
					p.pop(')')
					p.outln('')
				end
			end
			-- add_library

			-- set_target_properties
			if cmakekind then
				local cmakeoutputproperty = getcmakeoutputproperty(prj.kind)
				if cmakeoutputproperty then
					local cmakepath = getcmakepath(cfg.buildtarget.directory)
					p.push('set_target_properties(%s PROPERTIES %s', p.quoted(prj.name), cmakeoutputproperty)
					p.x('%s', p.quoted(cmakepath))
					p.pop(')')
					p.outln('')
				end
			end
			-- set_target_properties

			-- target_compile_definitions
			if cmakekind then
				local options = table.translate(cfg.defines, function (opt) return opt end)
				if #options > 0 then
					p.push('target_compile_definitions(%s PRIVATE', p.quoted(prj.name))
					table.sort(options)
					for _, opt in ipairs(options) do
						p.x('%s', p.quoted(opt))
					end
					p.pop(')')
					p.outln('')
				end
			end
			-- target_compile_definitions

			-- target_compile_options
			if cmakekind then
				local forceincludes = toolset.getforceincludes(cfg)
				local corcxxflags = getcorcxxflags(prj.language, toolset, cfg)
				local buildoptions = cfg.buildoptions
				local options = table.join(forceincludes, corcxxflags, buildoptions)
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

			-- target_include_directories
			if cmakekind then
				local options = table.translate(cfg.sysincludedirs, function (opt) return getcmakepath(opt) end)
				if #options > 0 then
					p.push('target_include_directories(%s SYSTEM PRIVATE', p.quoted(prj.name))
					table.sort(options)
					for _, opt in ipairs(options) do
						p.x('%s', p.quoted(opt))
					end
					p.pop(')')
					p.outln('')
				end
			end

			if cmakekind then
				local options = table.translate(cfg.includedirs, function (opt) return getcmakepath(opt) end)
				if #options > 0 then
					p.push('target_include_directories(%s PRIVATE', p.quoted(prj.name))
					table.sort(options)
					for _, opt in ipairs(options) do
						p.x('%s', p.quoted(opt))
					end
					p.pop(')')
					p.outln('')
				end
			end
			-- target_include_directories

			-- target_link_libraries
			if cmakekind then
				local dependencies = table.extract(project.getdependencies(prj), 'name')
				local ldflags = toolset.getldflags(cfg)
				local linkoptions = cfg.linkoptions
				local options = table.join(dependencies, ldflags, linkoptions)
				table.sort(options)
				local libdirs = table.translate(cfg.libdirs, function (dir) return p.quoted('-L' .. getcmakepath(dir)) end)
				local links = toolset.getlinks(cfg, 'system', 'fullpath')
				for _, depprj in ipairs(project.getdependencies(prj, 'linkOnly')) do
					local depcfg = project.findClosestMatch(depprj, cfg.buildcfg, cfg.platform)
					if depcfg then
						local libdir = p.quoted('-L' .. getcmakepath(depcfg.buildtarget.directory))
						if not table.contains(libdirs, libdir) then
							table.insert(libdirs, libdir)
						end
						local link = p.quoted('-l' .. depprj.name)
						if not table.contains(links, link) then
							table.insert(links, link)
						end
					end
				end
				table.sort(libdirs)
				table.sort(links)
				table.insert(links, 1, '-Wl,--start-group')
				table.insert(links, '-Wl,--end-group')
				options = table.join(options, libdirs, links)
				if #options > 0 then
					p.push('target_link_libraries(%s PUBLIC', p.quoted(prj.name))
					for _, opt in ipairs(options) do
						if opt == '-Wl,--start-group' then
							p.push(opt)
						elseif opt ~= '-Wl,--end-group' then
							p.x('%s', p.quoted(opt))
						else
							p.pop(opt)
						end
					end
					p.pop(')')
					p.outln('')
				end
			end
			-- target_link_libraries

			-- add_custom_command or add_custom_target
			if #buildcommands[cfg] > 0 then
				local useaddcustomcommand = false
				for i, info in ipairs(buildcommands[cfg]) do
					local buildcommandname = p.quoted(prj.name .. cfg.buildcfg .. 'Buildcommand' .. i)
					if useaddcustomcommand then
						p.push('add_custom_command(')
						p.push('OUTPUT')
						for _, file in ipairs(info.outputs) do
							p.x('%s', p.quoted(getcmakepath(file)))
						end
						p.pop()
					else
						p.push('add_custom_target(%s', buildcommandname)
					end
					for _, command in ipairs(info.commands) do
						p.push('COMMAND')
						p.x('%s', command)
						p.pop()
					end
					if not useaddcustomcommand then
						p.push('BYPRODUCTS')
						for _, file in ipairs(info.outputs) do
							p.x('%s', p.quoted(getcmakepath(file)))
						end
						p.pop()
					end
					if info.message then
						p.x('COMMENT %s', p.quoted(info.message))
					end
					if useaddcustomcommand then
						p.push('DEPENDS')
					else
						p.push('SOURCES')
					end
					for _, file in ipairs(info.inputs) do
						p.x('%s', p.quoted(getcmakepath(file)))
					end
					p.pop()
					p.pop(')')
					p.outln('')
					if not useaddcustomcommand then
						if 1 < i then
							local depends = prj.name .. cfg.buildcfg .. 'Buildcommand' .. (i - 1)
							p.x('add_dependencies(%s %s)', buildcommandname, p.quoted(depends))
						elseif #buildcommands[cfg] == i then
							p.x('add_dependencies(%s %s)', p.quoted(prj.name), buildcommandname)
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
