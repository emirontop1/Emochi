-- Emochi UI Library - Loader (Düzeltilmiş)

-- Eğer zaten yüklüyse tekrar yükleme
if game:GetService("CoreGui"):FindFirstChild("Emochi_GUI_HOLDER") then
    local existing = require(game:GetService("CoreGui").Emochi_GUI_HOLDER)
    return existing
end

local Emochi = {
    Ver = "1.0",
    Elements = {}
}

local GITHUB_USER = "emirontop1"
local GITHUB_REPO = "Ligma"
local GITHUB_BRANCH = "main"

local BASE_URL = "https://raw.githubusercontent.com/%s/%s/%s/elements/"
local LOAD_URL = string.format(BASE_URL, GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

local ElementsToLoad = {
    "window"  -- Dosya küçük harfle burada da
}

print("Emochi UI | Yükleme Başlatıldı...")

for _, elementName in ipairs(ElementsToLoad) do
    local url = LOAD_URL .. elementName .. ".lua"
    print("Emochi UI | Deneniyor: " .. url)
    
    local success, responseOrError = pcall(function()
        local elementCode = game:HttpGet(url)
        assert(type(elementCode) == "string", "Kod string değil")
        print("Emochi UI | Kod indirildi (ilk 100 karakter): " .. elementCode:sub(1, 100))
        
        local elementModule = loadstring(elementCode)()
        print("Emochi UI | elementModule tipi: " .. tostring(type(elementModule)))
        
        if not elementModule then
            error("elementModule nil döndü: " .. url)
        end
        
        Emochi[elementName] = elementModule
    end)
    
    if success then
        print(string.format("Emochi UI | '%s' elementi başarıyla yüklendi.", elementName))
    else
        warn(string.format("Emochi UI | '%s' elementi yüklenemedi! Hata: %s", elementName, tostring(responseOrError)))
        return nil
    end
end

print("Emochi UI | Tüm elementler yüklendi. Kütüphane hazır.")

local Module = Instance.new("ModuleScript", game:GetService("CoreGui"))
Module.Name = "Emochi_GUI_HOLDER"
script.Parent = Module

return setmetatable(Emochi, {
    __index = Emochi.Elements,
    __newindex = function(t, k, v)
        Emochi.Elements[k] = v
    end
})
