-- SECTION 1: CORE FRAME SETUP
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local StudioAction = ReplicatedStorage:WaitForChild("StudioAction", 5)
local SaveDraft = ReplicatedStorage:WaitForChild("SaveDraft", 5)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChomgsDoomGui"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
TitleBar.Text = "  Chomgfeel's Doom!"
TitleBar.TextColor3 = Color3.fromRGB(255, 60, 60)
TitleBar.TextSize = 20
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local TitleUICorner = Instance.new("UICorner")
TitleUICorner.CornerRadius = UDim.new(0, 10)
TitleUICorner.Parent = TitleBar
-- SECTION 2: UI PANELS & BUTTON GENERATION
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "System Status: Idle | Ready for Deployment"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local AutoSection = Instance.new("Frame")
AutoSection.Size = UDim2.new(0.5, -15, 1, -85)
AutoSection.Position = UDim2.new(0, 10, 0, 75)
AutoSection.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
AutoSection.Parent = MainFrame
Instance.new("UICorner", AutoSection).CornerRadius = UDim.new(0, 8)

local ConfigSection = Instance.new("Frame")
ConfigSection.Size = UDim2.new(0.5, -15, 1, -85)
ConfigSection.Position = UDim2.new(0.5, 5, 0, 75)
ConfigSection.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
ConfigSection.Parent = MainFrame
Instance.new("UICorner", ConfigSection).CornerRadius = UDim.new(0, 8)

local function createButton(text, position, parent, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local Btn_Multi = createButton("Multi-Stream (4-50): OFF", UDim2.new(0, 10, 0, 40), AutoSection, Color3.fromRGB(50, 30, 30))
local Btn_Original = createButton("Fixed Loop (ID 2): OFF", UDim2.new(0, 10, 0, 95), AutoSection, Color3.fromRGB(50, 30, 30))
local Btn_Story = createButton("Story Payload Loop: OFF", UDim2.new(0, 10, 0, 150), AutoSection, Color3.fromRGB(50, 30, 30))
local Btn_Color = createButton("Cycle UI Theme Color", UDim2.new(0, 10, 0, 40), ConfigSection)
local Btn_Unload = createButton("Safe Shutdown & Unload GUI", UDim2.new(0, 10, 0, 95), ConfigSection, Color3.fromRGB(70, 30, 30))
-- SECTION 3: CORE LOGIC & BACKGROUND LOOPS
local toggles = { MultiStream = false, OriginalCounter = false, StoryLoop = false }

task.spawn(function()
    local uploadType = 4
    while true do
        if toggles.MultiStream and StudioAction then
            local currentType = uploadType
            task.spawn(function()
                local success, err = pcall(function()
                    local counter = 1
                    while toggles.MultiStream do
                        StudioAction:InvokeServer("StartUpload", currentType, counter)
                        counter = counter + 1
                        if counter > 9999 then counter = 1 end
                        task.wait(0.1)
                    end
                end)
            end)
            uploadType = uploadType + 1
            if uploadType > 50 then uploadType = 4 end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        if toggles.OriginalCounter and StudioAction then
            task.spawn(function()
                pcall(function()
                    local counter = 2
                    while toggles.OriginalCounter do
                        StudioAction:InvokeServer("StartUpload", 2, counter)
                        counter = counter + 1
                        if counter > 9999 then counter = 2 end
                        task.wait(0.1)
                    end
                end)
            end)
            task.wait(5)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    local payload = {
        Title = "sim: how the game \"in this town\"",
        Length = "Long",
        Tone = "Epic",
        Genre = "Horror",
        Body = string.rep("you have been hacked! ", 20)
    }
    while true do
        if toggles.StoryLoop and SaveDraft then
            pcall(function() SaveDraft:InvokeServer(payload) end)
            task.wait(0.1)
        else
            task.wait(0.5)
        end
    end
end)
-- SECTION 4: INTERACTIVITIES & CLEAN CLOSURES
local function handleToggle(toggleKey, buttonObject, baseText)
    toggles[toggleKey] = not toggles[toggleKey]
    if toggles[toggleKey] then
        buttonObject.Text = baseText .. ": ON"
        TweenService:Create(buttonObject, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 80, 40)}):Play()
    else
        buttonObject.Text = baseText .. ": OFF"
        TweenService:Create(buttonObject, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 30, 30)}):Play()
    end
end

Btn_Multi.MouseButton1Click:Connect(function() handleToggle("MultiStream", Btn_Multi, "Multi-Stream (4-50)") end)
Btn_Original.MouseButton1Click:Connect(function() handleToggle("OriginalCounter", Btn_Original, "Fixed Loop (ID 2)") end)
Btn_Story.MouseButton1Click:Connect(function() handleToggle("StoryLoop", Btn_Story, "Story Payload Loop") end)

local themeColors = {Color3.fromRGB(30, 15, 15), Color3.fromRGB(15, 30, 15), Color3.fromRGB(15, 15, 30), Color3.fromRGB(30, 15, 30)}
local colorIdx = 1
Btn_Color.MouseButton1Click:Connect(function()
    colorIdx = colorIdx + 1
    if colorIdx > #themeColors then colorIdx = 1 end
    TweenService:Create(TitleBar, TweenInfo.new(0.4), {BackgroundColor3 = themeColors[colorIdx]}):Play()
end)

Btn_Unload.MouseButton1Click:Connect(function()
    toggles.MultiStream = false
    toggles.OriginalCounter = false
    toggles.StoryLoop = false
    task.wait(0.2)
    local tw = TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 480, 0, 0), BackgroundTransparency = 1})
    tw:Play()
    tw.Completed:Connect(function() ScreenGui:Destroy() end)
end)

