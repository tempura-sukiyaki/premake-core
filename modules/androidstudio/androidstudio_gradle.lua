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


	local function split_index(str, ...)
		if select('#', ...) > 0 then
			str = string.format(str, ...)
		end
		local result = {}
		local mode = ''
		local current = ''
		local quote = true
		for i = 1, string.len(str) do
			local ch = string.sub(str, i, i)
			if mode == '' then
				if string.len(current) == 0 and ch == '%' then
					quote = false
					mode = ch
				elseif string.match(ch, '[%s%w_]') then
					current = current .. ch
				elseif ch == '(' then
					current = current .. ch
					quote = false
					mode = ch
				elseif ch == '.' then
					table.insert(result, { key = current, quote = quote })
					current = ''
					quote = true
				elseif ch == '[' then
					table.insert(result, { key = current, quote = quote })
					current = ''
					quote = true
					mode = ch
				else
					p.error('detect illegal key: %s(%d)', str, i)
				end
			elseif mode == '%' then
				if ch == '(' then
					mode = mode .. ch
				else
					p.error('detect illegal key: %s(%d)', str, i)
				end
			elseif string.sub(mode, -1) == '(' then
				if ch == '(' then
					current = current .. ch
					mode = mode .. ch
				elseif ch == ')' then
					mode = string.sub(mode, 1, -2)
					if mode == '%' then
						mode = ''
					else
						current = current .. ch
					end
				else
					current = current .. ch
				end
			elseif mode == '[' then
				if ch == '"' or ch == "'" then
					mode = ch
				else
					p.error('detect illegal key: %s(%d)', str, i)
				end
			elseif mode == '"' or mode == "'" then
				if ch == '\\' then
					mode = mode .. ch
				elseif ch == mode then
					mode = ']'
				else
					current = current .. ch
				end
			elseif string.sub(mode, -1) == '\\' then
				current = current .. ch
				mode = string.sub(mode, 1, -2)
			elseif mode == ']' then
				if ch == mode then
					mode = '.'
				else
					p.error('detect illegal key: %s(%d)', str, i)
				end
			elseif mode == '.' then
				if ch == mode then
					table.insert(result, { key = current, quote = quote })
					current = ''
					quote = true
					mode = ''
				else
					p.error('detect illegal key: %s(%d)', str, i)
				end
			end
		end
		if current ~= '' then
			table.insert(result, { key = current, quote = quote })
		end
		return result
	end


	local function get_indices_and_value(tbl, indices)
		local function indices_equals(a, b)
			if #a ~= #b then
				return false
			end
			for i = 1, #a do
				if a[i].key ~= b[i].key or a[i].quote ~= b[i].quote  then
					return false
				end
			end
			return true
		end

		for key, value in pairs(tbl) do
			if indices_equals(key, indices) then
				return key, value
			end
		end
		return nil, nil
	end


	local function quoted(str, force)
		if force or string.match(str, '[^%w_]') then
			return '"' .. string.gsub(str, '[\\\"]', '\\%0') .. '"'
		end
		return str
	end


	local function write_gradle(gradle, callback)
		local function indices_less(a, b)
			for i = 1, math.min(#a, #b) do
				if a[i].key ~= b[i].key then
					return a[i].key < b[i].key
				end
			end
			return #a < #b
		end

		local function indices_matching_count(a, b)
			local result = 0
			for i = 1, math.min(#a, #b) do
				if a[i].key ~= b[i].key or a[i].quote ~= b[i].quote  then
					break
				end
				result = result + 1
			end
			return result
		end

		local function quote_index(index)
			if index.quote then
				return quoted(index.key)
			end
			return index.key
		end

		local function stringify(value)
			if type(value) == 'string' then
				return quoted(value, true)
			elseif type(value) == 'boolean' or type(value) == 'number' then
				return tostring(value)
			elseif type(value) == 'function' then
				local result = value()
				if type(result) == 'string' then
					return result
				end
				return stringify(result)
			elseif type(value) == 'table' then
				local result = {}
				for i = 1, #value do
					table.insert(result, stringify(value[i]))
				end
				table.sort(result)
				return table.concat(result, ', ')
			end
			p.error('invalid gradle value type: %s', type(value))
		end

		local keys = table.keys(gradle)
		table.sort(keys, indices_less)

		local lastindices = {}
		for i, indices in ipairs(keys) do
			local count = indices_matching_count(indices, lastindices)

			if count < #lastindices - 1 then
				for i = count + 1, #lastindices - 1 do
					p.pop('}')
				end
			end

			if i > 1 and count == 0 then
				p.outln('')
			end

			if count < #indices - 1 then
				for i = count + 1, #indices - 1 do
					p.push('%s {', quote_index(indices[i]))
				end
			end
			local key = quote_index(indices[#indices])
			local value = stringify(gradle[indices])
			callback(indices, key, value)

			lastindices = indices
		end

		if 0 < #lastindices - 1 then
			for i = 1, #lastindices - 1 do
				p.pop('}')
			end
		end

		p.outln('')
	end


	function m.generate_project_buildgradle(prj)
		local function architecture_to_abi(arch)
			local LUT = {
				[p.ARM] = 'armeabi-v7a',
				[p.ARM64] = 'arm64-v8a',
			}
			return LUT[arch] or arch
		end

		local buildgradle = {}
		do
			local tbl = table.merge({
				['android.compileSdkVersion'] = 28,
				['android.defaultConfig.minSdkVersion'] = 14,
				['android.defaultConfig.versionCode'] = 1,
				['android.defaultConfig.versionName'] = '1.0',
				['android.externalNativeBuild.cmake.path'] = 'CMakeLists.txt',
			}, prj.projectbuildgradle)
			for key, value in pairs(tbl) do
				buildgradle[split_index(key)] = value
			end
		end

		-- android.defaultConfig.externalNativeBuild.cmake.arguments
		do
			local indices = split_index('android.defaultConfig.externalNativeBuild.cmake.arguments')
			local key, value = get_indices_and_value(buildgradle, indices)
			value = table.unique(table.flatten({
				function ()
					return string.format('"-DPREMAKE_MAIN_SCRIPT_DIR=${projectDir.path.tr("\\\\", "/")}/%s"', path.getrelative(prj.location, _MAIN_SCRIPT_DIR))
				end,
				value,
			}))
			table.sort(value)
			buildgradle[key or indices] = value
		end

		-- android.flavorDimensions
		do
			local indices = split_index('android.flavorDimensions')
			local key, value = get_indices_and_value(buildgradle, indices)
			buildgradle[key or indices] = table.unique(table.flatten({ 'premake.platforms', value }))
		end

		for cfg in project.eachconfig(prj) do
			local buildcfg = string.lower(cfg.buildcfg)

			-- android.buildTypes.%{buildcfg}.debuggable
			do
				local indices = split_index('android.buildTypes[%s].debuggable', quoted(buildcfg, true))
				local key, value = get_indices_and_value(buildgradle, indices)
				if not key then
					buildgradle[indices] = config.isDebugBuild(cfg)
				end
			end

			-- android.buildTypes.%{buildcfg}.externalNativeBuild.cmake.arguments
			do
				local indices = split_index('android.buildTypes[%s].externalNativeBuild.cmake.arguments', quoted(buildcfg, true))
				local key, value = get_indices_and_value(buildgradle, indices)
				value = table.unique(table.flatten({
					'-DPREMAKE_CONFIG_BUILDCFG=' .. cfg.buildcfg,
					value,
				}))
				table.sort(value)
				buildgradle[key or indices] = value
			end

			if cfg.platform then
				-- android.productFlavors.%{cfg.platform}.dimension
				do
					local indices = split_index('android.productFlavors[%s].dimension', quoted(cfg.platform, true))
					local key, value = get_indices_and_value(buildgradle, indices)
					if not key then
						buildgradle[indices] = 'premake.platforms'
					end
				end

				-- android.productFlavors.%{cfg.platform}.externalNativeBuild.cmake.arguments
				do
					local indices = split_index('android.productFlavors[%s].externalNativeBuild.cmake.arguments', quoted(cfg.platform, true))
					local key, value = get_indices_and_value(buildgradle, indices)
					value = table.unique(table.flatten({
						'-DPREMAKE_CONFIG_PLATFORM=' .. cfg.platform,
						value,
					}))
					table.sort(value)
					buildgradle[key or indices] = value
				end

				-- android.productFlavors.%{cfg.platform}.ndk.abiFilters
				do
					local indices = split_index('android.productFlavors[%s].ndk.abiFilters', quoted(cfg.platform, true))
					local key, value = get_indices_and_value(buildgradle, indices)
					if not key then
						buildgradle[indices] = architecture_to_abi(cfg.architecture)
					end
				end
			end
		end

		-- apply plugin
		p.x('apply plugin: "com.android.application"')
		p.outln('')
		write_gradle(buildgradle, function (indices, key, value)
			p.x('%s%s%s', key, iif(value ~= '', ' ', ''), value)
		end)
	end


	function m.generate_workspace_buildgradle(wks)
		local buildgradle = {}
		do
			local tbl = table.merge({
				-- allproject
				['allprojects.repositories.google()'] = {},
				['allprojects.repositories.jcenter()'] = {},
				-- buildscript
				['buildscript.repositories.google()'] = {},
				['buildscript.repositories.jcenter()'] = {},
			}, wks.workspacebuildgradle)
			for key, value in pairs(tbl) do
				buildgradle[split_index(key)] = value
			end
		end

		-- buildscript.dependencies.classpath "com.android.tools.build:gradle:*"
		do
			local indices = split_index('buildscript.dependencies.%(classpath "com.android.tools.build:gradle:3.5.2")')
			local pattern = 'classpath%s*[\'"]com%.android%.tools%.build:gradle:%d%.%d%.%d[\'"]'
			local exists = false
			local keys = table.keys(buildgradle)
			for _, tmp in ipairs(keys) do
				exists = (#tmp == #indices) and
					(tmp[1].key == indices[1].key) and (tmp[2].key == indices[2].key) and
					string.match(tmp[3].key, pattern)
				if exists then
					break
				end
			end
			if not exists then
				buildgradle[indices] = {}
			end
		end

		write_gradle(buildgradle, function (indices, key, value)
			if indices[1].key == 'ext' then
				p.x('%s = %s', key, iif(value ~= '', value, ''))
			else
				p.x('%s%s%s', key, iif(value ~= '', ' ', ''), value)
			end
		end)
	end


	function m.geneate_workspace_settingsgradle(wks)
		for prj in p.workspace.eachproject(wks) do
			if prj.kind == p.WINDOWEDAPP then
				local name = quoted(':' .. prj.name, true)
				local file = quoted(path.getrelative(wks.location, prj.location), true)
				p.x('include(%s)', name)
				p.x('project(%s).setProjectDir(file(%s))', name, file)
				p.outln('')
			end
		end
	end
