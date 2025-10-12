--[[
    Emochi UI Library - Window Element
    Bu modül, GUI'nin ana penceresini oluşturur ve yönetir.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Ana modül tablosu
local Window = {}
Window.__index = Window

--// TEMA AYARLARI //--
local Themes = {
    Dark = {
        Background = Color3.fromRGB(35, 35, 45),
        Header = Color3.fromRGB(45, 45, 55),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(80, 120, 255),
        Outline = Color3.fromRGB(60, 60, 70)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Header = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(0, 120, 255),
        Outline = Color3.fromRGB(200, 200, 200)
    }
}


function Window:Create(options)
    options = options or {}
    local title = options.Title or "Emochi UI"
    local subTitle = options.SubTitle or "Version " .. (getfenv(0).Emochi and getfenv(0).Emochi.Ver or "1.0")
    local size = options.Size or UDim2.fromOffset(580, 460)
    local themeName = options.Theme or "Dark"
    local selectedTheme = Themes[themeName] or Themes.Dark

    local windowObject = setmetatable({}, Window)

    windowObject.ScreenGui = Instance.new("ScreenGui")
    windowObject.ScreenGui.Name = "Emochi_Window_Root"
    windowObject.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    windowObject.ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = selectedTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = windowObject.ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = selectedTheme.Outline
    Stroke.Thickness = 1
    Stroke.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = selectedTheme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(10, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = selectedTheme.Text
    TitleLabel.Text = title
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Name = "SubTitleLabel"
    SubTitleLabel.Size = UDim2.new(1, -10, 1, 0)
    SubTitleLabel.Position = UDim2.fromOffset(TitleLabel.TextBounds.X + 15, 0)
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Font = Enum.Font.Gotham
    SubTitleLabel.TextColor3 = selectedTheme.Accent
    SubTitleLabel.Text = subTitle
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.Parent = Header

    windowObject.Container = Instance.new("Frame")
    windowObject.Container.Name = "Container"
    windowObject.Container.Size = UDim2.new(1, -20, 1, -50)
    windowObject.Container.Position = UDim2.fromOffset(10, 40)
    windowObject.Container.BackgroundTransparency = 1
    windowObject.Container.Parent = MainFrame

    local dragging = false
    local dragInput, dragStart, startPosition
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPosition.X.Scale, startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    windowObject.ScreenGui.Parent = CoreGui
    
    return windowObject
end


-- Modülü döndür
return Window
