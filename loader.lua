--[[
    Emochi UI | Loader Modülü (Stabil ve Hatasız - Modernize Edildi)
    - ModuleScript oluşturma kaldırıldı.
    - Global 'shared' tablo üzerinden tekrar yükleme kontrolü eklendi (Fluent stil).
]]

-- Global shared tabloyu kontrol et
if not shared then shared = {} end

-- Eğer zaten yüklüyse tekrar yüklemeyi engelle
if shared.Emochi_UI_Loaded then
    print("Emochi UI | Kütüphane zaten yüklü. Mevcut kütüphane döndürülüyor.")
    return shared.Emochi_UI_Loaded
end

local Emochi = {
    Ver = "1.4 - Global Stabilize",
    Elements = {}
}

-- GitHub URL yapılandırması (Kullanıcının orijinal ayarları)
local GITHUB_USER = "emirontop1"
local GITHUB_REPO = "Ligma"
local GITHUB_BRANCH = "main"

local BASE_URL = "https://raw.githubusercontent.com/%s/%s/%s/elements/"
local LOAD_URL = string.format(BASE_URL, GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

local ElementsToLoad = {
    "window" -- Şu an sadece pencere elementi yüklüyoruz
}

print("Emochi UI | Yükleme Başlatılıyor... (v" .. Emochi.Ver .. ")")

for _, elementName in ipairs(ElementsToLoad) do
    local url = LOAD_URL .. elementName .. ".lua"
    print("Emochi UI | Deneniyor: " .. url)
    
    -- Adım 1: Kodun İndirilmesi (game:HttpGet)
    local elementCode
    local successDownload, errorDownload = pcall(function()
        elementCode = game:HttpGet(url)
        assert(type(elementCode) == "string" and #elementCode > 0, "İndirilen kod string değil veya boş.")
    end)
    
    if not successDownload then
        warn(string.format("Emochi UI | '%s' indirilemedi! Hata: %s", elementName, tostring(errorDownload)))
        return nil
    end

    -- Adım 2: Kodun Çalıştırılması (loadstring)
    local elementModule
    local successRun, errorRun = pcall(function()
        local loaderChunk = loadstring(elementCode)
        if not loaderChunk then 
            error("loadstring bir fonksiyon döndürmedi (Syntax hatası olabilir).") 
        end
        
        elementModule = loaderChunk()
        if not elementModule then
             error("Çalıştırma başarılı ancak modül boş (nil) döndü.")
        end
    end)

    if successRun then
        Emochi[elementName] = elementModule
        print(string.format("Emochi UI | '%s' elementi başarıyla yüklendi.", elementName))
    else
        warn(string.format("Emochi UI | '%s' yüklenirken asıl RUNTIME hatası oluştu! Hata: %s", elementName, tostring(errorRun)))
        return nil
    end
end

print("Emochi UI | Tüm elementler yüklendi. Kütüphane hazır.")

-- Kütüphane objesini global 'shared' tabloya kaydet (Tekrar yükleme kontrolü için)
shared.Emochi_UI_Loaded = Emochi

return Emochi
