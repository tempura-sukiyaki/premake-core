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
				local cflags = config.mapFlags(cfg, gcc.cflags)
				return table.join(flags, cflags, toolset.getcxxflags(cfg))
			end
			return {}
		end

		local function getcmakepath(str)
			return '${PREMAKE_MAIN_SCRIPT_DIR}/' .. path.getrelative(_MAIN_SCRIPT_DIR, str)
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
			local out = false
			for _, dep in ipairs(project.getdependencies(prj, 'dependOnly')) do
				local cmakepath = getcmakepath(dep.location)
				p.x('include(%s)', p.quoted(path.join(cmakepath, 'CMakeLists.txt')))
				out = true
			end

			for _, dep in ipairs(project.getdependencies(prj, 'linkOnly')) do
				local cmakepath = getcmakepath(dep.location)
				p.x('include(%s)', p.quoted(path.join(cmakepath, 'CMakeLists.txt')))
				out = true
			end

			if out then
				p.outln('')
			end
		end
		-- include

		-- project
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
				local options = cfg.defines
				if #options > 0 then
					p.push('target_compile_definitions(%s PRIVATE', p.quoted(prj.name))
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
				local options = cfg.sysincludedirs
				if #options > 0 then
					p.push('target_include_directories(%s SYSTEM PRIVATE', p.quoted(prj.name))
					for _, opt in ipairs(options) do
						local cmakepath = getcmakepath(opt)
						p.x('%s', p.quoted(cmakepath))
					end
					p.pop(')')
					p.outln('')
				end
			end

			if cmakekind then
				local options = cfg.includedirs
				if #options > 0 then
					p.push('target_include_directories(%s PRIVATE', p.quoted(prj.name))
					for _, opt in ipairs(options) do
						local cmakepath = getcmakepath(opt)
						p.x('%s', p.quoted(cmakepath))
					end
					p.pop(')')
					p.outln('')
				end
			end
			-- target_include_directories

			-- target_link_libraries
			if cmakekind then
				local dependencies = table.extract(project.getdependencies(prj, 'linkOnly'), 'name')
				local linkoptions = cfg.linkoptions
				local options = table.join(dependencies, linkoptions)
				if #options > 0 then
					p.push('target_link_libraries(%s', p.quoted(prj.name))
					--local siblinglinks = config.getlinks(cfg, 'siblings', 'fullpath')
					--for _, name in ipairs(siblinglinks) do
					--	p.x('%s', p.quoted(name))
					--end
					--local systemlinks = config.getlinks(cfg, 'system', 'fullpath')
					--for _, name in ipairs(systemlinks) do
					--	p.x('%s', p.quoted(name))
					--end
					--local ldflags = toolset.getldflags(cfg)
					--for _, name in ipairs(ldflags) do
					--	p.x('%s', p.quoted(name))
					--end
					for _, opt in ipairs(options) do
						p.x('%s', p.quoted(opt))
					end
					p.pop(')')
					p.outln('')
				end
			end
			-- target_link_libraries

			-- add_library
			if cmakekind then
				local options = cfg.files
				if #options > 0 then
					p.push('add_library(%s %s', p.quoted(prj.name), cmakekind)
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

			p.pop('endif()')
			p.x('# %s', cfg.name)
			p.outln('')
		end
		-- eachconfig

		-- project
	end
