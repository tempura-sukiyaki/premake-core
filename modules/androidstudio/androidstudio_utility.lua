---
-- androidstudio/androidstudio_utility.lua
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


	cmake.compileflags = table.merge(
		-- c
		{
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
				[p.OFF] = '-fno-omit-frame-pointer',
				[p.ON] = '-fomit-frame-pointer',
			},
			optimize = {
				[p.OFF] = '-O0',
				[p.ON] = '-O2',
				Debug = '-Og',
				Full = '-O3',
				Size = '-Os',
				Speed = '-O3',
			},
			pic = {
				[p.OFF] = '-fno-PIC',
				[p.ON] = '-fPIC',
			},
			strictaliasing = {
				[p.OFF] = '-fno-strict-aliasing',
				Level1 = { '-fstrict-aliasing', '-Wstrict-aliasing=1' },
				Level2 = { '-fstrict-aliasing', '-Wstrict-aliasing=2' },
				Level3 = { '-fstrict-aliasing', '-Wstrict-aliasing=3' },
			},
			symbols = {
				[p.OFF] = '-g0',
				[p.ON] = '-g',
				FastLink = '-g',
				Full = '-g',
			},
			unsignedchar = {
				[p.OFF] = '-fno-unsigned-char',
				[p.ON] = '-funsigned-char',
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
				[p.OFF] = '-w',
				Extra = {'-Wall', '-Wextra'},
				High = '-Wall',
			},
		},
		-- cxx
		{
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
	)


	function cmake.getsysincludedirs(cfg, callback)
		return table.translate(cfg.sysincludedirs, callback)
	end


	function cmake.getincludedirs(cfg, callback)
		return table.translate(cfg.includedirs, callback)
	end


	function cmake.getdefines(cfg, callback)
		return table.translate(cfg.defines, callback)
	end


	function cmake.getcompileflags(cfg, callback)
		return table.translate(config.mapFlags(cfg, cmake.compileflags), callback)
	end


	function cmake.getbuildoptions(cfg, callback)
		local warnings = table.translate(cmake.warnings(cfg), callback)
		local options = table.translate(cfg.buildoptions, callback)
		return table.join(warnings, options)
	end


	-- onstart

	function m.start()
		_TARGET_OS = p.ANDROID
	end
