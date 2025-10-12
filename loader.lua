--[[
    Emochi UI Library - Loader
    Yazar: Emir (ve Gemini)
    Versiyon: 1.0

    Bu betik, kütüphanenin diğer tüm parçalarını GitHub deposundan yükler
    ve tek bir tablo (library) içinde birleştirir.
]]

-- Eğer başka bir script tarafından zaten yüklendiyse tekrar yüklemeyi engelle
if game:GetService("CoreGui"):FindFirstChild("Emochi_GUI_HOLDER") then
    return require(game:GetService("CoreGui").Emochi_GUI_HOLDER)
end

-- Ana kütüphane tablosunu oluştur
local Emochi = {
    Ver = "1.0",
    Elements = {}
}

--// GITHUB AYARLARI //--
local GITHUB_USER = "emirontop1" -- DEĞİŞTİRİLDİ
local GITHUB_REPO = "Ligma"      -- DEĞİŞTİRİLDİ
local GITHUB_BRANCH = "main"

-- Elementlerin bulunduğu temel URL
local BASE_URL = "https://raw.githubusercontent.com/%s/%s/%s/elements/"
local LOAD_URL = string.format(BASE_URL, GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

-- Yüklenmesini istediğin tüm elementlerin isimleri
local ElementsToLoad = {
    "Window"
    -- Gelecekte buraya "Button", "Tab", "Toggle" gibi yeni elementleri ekleyeceksin
}

print("Emochi UI | Yükleme Başlatıldı...")

-- Elementleri döngü ile yükle
for _, elementName in ipairs(ElementsToLoad) do
    local url = LOAD_URL .. elementName:lower() .. ".lua" -- Dosya adları küçük harfle (window.lua)
    
    local success, response = pcall(function()
        local elementCode = game:HttpGet(url)
        local elementModule = loadstring(elementCode)()
        Emochi[elementName] = elementModule
    end)

    if success then
        print(string.format("Emochi UI | '%s' elementi başarıyla yüklendi.", elementName))
    else
        warn(string.format("Emochi UI | '%s' elementi yüklenemedi! Repo'da dosyanın olduğundan emin ol. Hata: %s", elementName, tostring(response)))
        return nil
    end
end

print("Emochi UI | Tüm elementler yüklendi. Kütüphane hazır.")

-- Kütüphanenin tekrar yüklenmesini engellemek için bir modül oluşturup sakla
local Module = Instance.new("ModuleScript", game:GetService("CoreGui"))
Module.Name = "Emochi_GUI_HOLDER"
script.Parent = Module 
-- Bu modülün asıl amacı require ile kütüphaneyi tekrar alabilmek.

-- Yüklü kütüphaneyi döndür
return setmetatable(Emochi, {
	__index = Emochi.Elements,
	__newindex = function(t, k, v)
		Emochi.Elements[k] = v
	end
})
