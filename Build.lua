-- premake5.lua
if os.istarget "Windows" then
	require "vstudio"
	local p = premake;
	local m = p.vstudio.vc2010;

   local buildToolsPath = os.getenv('SCCACHE_BUILDTOOLS_PATH')
   local buildToolsExe = os.getenv('SCCACHE_BUILDTOOLS_EXE')

   local function clToolPath(prj)
      m.element('ClToolPath', nil, buildToolsPath)
      m.element('CLToolExe', nil, buildToolsExe)
      m.element('UseMultiToolTask', nil, 'true')
      m.element('MultiProcCL', nil, 'true')
   end

   local function objectFilename(prj)
      m.element('ObjectFileName', nil, '%s', '$(IntDir)%(FileName).obj')
   end
	
	p.override(m.elements, "globalsCondition",
			function(oldfn, prj, cfg)
				local elements = oldfn(prj, cfg)
				elements = table.join(elements, {clToolPath})
				return elements
			end)
   p.override(m.elements, "clCompile",
      function(oldfn, prj, cfg)
         local elements = oldfn(prj, cfg)
         elements = table.join(elements, {objectFilename})
         return elements
      end)

   p.override(m, 'multiProcessorCompilation', function (base, cfg)
      m.element('MultiProcessorCompilation', nil, 'false')
   end)
end

workspace "New Project"
   architecture "x64"
   configurations { "Debug", "Release", "Dist" }
   startproject "App"

   -- Workspace-wide build options for MSVC
   filter "system:windows"
      buildoptions { "/EHsc", "/Zc:preprocessor", "/Zc:__cplusplus" }

OutputDir = "%{cfg.system}-%{cfg.architecture}/%{cfg.buildcfg}"

group "Core"
	include "Core/Build-Core.lua"
group ""

include "App/Build-App.lua"