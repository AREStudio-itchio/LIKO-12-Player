-- BIOS/bconf.lua
--luacheck: globals P PA _OS, ignore 211

-- Crear CPU y GPU
local CPU, yCPU, CPUKit = PA("CPU")
local GPU, yGPU, GPUKit = PA("GPU","GPU",{
  _ColorSet = {
    {0,0,0,255},{28,43,83,255},{127,36,84,255},{0,135,81,255},
    {171,82,54,255},{96,88,79,255},{195,195,198,255},{255,241,233,255},
    {237,27,81,255},{250,162,27,255},{247,236,47,255},{93,187,77,255},
    {81,166,220,255},{131,118,156,255},{241,118,166,255},{252,204,171,255}
  },
  _ClearOnRender = true,
  CPUKit = CPUKit
})

local LIKO_W, LIKO_H = GPUKit._LIKO_W, GPUKit._LIKO_H
local ScreenSize = (LIKO_W/2)*LIKO_H

-- Periféricos esenciales
PA("Audio")
PA("Gamepad","Gamepad",{CPUKit = CPUKit})
PA("TouchControls","TC",{CPUKit = CPUKit, GPUKit = GPUKit})
PA("Keyboard","Keyboard",{CPUKit = CPUKit, GPUKit = GPUKit, _Android = (_OS == "Android"), _EXKB = false})

-- Montar HDD virtual
local HDD, yHDD, HDDKit = PA("HDD","HDD",{
  Drives = {
    C = 1024*1024 * 50,
    D = 1024*1024 * 50
  }
})

-- Clonar sistema base desde C:/ del .love a C:/ persistente
if HDDKit and HDDKit.exists and not HDDKit.exists("C:/DiskOS") then
  print("AREStudio[autorun]: clonando sistema base a C:/")
  local function copyDir(src, dst)
    local items = HDDKit.list(src)
    for _, item in ipairs(items) do
      local srcPath = src..item
      local dstPath = dst..item
      if HDDKit.isDirectory(srcPath) then
        HDDKit.makeDirectory(dstPath)
        copyDir(srcPath.."/", dstPath.."/")
      else
        local data = HDDKit.readFile(srcPath)
        HDDKit.writeFile(dstPath, data)
      end
    end
  end
  copyDir("C:/", "C:/")
end

-- Copiar cartucho si no existe
if HDDKit and HDDKit.exists and not HDDKit.exists("D:/game.lk12") and HDDKit.exists("game.lk12") then
  print("AREStudio[autorun]: copiando cartucho a D:/")
  local data = HDDKit.readFile("game.lk12")
  HDDKit.makeDirectory("D:/")
  HDDKit.writeFile("D:/game.lk12", data)
end

-- RAM y FDD
local KB = function(v) return v*1024 end
local RAMConfig = {
  layout = {
    {ScreenSize,GPUKit.VRAMHandler},
    {ScreenSize,GPUKit.LIMGHandler},
    {KB(64)}
  }
}
local RAM, yRAM, RAMKit = PA("RAM","RAM",RAMConfig)

PA("FDD","FDD",{
  GPUKit = GPUKit,
  RAM = RAM,
  DiskSize = KB(64),
  FRAMAddress = 0x6000
})

PA("WEB","WEB",{CPUKit = CPUKit})
