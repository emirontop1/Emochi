-- loader.luau
-- Kütüphaneyi ve tüm bileşenlerini GitHub'dan dinamik olarak yükler ve birleştirir.

local REPO_OWNER = "emirontop1"
local REPO_NAME = "Emochi"
local REPO_BRANCH = "main"
local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s", REPO_OWNER, REPO_NAME, REPO_BRANCH)

local Emochi = {} -- Ana kütüphane nesnemiz
local Components = {} -- Yüklenen modülleri tutacak tablo

-- ************************************************
-- DİNAMİK MODÜL YÜKLEME VE ÇALIŞTIRMA (LOADSTRING)
-- ************************************************
local function LoadComponent(path)
    local url = BASE_URL .. "/" .. path
    print(string.format("[Loader] '%s' bileşeni yükleniyor...", path))
    
    local codeString = game:HttpGet(url, true)
    local loadFunc = loadstring(codeString)
    
    if loadFunc then
        -- loadstring ile çalıştırılan kodun döndürdüğü değeri al
        return loadFunc()
    else
        error(string.format("Hata: %s adresindeki kod yüklenemedi.", url))
    end
end

-- ************************************************
-- BİLEŞENLERİ YÜKLE VE BİRLEŞTİR
-- ************************************************

-- 1. Window Bileşenini Yükle
Components.Window = LoadComponent("elements/Window.luau")

-- 2. Ana Kütüphane Arayüzünü Oluştur
-- Artık Emochi nesnesinin içindeki fonksiyonları, yüklediğimiz modüllere bağlayabiliriz.

function Emochi:CreateWindow(options)
    -- Yüklenen Window modülündeki .new() fonksiyonunu çağır
    return Components.Window.new(options)
end

-- Geriye Tek Bir Emochi Kütüphanesi Nesnesi Döndür
return Emochi
