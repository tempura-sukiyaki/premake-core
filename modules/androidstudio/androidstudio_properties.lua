---
-- androidstudio/androidstudio_workspace.lua
---

	local p = premake
	local m = p.modules.androidstudio


	local function write_properties(tbl)
		local function stringify(value)
			if type(value) == 'string' then
				return value
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
				return table.concat(result, ' ')
			end
			p.error('invalid property value type: %s', type(value))
		end
		for key, value in spairs(tbl) do
			p.x('%s=%s', key, stringify(value))
		end
		p.outln('')
	end


	function m.generate_workspace_gradleproperties(wks)
		write_properties(wks.gradleproperties)
	end


	function m.generate_workspace_localproperties(wks)
		write_properties(wks.localproperties)
	end
