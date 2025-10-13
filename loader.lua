-- Emochi UI Loader
if shared.Emochi_UI then return shared.Emochi_UI end
shared.Emochi_UI = {}

local Emochi = {}

-- Element listesi
local components = {"window"} -- Şimdilik sadece window, diğerleri eklenebilir

for _, name in ipairs(components) do
    local url = "https://raw.githubusercontent.com/emirontop1/Ligma/main/elements/" .. name .. ".lua"
    local success, module = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and module then
        Emochi[name] = module
    else
        warn("Emochi UI: " .. name .. " yüklenemedi!")
    end
end

shared.Emochi_UI = Emochi
return Emochi
