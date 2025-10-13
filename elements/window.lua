-- Window Elementi
local Window = {}

function Window:Create(options)
    options = options or {}
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = options.Title or "Emochi UI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = options.Size or UDim2.fromOffset(600, 400)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Text = options.Title or "Emochi UI"
    title.Size = UDim2.fromOffset(600, 50)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame

    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(580, 350)
    container.Position = UDim2.fromOffset(10, 60)
    container.BackgroundTransparency = 1
    container.Parent = frame

    return {
        Window = screenGui,
        Frame = frame,
        Container = container
    }
end

return Window
