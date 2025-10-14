-- Emochi UI Loader
print("[Emochi] Loader started...")

local Emochi = {}
Emochi.Version = "1.0.0"
Emochi.ActiveWindows = {}

-- window.lua yükle
local success, WindowModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/emirontop1/Emochi/main/elements/window.lua"))()
end)

if success and WindowModule then
    Emochi.window = WindowModule
else
    warn("[Emochi] window.lua yüklenemedi: ", WindowModule)
end

-- Shared olarak paylaş
shared.Emochi_UI = Emochi

print("[Emochi] Loader loaded successfully.")
return Emochi
