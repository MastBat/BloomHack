local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local player = Players.LocalPlayer
local Networking = require(game.ReplicatedStorage.SharedModules.Networking)
local Gardens = workspace:WaitForChild("Gardens")

local ok, CrateData = pcall(function()
    return require(game.ReplicatedStorage.SharedModules.CrateData)
end)
if not ok then CrateData = nil end

local running = true

-- ========== GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloomHack"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 520)
main.Position = UDim2.new(0.5, -210, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌸 BloomHack"
titleLabel.TextColor3 = Color3.fromRGB(200, 80, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -64, 0, 4)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 10
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 10
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- ===== МИНИ-КНОПКА (когда свёрнуто) =====
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 54, 0, 54)
miniBtn.Position = UDim2.new(0, 20, 0.5, -27)
miniBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
miniBtn.Text = "🌱"
miniBtn.TextSize = 28
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.BorderSizePixel = 0
miniBtn.Active = true
miniBtn.Draggable = true
miniBtn.Visible = false
miniBtn.ZIndex = 20
miniBtn.Parent = screenGui
do
    local corner = Instance.new("UICorner", miniBtn)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", miniBtn)
    stroke.Color = Color3.fromRGB(80, 200, 80)
    stroke.Thickness = 2
end

local function minimize()
    main.Visible = false
    miniBtn.Visible = true
end
local function expand()
    miniBtn.Visible = false
    main.Visible = true
end

minimizeBtn.MouseButton1Click:Connect(minimize)
miniBtn.MouseButton1Click:Connect(expand)

closeBtn.MouseButton1Click:Connect(function()
    running = false
    screenGui:Destroy()
end)

-- ===== STATUS =====
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 16)
statusLabel.Position = UDim2.new(0, 5, 0, 38)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Скрипт запущен!"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.Parent = main

local function setStatus(text) statusLabel.Text = text end

-- Переливающийся заголовок (фиолетово-розовый)
task.spawn(function()
    local hue = 0.75
    local dir = 1
    while running do
        hue = hue + 0.003 * dir
        if hue >= 0.95 then dir = -1
        elseif hue <= 0.75 then dir = 1 end
        titleLabel.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
        task.wait(0.05)
    end
end)

-- ===== TAB BAR =====
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 68)
tabBar.Position = UDim2.new(0, 0, 0, 56)
tabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local tabRow1 = Instance.new("Frame")
tabRow1.Size = UDim2.new(1, 0, 0, 34)
tabRow1.Position = UDim2.new(0, 0, 0, 0)
tabRow1.BackgroundTransparency = 1
tabRow1.Parent = tabBar
local row1Layout = Instance.new("UIListLayout")
row1Layout.FillDirection = Enum.FillDirection.Horizontal
row1Layout.SortOrder = Enum.SortOrder.LayoutOrder
row1Layout.Parent = tabRow1

local tabRow2 = Instance.new("Frame")
tabRow2.Size = UDim2.new(1, 0, 0, 34)
tabRow2.Position = UDim2.new(0, 0, 0, 34)
tabRow2.BackgroundTransparency = 1
tabRow2.Parent = tabBar
local row2Layout = Instance.new("UIListLayout")
row2Layout.FillDirection = Enum.FillDirection.Horizontal
row2Layout.SortOrder = Enum.SortOrder.LayoutOrder
row2Layout.Parent = tabRow2

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, 0, 1, -124)
contentArea.Position = UDim2.new(0, 0, 0, 124)
contentArea.BackgroundTransparency = 1
contentArea.Parent = main

local tabBtns = {}
local tabFrames = {}

local function makeTab(name, icon, order, rowFrame)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/3, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = rowFrame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 100)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.Parent = contentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = scroll

    tabBtns[name] = btn
    tabFrames[name] = scroll

    btn.MouseButton1Click:Connect(function()
        for k, f in pairs(tabFrames) do
            f.Visible = false
            tabBtns[k].BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            tabBtns[k].TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        scroll.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(140, 80, 175)
        btn.TextColor3 = Color3.new(1, 1, 1)
    end)

    return scroll
end

local farmFrame   = makeTab("Ферма",  "🌾", 1, tabRow1)
local seedFrame   = makeTab("Семена", "🌱", 2, tabRow1)
local gearFrame   = makeTab("Гиры",   "⚙️", 3, tabRow1)
local crateFrame  = makeTab("Ящики",  "📦", 1, tabRow2)
local petFrame    = makeTab("Петы",   "🐾", 2, tabRow2)
local playerFrame = makeTab("Игрок",  "🏃", 3, tabRow2)

-- ========== UI HELPERS ==========
local function makeToggleRow(parent, labelText, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 22)
    track.Position = UDim2.new(1, -50, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local enabled = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = track

    local function setState(val)
        enabled = val
        track.BackgroundColor3 = val and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(80, 80, 80)
        knob.Position = val and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    end
    btn.MouseButton1Click:Connect(function() setState(not enabled) end)
    return function() return enabled end
end

-- Единый Heartbeat для всех слайдеров вместо отдельного на каждый
local _sliderRegistry = {}
RunService.Heartbeat:Connect(function()
    for i = 1, #_sliderRegistry do _sliderRegistry[i]() end
end)

local function makeSlider(parent, labelText, minVal, maxVal, defaultVal, color, order, fmtFn)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 46)
    container.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local function fmt(v) return fmtFn and fmtFn(v) or (tostring(v) .. "с") end
    local value = defaultVal
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 20)
    lbl.Position = UDim2.new(0, 8, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. ": " .. fmt(value)
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -16, 0, 6)
    track.Position = UDim2.new(0, 8, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    track.BorderSizePixel = 0
    track.Parent = container
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

    local initRel = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initRel, 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(initRel, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    _sliderRegistry[#_sliderRegistry + 1] = function()
        if not dragging then return end
        local rel = math.clamp((player:GetMouse().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(minVal + rel * (maxVal - minVal))
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = labelText .. ": " .. fmt(value)
    end
    return function() return value end
end

local function makeButton(parent, text, color, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function makeShopTab(parent, accentColor)
    local getAutoToggle = makeToggleRow(parent, "Авто-покупка", 1)
    local getInterval   = makeSlider(parent, "Интервал", 5, 120, 60, accentColor, 2)

    local hdr = Instance.new("TextLabel")
    hdr.Size = UDim2.new(1, 0, 0, 16)
    hdr.BackgroundTransparency = 1
    hdr.Text = "Выбери для покупки:"
    hdr.TextColor3 = Color3.fromRGB(180, 180, 180)
    hdr.Font = Enum.Font.Gotham
    hdr.TextSize = 11
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.LayoutOrder = 10
    hdr.Parent = parent

    -- inner scroll for items
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 0, 250)
    scroll.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = accentColor
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.LayoutOrder = 11
    scroll.Parent = parent
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

    local itemLayout = Instance.new("UIListLayout")
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Padding = UDim.new(0, 2)
    itemLayout.Parent = scroll

    local itemIndex = 0

    local itemPad = Instance.new("UIPadding")
    itemPad.PaddingLeft = UDim.new(0, 4)
    itemPad.PaddingRight = UDim.new(0, 4)
    itemPad.PaddingTop = UDim.new(0, 4)
    itemPad.Parent = scroll

    itemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, itemLayout.AbsoluteContentSize.Y + 8)
    end)

    local selected = {}
    local function addItem(name, rarityColor)
        if selected[name] ~= nil then return end
        selected[name] = false
        itemIndex += 1

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundTransparency = 1
        row.Name = name
        row.LayoutOrder = itemIndex
        row.Parent = scroll

        -- цветной кружок редкости (если передан цвет)
        local dotOffset = 4
        if rarityColor then
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 10, 0, 10)
            dot.Position = UDim2.new(0, 4, 0.5, -5)
            dot.BackgroundColor3 = rarityColor == "rainbow" and Color3.new(1,1,1) or rarityColor
            dot.BorderSizePixel = 0
            dot.Parent = row
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            dotOffset = 18
            if rarityColor == "rainbow" then
                local hue = 0
                task.spawn(function()
                    while running and dot and dot.Parent do
                        hue = (hue + 0.01) % 1
                        dot.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        task.wait(0.05)
                    end
                end)
            end
        end

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -(dotOffset + 30), 1, 0)
        lbl.Position = UDim2.new(0, dotOffset, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = row

        local chk = Instance.new("TextButton")
        chk.Size = UDim2.new(0, 20, 0, 20)
        chk.Position = UDim2.new(1, -24, 0.5, -10)
        chk.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        chk.Text = "✓"
        chk.TextColor3 = Color3.new(1,1,1)
        chk.Font = Enum.Font.GothamBold
        chk.TextSize = 13
        chk.TextTransparency = 1
        chk.BorderSizePixel = 0
        chk.Parent = row
        Instance.new("UICorner", chk).CornerRadius = UDim.new(0, 4)

        chk.MouseButton1Click:Connect(function()
            selected[name] = not selected[name]
            local v = selected[name]
            chk.BackgroundColor3 = v and accentColor or Color3.fromRGB(60, 60, 60)
            chk.TextTransparency = v and 0 or 1
        end)
    end

    return getAutoToggle, getInterval, selected, addItem
end

-- ========== PLAYER TAB ==========
do
    local C = Color3.fromRGB
    local humanoid = (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid")
    humanoid.UseJumpPower = true

    -- Скорость
    local speedSlider = Instance.new("Frame")
    speedSlider.Size = UDim2.new(1, 0, 0, 56)
    speedSlider.BackgroundColor3 = C(38, 38, 38)
    speedSlider.BorderSizePixel = 0
    speedSlider.LayoutOrder = 1
    speedSlider.Parent = playerFrame
    Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 6)

    local speedVal = 16
    local speedLbl = Instance.new("TextLabel")
    speedLbl.Size = UDim2.new(1, -8, 0, 20)
    speedLbl.Position = UDim2.new(0, 8, 0, 2)
    speedLbl.BackgroundTransparency = 1
    speedLbl.Text = "Скорость: " .. speedVal
    speedLbl.TextColor3 = C(200, 200, 200)
    speedLbl.TextSize = 12
    speedLbl.Font = Enum.Font.GothamBold
    speedLbl.TextXAlignment = Enum.TextXAlignment.Left
    speedLbl.Parent = speedSlider

    local sTrack = Instance.new("Frame")
    sTrack.Size = UDim2.new(1, -16, 0, 6)
    sTrack.Position = UDim2.new(0, 8, 0, 32)
    sTrack.BackgroundColor3 = C(60, 60, 60)
    sTrack.BorderSizePixel = 0
    sTrack.Parent = speedSlider
    Instance.new("UICorner", sTrack).CornerRadius = UDim.new(0, 3)

    local initS = (16 - 4) / (200 - 4)
    local sFill = Instance.new("Frame")
    sFill.Size = UDim2.new(initS, 0, 1, 0)
    sFill.BackgroundColor3 = C(80, 180, 255)
    sFill.BorderSizePixel = 0
    sFill.Parent = sTrack
    Instance.new("UICorner", sFill).CornerRadius = UDim.new(0, 3)

    local sKnob = Instance.new("TextButton")
    sKnob.Size = UDim2.new(0, 16, 0, 16)
    sKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sKnob.Position = UDim2.new(initS, 0, 0.5, 0)
    sKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    sKnob.Text = ""
    sKnob.BorderSizePixel = 0
    sKnob.ZIndex = 5
    sKnob.Parent = sTrack
    Instance.new("UICorner", sKnob).CornerRadius = UDim.new(1, 0)

    local sDrag = false
    sKnob.MouseButton1Down:Connect(function() sDrag = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sDrag = false end
    end)
    RunService.Heartbeat:Connect(function()
        if not sDrag then return end
        local rel = math.clamp((player:GetMouse().X - sTrack.AbsolutePosition.X) / sTrack.AbsoluteSize.X, 0, 1)
        speedVal = math.floor(4 + rel * (200 - 4))
        sKnob.Position = UDim2.new(rel, 0, 0.5, 0)
        sFill.Size = UDim2.new(rel, 0, 1, 0)
        speedLbl.Text = "Скорость: " .. speedVal
        if humanoid then humanoid.WalkSpeed = speedVal end
    end)

    local sReset = Instance.new("TextButton")
    sReset.Size = UDim2.new(0, 50, 0, 20)
    sReset.Position = UDim2.new(1, -58, 0, 2)
    sReset.BackgroundColor3 = C(60, 60, 60)
    sReset.Text = "Сброс"
    sReset.TextColor3 = Color3.new(1, 1, 1)
    sReset.Font = Enum.Font.Gotham
    sReset.TextSize = 10
    sReset.BorderSizePixel = 0
    sReset.Parent = speedSlider
    Instance.new("UICorner", sReset).CornerRadius = UDim.new(0, 4)
    sReset.MouseButton1Click:Connect(function()
        speedVal = 16
        local rel = (16 - 4) / (200 - 4)
        sKnob.Position = UDim2.new(rel, 0, 0.5, 0)
        sFill.Size = UDim2.new(rel, 0, 1, 0)
        speedLbl.Text = "Скорость: 16"
        if humanoid then humanoid.WalkSpeed = 16 end
    end)

    -- Высота прыжка
    local jumpSlider = Instance.new("Frame")
    jumpSlider.Size = UDim2.new(1, 0, 0, 56)
    jumpSlider.BackgroundColor3 = C(38, 38, 38)
    jumpSlider.BorderSizePixel = 0
    jumpSlider.LayoutOrder = 2
    jumpSlider.Parent = playerFrame
    Instance.new("UICorner", jumpSlider).CornerRadius = UDim.new(0, 6)

    local jumpVal = 50
    local jumpLbl = Instance.new("TextLabel")
    jumpLbl.Size = UDim2.new(1, -8, 0, 20)
    jumpLbl.Position = UDim2.new(0, 8, 0, 2)
    jumpLbl.BackgroundTransparency = 1
    jumpLbl.Text = "Прыжок: " .. jumpVal
    jumpLbl.TextColor3 = C(200, 200, 200)
    jumpLbl.TextSize = 12
    jumpLbl.Font = Enum.Font.GothamBold
    jumpLbl.TextXAlignment = Enum.TextXAlignment.Left
    jumpLbl.Parent = jumpSlider

    local jTrack = Instance.new("Frame")
    jTrack.Size = UDim2.new(1, -16, 0, 6)
    jTrack.Position = UDim2.new(0, 8, 0, 32)
    jTrack.BackgroundColor3 = C(60, 60, 60)
    jTrack.BorderSizePixel = 0
    jTrack.Parent = jumpSlider
    Instance.new("UICorner", jTrack).CornerRadius = UDim.new(0, 3)

    local initJ = (50 - 7) / (500 - 7)
    local jFill = Instance.new("Frame")
    jFill.Size = UDim2.new(initJ, 0, 1, 0)
    jFill.BackgroundColor3 = C(180, 100, 255)
    jFill.BorderSizePixel = 0
    jFill.Parent = jTrack
    Instance.new("UICorner", jFill).CornerRadius = UDim.new(0, 3)

    local jKnob = Instance.new("TextButton")
    jKnob.Size = UDim2.new(0, 16, 0, 16)
    jKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    jKnob.Position = UDim2.new(initJ, 0, 0.5, 0)
    jKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    jKnob.Text = ""
    jKnob.BorderSizePixel = 0
    jKnob.ZIndex = 5
    jKnob.Parent = jTrack
    Instance.new("UICorner", jKnob).CornerRadius = UDim.new(1, 0)

    local jDrag = false
    jKnob.MouseButton1Down:Connect(function() jDrag = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then jDrag = false end
    end)
    RunService.Heartbeat:Connect(function()
        if not jDrag then return end
        local rel = math.clamp((player:GetMouse().X - jTrack.AbsolutePosition.X) / jTrack.AbsoluteSize.X, 0, 1)
        jumpVal = math.floor(7 + rel * (500 - 7))
        jKnob.Position = UDim2.new(rel, 0, 0.5, 0)
        jFill.Size = UDim2.new(rel, 0, 1, 0)
        jumpLbl.Text = "Прыжок: " .. jumpVal
        if humanoid then humanoid.JumpPower = jumpVal end
    end)

    local jReset = Instance.new("TextButton")
    jReset.Size = UDim2.new(0, 50, 0, 20)
    jReset.Position = UDim2.new(1, -58, 0, 2)
    jReset.BackgroundColor3 = C(60, 60, 60)
    jReset.Text = "Сброс"
    jReset.TextColor3 = Color3.new(1, 1, 1)
    jReset.Font = Enum.Font.Gotham
    jReset.TextSize = 10
    jReset.BorderSizePixel = 0
    jReset.Parent = jumpSlider
    Instance.new("UICorner", jReset).CornerRadius = UDim.new(0, 4)
    jReset.MouseButton1Click:Connect(function()
        jumpVal = 50
        local rel = (50 - 7) / (500 - 7)
        jKnob.Position = UDim2.new(rel, 0, 0.5, 0)
        jFill.Size = UDim2.new(rel, 0, 1, 0)
        jumpLbl.Text = "Прыжок: 50"
        if humanoid then humanoid.JumpPower = 50 end
    end)

    -- Нoclip
    local noclipEnabled = false
    local noclipConn = nil
    local noclipParts = {}
    local noclipPartConns = {}

    local function rebuildNoclipCache()
        for _, c in ipairs(noclipPartConns) do c:Disconnect() end
        noclipPartConns = {}
        noclipParts = {}
        local c = player.Character
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then noclipParts[p] = true end
        end
        table.insert(noclipPartConns, c.DescendantAdded:Connect(function(p)
            if p:IsA("BasePart") then noclipParts[p] = true end
        end))
        table.insert(noclipPartConns, c.DescendantRemoving:Connect(function(p)
            noclipParts[p] = nil
        end))
    end
    rebuildNoclipCache()

    local noclipRow = Instance.new("Frame")
    noclipRow.Size = UDim2.new(1, 0, 0, 30)
    noclipRow.BackgroundColor3 = C(38, 38, 38)
    noclipRow.BorderSizePixel = 0
    noclipRow.LayoutOrder = 3
    noclipRow.Parent = playerFrame
    Instance.new("UICorner", noclipRow).CornerRadius = UDim.new(0, 6)

    local noclipLbl = Instance.new("TextLabel")
    noclipLbl.Size = UDim2.new(1, -60, 1, 0)
    noclipLbl.Position = UDim2.new(0, 8, 0, 0)
    noclipLbl.BackgroundTransparency = 1
    noclipLbl.Text = "Нoclip (сквозь стены)"
    noclipLbl.TextColor3 = Color3.new(1, 1, 1)
    noclipLbl.Font = Enum.Font.Gotham
    noclipLbl.TextSize = 12
    noclipLbl.TextXAlignment = Enum.TextXAlignment.Left
    noclipLbl.Parent = noclipRow

    local nTrack = Instance.new("Frame")
    nTrack.Size = UDim2.new(0, 44, 0, 22)
    nTrack.Position = UDim2.new(1, -50, 0.5, -11)
    nTrack.BackgroundColor3 = C(80, 80, 80)
    nTrack.BorderSizePixel = 0
    nTrack.Parent = noclipRow
    Instance.new("UICorner", nTrack).CornerRadius = UDim.new(1, 0)

    local nKnob = Instance.new("Frame")
    nKnob.Size = UDim2.new(0, 18, 0, 18)
    nKnob.Position = UDim2.new(0, 2, 0.5, -9)
    nKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    nKnob.BorderSizePixel = 0
    nKnob.Parent = nTrack
    Instance.new("UICorner", nKnob).CornerRadius = UDim.new(1, 0)

    local nBtn = Instance.new("TextButton")
    nBtn.Size = UDim2.new(1, 0, 1, 0)
    nBtn.BackgroundTransparency = 1
    nBtn.Text = ""
    nBtn.Parent = nTrack

    local function setNoclip(val)
        noclipEnabled = val
        nTrack.BackgroundColor3 = val and C(60, 180, 60) or C(80, 80, 80)
        nKnob.Position = val and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        if val then
            noclipConn = RunService.Stepped:Connect(function()
                if not running then setNoclip(false) return end
                for part in pairs(noclipParts) do
                    if part and part.Parent then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            for part in pairs(noclipParts) do
                if part and part.Parent then
                    part.CanCollide = true
                end
            end
        end
    end

    nBtn.MouseButton1Click:Connect(function() setNoclip(not noclipEnabled) end)

    -- Телепорт на базу
    local tpBtn = makeButton(playerFrame, "🏠 Телепорт на базу", C(60, 100, 200), 4)
    local getAutoTp = makeToggleRow(playerFrame, "Авто-телепорт на базу", 5)
    local getTpInterval = makeSlider(playerFrame, "Интервал телепорта", 5, 300, 60, C(60, 100, 200), 6)

    local cachedPlotId = nil
    local cachedBasePos = nil

    local function resolveBasePos()
        local plotId = player:GetAttribute("PlotId")
        if not plotId then return nil end
        if plotId == cachedPlotId and cachedBasePos then return cachedBasePos end
        local plot = Gardens:FindFirstChild("Plot" .. plotId)
        if not plot then return nil end
        local spawn = plot:FindFirstChildWhichIsA("SpawnLocation", true)
        local pos
        if spawn then
            pos = spawn.Position + Vector3.new(0, 5, 0)
        elseif plot.PrimaryPart then
            pos = plot.PrimaryPart.Position + Vector3.new(0, 5, 0)
        else
            pos = plot:GetPivot().Position + Vector3.new(0, 5, 0)
        end
        cachedPlotId = plotId
        cachedBasePos = pos
        return pos
    end

    local function teleportToBase()
        local targetPos = resolveBasePos()
        if not targetPos then setStatus("Нет участка"); return end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(targetPos)
        setStatus("Телепорт на базу")
    end

    tpBtn.MouseButton1Click:Connect(teleportToBase)

    -- Оптимизация: скрыть растения
    local hidePlantsEnabled = false
    local hiddenParts = {}

    local hidePlantsBtn = makeButton(playerFrame, "👁 Скрыть растения (оптимизация)", C(60, 60, 80), 7)

    local function hidePlantObj(obj)
        if obj:IsA("BasePart") then
            hiddenParts[obj] = {ltm = true}
            obj.LocalTransparencyModifier = 1
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            hiddenParts[obj] = {tr = obj.Transparency}
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            hiddenParts[obj] = {en = obj.Enabled}
            obj.Enabled = false
        end
    end

    local function setHidePlants(val)
        hidePlantsEnabled = val
        hidePlantsBtn.Text = val and "👁 Показать растения" or "👁 Скрыть растения (оптимизация)"
        hidePlantsBtn.BackgroundColor3 = val and C(100, 60, 60) or C(60, 60, 80)
        if val then
            hiddenParts = {}
            for _, plot in ipairs(Gardens:GetChildren()) do
                local plantsFolder = plot:FindFirstChild("Plants")
                if plantsFolder then
                    for _, plant in ipairs(plantsFolder:GetChildren()) do
                        for _, obj in ipairs(plant:GetDescendants()) do
                            hidePlantObj(obj)
                        end
                    end
                end
            end
        else
            for obj, orig in pairs(hiddenParts) do
                if obj and obj.Parent then
                    if orig.ltm then
                        obj.LocalTransparencyModifier = 0
                    elseif orig.tr ~= nil then
                        obj.Transparency = orig.tr
                    elseif orig.en ~= nil then
                        obj.Enabled = orig.en
                    end
                end
            end
            hiddenParts = {}
        end
    end

    hidePlantsBtn.MouseButton1Click:Connect(function()
        setHidePlants(not hidePlantsEnabled)
    end)

    -- Оптимизация: скрыть декор карты
    local hideMapEnabled = false
    local hiddenMapParts = {}

    local hideMapBtn = makeButton(playerFrame, "🏚 Скрыть декор (оптимизация)", C(60, 60, 80), 8)

    local hiddenSky = nil

    -- Папки workspace которые не трогаем
    local SKIP = {
        ["CurrentCamera"] = true,
        ["Terrain"] = true,
    }
    -- Добавляем имена персонажей всех игроков
    local function buildSkip()
        local skip = {}
        for k, v in pairs(SKIP) do skip[k] = v end
        for _, p in ipairs(Players:GetPlayers()) do
            skip[p.Name] = true
        end
        return skip
    end

    local function setHideMap(val)
        hideMapEnabled = val
        hideMapBtn.Text = val and "🏚 Показать декор" or "🏚 Скрыть декор (оптимизация)"
        hideMapBtn.BackgroundColor3 = val and C(100, 60, 60) or C(60, 60, 80)
        if val then
            hiddenMapParts = {}
            -- Убираем скайбокс
            local sky = game.Lighting:FindFirstChildOfClass("Sky")
            if sky then
                hiddenSky = sky
                sky.Parent = nil
            end
            local skip = buildSkip()
            for _, child in ipairs(workspace:GetChildren()) do
                if not skip[child.Name] then
                    for _, obj in ipairs(child:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            hiddenMapParts[obj] = {t = true}
                            obj.LocalTransparencyModifier = 1
                        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                            hiddenMapParts[obj] = {e = obj.Enabled}
                            obj.Enabled = false
                        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                            hiddenMapParts[obj] = {e = obj.Enabled}
                            obj.Enabled = false
                        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                            hiddenMapParts[obj] = {e = obj.Enabled}
                            obj.Enabled = false
                        end
                    end
                end
            end
        else
            -- Восстанавливаем скайбокс
            if hiddenSky then
                hiddenSky.Parent = game.Lighting
                hiddenSky = nil
            end
            for obj, orig in pairs(hiddenMapParts) do
                if obj and obj.Parent then
                    if orig.t ~= nil then
                        obj.LocalTransparencyModifier = 0
                    elseif orig.e ~= nil then
                        obj.Enabled = orig.e
                    end
                end
            end
            hiddenMapParts = {}
        end
    end

    hideMapBtn.MouseButton1Click:Connect(function()
        setHideMap(not hideMapEnabled)
    end)

    -- Скрыть других игроков
    local hidePlayersEnabled = false
    local hiddenPlayerParts = {}
    local hidePlayerConns = {}
    local playerAddedConn = nil

    local hidePlayersBtn = makeButton(playerFrame, "👤 Скрыть игроков", C(60, 60, 80), 9)

    local function hideCharacter(char)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                hiddenPlayerParts[part] = true
                part.LocalTransparencyModifier = 1
            end
        end
        local conn = char.DescendantAdded:Connect(function(part)
            if hidePlayersEnabled and part:IsA("BasePart") then
                hiddenPlayerParts[part] = true
                part.LocalTransparencyModifier = 1
            end
        end)
        table.insert(hidePlayerConns, conn)
    end

    local function setHidePlayers(val)
        hidePlayersEnabled = val
        hidePlayersBtn.Text = val and "👤 Показать игроков" or "👤 Скрыть игроков"
        hidePlayersBtn.BackgroundColor3 = val and C(100, 60, 60) or C(60, 60, 80)
        if val then
            hiddenPlayerParts = {}
            hidePlayerConns = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    if p.Character then hideCharacter(p.Character) end
                    local c = p.CharacterAdded:Connect(function(char)
                        if hidePlayersEnabled then hideCharacter(char) end
                    end)
                    table.insert(hidePlayerConns, c)
                end
            end
            playerAddedConn = Players.PlayerAdded:Connect(function(p)
                if not hidePlayersEnabled then return end
                local c = p.CharacterAdded:Connect(function(char)
                    if hidePlayersEnabled then hideCharacter(char) end
                end)
                table.insert(hidePlayerConns, c)
            end)
        else
            if playerAddedConn then playerAddedConn:Disconnect(); playerAddedConn = nil end
            for _, c in ipairs(hidePlayerConns) do c:Disconnect() end
            hidePlayerConns = {}
            for part in pairs(hiddenPlayerParts) do
                if part and part.Parent then
                    part.LocalTransparencyModifier = 0
                end
            end
            hiddenPlayerParts = {}
        end
    end

    hidePlayersBtn.MouseButton1Click:Connect(function()
        setHidePlayers(not hidePlayersEnabled)
    end)

    -- Скрыть внутриигровой GUI
    local hideGuiEnabled = false
    local hiddenGuis = {}
    local hideGuiConn = nil

    local hideGuiBtn = makeButton(playerFrame, "🖥 Скрыть внутриигровой GUI", C(60, 60, 80), 10)

    local function hideOneGui(gui)
        if gui.Name == "BloomHack" then return end
        if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
            hiddenGuis[gui] = gui.Enabled
            gui.Enabled = false
        end
    end

    local function setHideGui(val)
        hideGuiEnabled = val
        hideGuiBtn.Text = val and "🖥 Показать внутриигровой GUI" or "🖥 Скрыть внутриигровой GUI"
        hideGuiBtn.BackgroundColor3 = val and C(100, 60, 60) or C(60, 60, 80)
        if val then
            hiddenGuis = {}
            for _, gui in ipairs(player.PlayerGui:GetChildren()) do
                hideOneGui(gui)
            end
            hideGuiConn = player.PlayerGui.ChildAdded:Connect(function(gui)
                if hideGuiEnabled then hideOneGui(gui) end
            end)
        else
            if hideGuiConn then hideGuiConn:Disconnect(); hideGuiConn = nil end
            -- восстанавливаем сохранённые
            for gui, orig in pairs(hiddenGuis) do
                if gui and gui.Parent then
                    gui.Enabled = orig
                end
            end
            -- включаем всё остальное что появилось пока были скрыты
            for _, gui in ipairs(player.PlayerGui:GetChildren()) do
                if gui.Name ~= "BloomHack" and hiddenGuis[gui] == nil then
                    if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                        gui.Enabled = true
                    end
                end
            end
            hiddenGuis = {}
        end
    end

    hideGuiBtn.MouseButton1Click:Connect(function()
        setHideGui(not hideGuiEnabled)
    end)

    local creditLbl = Instance.new("TextLabel")
    creditLbl.Size = UDim2.new(1, 0, 0, 28)
    creditLbl.BackgroundColor3 = C(30, 30, 30)
    creditLbl.BorderSizePixel = 0
    creditLbl.Text = "✨ Создан: MastBat | BloomHack v1.0"
    creditLbl.TextColor3 = C(120, 120, 120)
    creditLbl.Font = Enum.Font.Gotham
    creditLbl.TextSize = 10
    creditLbl.LayoutOrder = 11
    creditLbl.Parent = playerFrame
    Instance.new("UICorner", creditLbl).CornerRadius = UDim.new(0, 6)

    for _, plot in ipairs(Gardens:GetChildren()) do
        local plantsFolder = plot:FindFirstChild("Plants")
        if plantsFolder then
            plantsFolder.DescendantAdded:Connect(function(part)
                if hidePlantsEnabled then hidePlantObj(part) end
            end)
            plantsFolder.DescendantRemoving:Connect(function(part)
                hiddenParts[part] = nil
            end)
        end
    end

    task.spawn(function()
        local timer = 0
        while running do
            task.wait(1)
            if getAutoTp() then
                timer += 1
                if timer >= getTpInterval() then
                    timer = 0
                    teleportToBase()
                end
            else
                timer = 0
            end
        end
    end)

    -- Применять скорость/прыжок при респауне
    player.CharacterAdded:Connect(function(c)
        local h = c:WaitForChild("Humanoid")
        humanoid = h
        h.UseJumpPower = true
        h.WalkSpeed = speedVal
        h.JumpPower = jumpVal
        rebuildNoclipCache()
        if noclipEnabled then setNoclip(false); task.wait(0.1); setNoclip(true) end
    end)
end

-- ========== FARM TAB ==========
local harvestBtn      = makeButton(farmFrame, "🌾 Собрать всё сейчас", Color3.fromRGB(55, 130, 55), 1)
local getAutoHarvest  = makeToggleRow(farmFrame, "Авто-сбор", 2)
local getHarvestInterval = makeSlider(farmFrame, "Интервал сбора", 1, 120, 10, Color3.fromRGB(55, 130, 55), 3)
local sellBtn         = makeButton(farmFrame, "💰 Продать всё сейчас", Color3.fromRGB(160, 120, 20), 4)
local getAutoSell     = makeToggleRow(farmFrame, "Авто-продажа", 5)
local getSellInterval = makeSlider(farmFrame, "Интервал продажи", 1, 120, 30, Color3.fromRGB(160, 120, 20), 6)

-- ========== SEED TAB ==========
local getAutoBuy, getSeedInterval, selectedSeeds, addSeed = makeShopTab(seedFrame, Color3.fromRGB(60, 180, 60))
local plantBtn = makeButton(seedFrame, "🌱 Посадить на свободные места", Color3.fromRGB(40, 140, 40), 5)
local getAutoPlant = makeToggleRow(seedFrame, "Авто-посадка", 6)
local getPlantInterval = makeSlider(seedFrame, "Интервал посадки", 5, 300, 60, Color3.fromRGB(40, 140, 40), 7)

local plantHdr = Instance.new("TextLabel")
plantHdr.Size = UDim2.new(1, 0, 0, 16)
plantHdr.BackgroundTransparency = 1
plantHdr.Text = "Выбери для посадки:"
plantHdr.TextColor3 = Color3.fromRGB(180, 180, 180)
plantHdr.Font = Enum.Font.Gotham
plantHdr.TextSize = 11
plantHdr.TextXAlignment = Enum.TextXAlignment.Left
plantHdr.LayoutOrder = 8
plantHdr.Parent = seedFrame

local plantScroll = Instance.new("ScrollingFrame")
plantScroll.Size = UDim2.new(1, 0, 0, 200)
plantScroll.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
plantScroll.BorderSizePixel = 0
plantScroll.ScrollBarThickness = 4
plantScroll.ScrollBarImageColor3 = Color3.fromRGB(40, 140, 40)
plantScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plantScroll.LayoutOrder = 9
plantScroll.Parent = seedFrame
Instance.new("UICorner", plantScroll).CornerRadius = UDim.new(0, 6)

local plantListLayout = Instance.new("UIListLayout")
plantListLayout.SortOrder = Enum.SortOrder.LayoutOrder
plantListLayout.Padding = UDim.new(0, 2)
plantListLayout.Parent = plantScroll

local plantListPad = Instance.new("UIPadding")
plantListPad.PaddingLeft = UDim.new(0, 4)
plantListPad.PaddingRight = UDim.new(0, 4)
plantListPad.PaddingTop = UDim.new(0, 4)
plantListPad.Parent = plantScroll

plantListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    plantScroll.CanvasSize = UDim2.new(0, 0, 0, plantListLayout.AbsoluteContentSize.Y + 8)
end)

local selectedPlant = {}
local plantItemIndex = 0
local accentPlant = Color3.fromRGB(40, 140, 40)

local function addPlantItem(name, rarityColor)
    selectedPlant[name] = false
    plantItemIndex += 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = plantItemIndex
    row.Parent = plantScroll

    local dotOffset = 4
    if rarityColor then
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 10, 0, 10)
        dot.Position = UDim2.new(0, 4, 0.5, -5)
        dot.BackgroundColor3 = rarityColor == "rainbow" and Color3.new(1,1,1) or rarityColor
        dot.BorderSizePixel = 0
        dot.Parent = row
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        dotOffset = 18
        if rarityColor == "rainbow" then
            local hue = 0
            task.spawn(function()
                while running and dot and dot.Parent do
                    hue = (hue + 0.01) % 1
                    dot.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    task.wait(0.05)
                end
            end)
        end
    end

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -(dotOffset + 30), 1, 0)
    lbl.Position = UDim2.new(0, dotOffset, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = row

    local chk = Instance.new("TextButton")
    chk.Size = UDim2.new(0, 20, 0, 20)
    chk.Position = UDim2.new(1, -24, 0.5, -10)
    chk.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    chk.Text = "✓"
    chk.TextColor3 = Color3.new(1,1,1)
    chk.Font = Enum.Font.GothamBold
    chk.TextSize = 13
    chk.TextTransparency = 1
    chk.BorderSizePixel = 0
    chk.Parent = row
    Instance.new("UICorner", chk).CornerRadius = UDim.new(0, 4)

    chk.MouseButton1Click:Connect(function()
        selectedPlant[name] = not selectedPlant[name]
        local v = selectedPlant[name]
        chk.BackgroundColor3 = v and accentPlant or Color3.fromRGB(60, 60, 60)
        chk.TextTransparency = v and 0 or 1
    end)
end

do
    local C = Color3.fromRGB
    local RARITY = {
        Common    = C(180, 180, 180),
        Uncommon  = C(80,  200, 80),
        Rare      = C(80,  140, 255),
        Epic      = C(180, 80,  255),
        Legendary = C(255, 165, 0),
        Mythic    = C(255, 50,  150),
        Super     = C(0,   220, 255),
    }
    local seeds = {
        {"Carrot",          "Common"},
        {"Strawberry",      "Common"},
        {"Blueberry",       "Common"},
        {"Tulip",           "Uncommon"},
        {"Tomato",          "Uncommon"},
        {"Apple",           "Uncommon"},
        {"Bamboo",          "Rare"},
        {"Corn",            "Rare"},
        {"Cactus",          "Rare"},
        {"Pineapple",       "Rare"},
        {"Mushroom",        "Epic"},
        {"Green Bean",      "Epic"},
        {"Banana",          "Epic"},
        {"Grape",           "Epic"},
        {"Coconut",         "Epic"},
        {"Mango",           "Epic"},
        {"Dragon Fruit",    "Legendary"},
        {"Acorn",           "Legendary"},
        {"Cherry",          "Legendary"},
        {"Sunflower",       "Legendary"},
        {"Venus Fly Trap",  "Mythic"},
        {"Pomegranate",     "Mythic"},
        {"Poison Apple",    "Mythic"},
        {"Moon Bloom",      "Super"},
        {"Dragon's Breath", "Super"},
    }
    for _, v in ipairs(seeds) do
        local color = v[2] == "Super" and "rainbow" or RARITY[v[2]]
        addSeed(v[1], color)
        addPlantItem(v[1], color)
    end
end

-- ========== GEAR TAB ==========
local getAutoGear, getGearInterval, selectedGears, addGear = makeShopTab(gearFrame, Color3.fromRGB(100, 160, 220))
do
    local C = Color3.fromRGB
    local RARITY = {
        Common    = C(180, 180, 180),
        Uncommon  = C(80,  200, 80),
        Rare      = C(80,  140, 255),
        Epic      = C(180, 80,  255),
        Legendary = C(255, 165, 0),
        Mythic    = C(255, 50,  150),
    }
    local gears = {
        {"Common Watering Can",  "Common"},
        {"Common Sprinkler",     "Common"},
        {"Uncommon Sprinkler",   "Uncommon"},
        {"Trowel",               "Rare"},
        {"Rare Sprinkler",       "Rare"},
        {"Jump Mushroom",        "Rare"},
        {"Speed Mushroom",       "Rare"},
        {"Shrink Mushroom",      "Epic"},
        {"Supersize Mushroom",   "Epic"},
        {"Gnome",                "Epic"},
        {"Flashbang",            "Epic"},
        {"Basic Pot",            "Epic"},
        {"Legendary Sprinkler",  "Legendary"},
        {"Invisibility Mushroom","Legendary"},
        {"Teleporter",           "Legendary"},
        {"Super Watering Can",   "Super"},
        {"Super Sprinkler",      "Super"},
    }
    for _, v in ipairs(gears) do
        local color = v[2] == "Super" and "rainbow" or RARITY[v[2]]
        addGear(v[1], color)
    end
end

-- ========== CRATE TAB ==========
local getAutoCrate, getCrateInterval, selectedCrates, addCrate = makeShopTab(crateFrame, Color3.fromRGB(200, 120, 50))
do
    local C = Color3.fromRGB
    local RARITY = {
        Common    = C(180, 180, 180),
        Uncommon  = C(80,  200, 80),
        Rare      = C(80,  140, 255),
        Epic      = C(180, 80,  255),
        Legendary = C(255, 165, 0),
        Mythic    = C(255, 50,  150),
        Super     = "rainbow",
    }
    local crates = {
        {"Ladder Crate",        "Common"},
        {"Bench Crate",         "Uncommon"},
        {"Light Crate",         "Uncommon"},
        {"Sign Crate",          "Rare"},
        {"Arch Crate",          "Rare"},
        {"Roleplay Crate",      "Rare"},
        {"Bridge Crate",        "Epic"},
        {"Spring Crate",        "Epic"},
        {"Seesaw Crate",        "Epic"},
        {"Conveyor Crate",      "Epic"},
        {"Owner Door Crate",    "Legendary"},
        {"Bear Trap Crate",     "Legendary"},
        {"Fence Crate",         "Legendary"},
        {"Teleporter Pad Crate","Mythic"},
    }
    for _, v in ipairs(crates) do
        local color = v[2] and (v[2] == "Super" and "rainbow" or RARITY[v[2]]) or nil
        addCrate(v[1], color)
    end
end

-- ========== PET TAB ==========
do
    local C = Color3.fromRGB
    local RARITY = {
        Common    = C(180, 180, 180),
        Uncommon  = C(80,  200, 80),
        Rare      = C(80,  140, 255),
        Epic      = C(180, 80,  255),
        Legendary = C(255, 165, 0),
        Mythic    = C(255, 50,  150),
    }
    local getAutoPet, getPetInterval, selectedPets, addPet = makeShopTab(petFrame, C(255, 160, 80))

    -- DisplayName → internal PetName attribute key
    local PET_KEYS = {
        ["Frog"]            = "Frog",
        ["Bunny"]           = "Bunny",
        ["Owl"]             = "Owl",
        ["Deer"]            = "Deer",
        ["Robin"]           = "Robin",
        ["Bee"]             = "Bee",
        ["Monkey"]          = "Monkey",
        ["Unicorn"]         = "Unicorn",
        ["Golden Dragonfly"]= "GoldenDragonfly",
        ["Raccoon"]         = "Raccoon",
        ["Black Dragon"]    = "BlackDragon",
        ["Ice Serpent"]     = "IceSerpent",
    }
    local pets = {
        {"Frog",            "Common"},
        {"Bunny",           "Common"},
        {"Owl",             "Uncommon"},
        {"Deer",            "Rare"},
        {"Robin",           "Legendary"},
        {"Bee",             "Legendary"},
        {"Monkey",          "Mythic"},
        {"Unicorn",         "Mythic"},
        {"Golden Dragonfly","Mythic"},
        {"Raccoon",         "Super"},
        {"Black Dragon",    "Super"},
        {"Ice Serpent",     "Super"},
    }
    for _, v in ipairs(pets) do
        local color = v[2] == "Super" and "rainbow" or RARITY[v[2]]
        addPet(v[1], color)
    end

    local getMaxPetPrice = makeSlider(petFrame, "💰 Макс. цена пета", 0, 10000000, 0,
        C(255, 160, 80), 3,
        function(v) return v == 0 and "выкл." or tostring(v) .. "¢" end)

    local wildPetRef = nil
    task.spawn(function()
        local map = workspace:WaitForChild("Map", 30)
        if not map then return end
        local ref = map:FindFirstChild("WildPetRef")
        if ref and ref:IsA("Folder") then
            wildPetRef = ref
        else
            map.ChildAdded:Connect(function(child)
                if child.Name == "WildPetRef" and child:IsA("Folder") then
                    wildPetRef = child
                end
            end)
        end
    end)

    -- Режим перемещения: true = телепорт интервалами, false = ходьба
    local petTpMode = false

    local modeRow = Instance.new("Frame")
    modeRow.Size = UDim2.new(1, 0, 0, 30)
    modeRow.BackgroundColor3 = C(38, 38, 38)
    modeRow.BorderSizePixel = 0
    modeRow.LayoutOrder = 4
    modeRow.Parent = petFrame
    Instance.new("UICorner", modeRow).CornerRadius = UDim.new(0, 6)

    local modeLbl = Instance.new("TextLabel")
    modeLbl.Size = UDim2.new(1, -60, 1, 0)
    modeLbl.Position = UDim2.new(0, 8, 0, 0)
    modeLbl.BackgroundTransparency = 1
    modeLbl.Text = "Режим: 🚶 Ходьба"
    modeLbl.TextColor3 = Color3.new(1, 1, 1)
    modeLbl.Font = Enum.Font.Gotham
    modeLbl.TextSize = 12
    modeLbl.TextXAlignment = Enum.TextXAlignment.Left
    modeLbl.Parent = modeRow

    local modeTrack = Instance.new("Frame")
    modeTrack.Size = UDim2.new(0, 44, 0, 22)
    modeTrack.Position = UDim2.new(1, -50, 0.5, -11)
    modeTrack.BackgroundColor3 = C(80, 80, 80)
    modeTrack.BorderSizePixel = 0
    modeTrack.Parent = modeRow
    Instance.new("UICorner", modeTrack).CornerRadius = UDim.new(1, 0)

    local modeKnob = Instance.new("Frame")
    modeKnob.Size = UDim2.new(0, 18, 0, 18)
    modeKnob.Position = UDim2.new(0, 2, 0.5, -9)
    modeKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    modeKnob.BorderSizePixel = 0
    modeKnob.Parent = modeTrack
    Instance.new("UICorner", modeKnob).CornerRadius = UDim.new(1, 0)

    local modeBtn = Instance.new("TextButton")
    modeBtn.Size = UDim2.new(1, 0, 1, 0)
    modeBtn.BackgroundTransparency = 1
    modeBtn.Text = ""
    modeBtn.Parent = modeTrack

    modeBtn.MouseButton1Click:Connect(function()
        petTpMode = not petTpMode
        modeTrack.BackgroundColor3 = petTpMode and C(60, 180, 60) or C(80, 80, 80)
        modeKnob.Position = petTpMode and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        modeLbl.Text = petTpMode and "Режим: 📡 Телепорт" or "Режим: 🚶 Ходьба"
    end)

    local goToPetsBtn = makeButton(petFrame, "🐾 Идти к выбранным петам", C(140, 80, 175), 5)

    local function walkTo(pos)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local target = pos + Vector3.new(0, 4, 0)
        if petTpMode then
            -- Телепорт малыми шагами с паузой, чтобы не триггерить античит
            local STEP = 8   -- малый шаг в студах (~8 ст)
            local WAIT = 0.25 -- ожидание между шагами
            while (hrp.Position - target).Magnitude > 3 do
                local diff = target - hrp.Position
                local move = diff.Unit * math.min(STEP, diff.Magnitude)
                hrp.CFrame = CFrame.new(hrp.Position + move)
                hrp.AssemblyLinearVelocity = Vector3.zero
                task.wait(WAIT)
                char = player.Character
                hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
            end
            hrp.CFrame = CFrame.new(target)
            hrp.AssemblyLinearVelocity = Vector3.zero
        else
            -- Обычная ходьба через MoveTo с повторами и телепорт-добивкой
            for _ = 1, 3 do
                char = player.Character
                hrp = char and char:FindFirstChild("HumanoidRootPart")
                hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then break end
                if (hrp.Position - target).Magnitude < 5 then break end
                hum:MoveTo(target)
                local arrived = false
                local conn = hum.MoveToFinished:Connect(function() arrived = true end)
                local t = 0
                while not arrived and t < 9 do
                    task.wait(0.1); t += 0.1
                    char = player.Character
                    hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then conn:Disconnect(); return end
                    if (hrp.Position - target).Magnitude < 5 then arrived = true end
                end
                conn:Disconnect()
                if arrived then break end
            end
            -- Если всё равно не дошли — телепортируем остаток
            char = player.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - target).Magnitude > 5 then
                hrp.CFrame = CFrame.new(target)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
        task.wait(0.2)
    end

    goToPetsBtn.MouseButton1Click:Connect(function()
        if not wildPetRef then setStatus("WildPetRef не найден"); return end
        task.spawn(function()
            for _, refPart in ipairs(wildPetRef:GetChildren()) do
                if not running then break end
                if refPart:IsA("BasePart") then
                    local petInternalName = refPart:GetAttribute("PetName") or ""
                    local owner = refPart:GetAttribute("OwnerUserId") or 0
                    if type(owner) ~= "number" or owner == 0 then
                        for displayName, key in pairs(PET_KEYS) do
                            if key == petInternalName and selectedPets[displayName] then
                                setStatus("Иду к: " .. displayName)
                                walkTo(refPart.Position)
                                break
                            end
                        end
                    end
                end
            end
            setStatus("Готово")
        end)
    end)

    local function buyPet(refPart)
        local petName = refPart:GetAttribute("PetName") or ""
        -- Идём к пету перед покупкой
        walkTo(refPart.Position)
        task.wait(0.2)
        if fireproximityprompt then
            local map = workspace:FindFirstChild("Map")
            local spawns = map and map:FindFirstChild("WildPetSpawns")
            if spawns then
                local visualName = "WildPet_" .. petName .. "_" .. refPart.Name
                local visual = spawns:FindFirstChild(visualName)
                if visual then
                    local prompt = visual:FindFirstChild("BuyPrompt", true)
                    if prompt and prompt:IsA("ProximityPrompt") then
                        pcall(fireproximityprompt, prompt)
                        return
                    end
                end
            end
        end
        pcall(function() Networking.Pets.WildPetTame:Fire(refPart) end)
    end

    task.spawn(function()
        local timer = 0
        while running do
            task.wait(1)
            if getAutoPet() then
                timer += 1
                if timer >= getPetInterval() and wildPetRef then
                    timer = 0
                    for _, refPart in ipairs(wildPetRef:GetChildren()) do
                        if not running then break end
                        if refPart:IsA("BasePart") then
                            local petInternalName = refPart:GetAttribute("PetName") or ""
                            local owner = refPart:GetAttribute("OwnerUserId") or 0
                            if type(owner) ~= "number" or owner == 0 then
                                local price = refPart:GetAttribute("Price")
                                    or refPart:GetAttribute("Cost")
                                    or refPart:GetAttribute("PetPrice") or 0
                                local cap = getMaxPetPrice()
                                local withinBudget = cap == 0 or price == 0 or price <= cap
                                if withinBudget then
                                    for displayName, key in pairs(PET_KEYS) do
                                        if key == petInternalName and selectedPets[displayName] then
                                            buyPet(refPart)
                                            task.wait(1)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                timer = 0
            end
        end
    end)
end

-- ========== ACTIVATE FIRST TAB ==========
tabBtns["Ферма"].BackgroundColor3 = Color3.fromRGB(140, 80, 175)
tabBtns["Ферма"].TextColor3 = Color3.new(1, 1, 1)
tabFrames["Ферма"].Visible = true

-- ========== LOGIC ==========
local function collectFruit(plantId, fruitId)
    pcall(function()
        Networking.Garden.CollectFruit:Fire(plantId, fruitId or "")
    end)
end

local function harvestAll()
    if not running then return end
    setStatus("Сбор урожая...")
    local count = 0
    for _, plot in ipairs(Gardens:GetChildren()) do
        if not running then break end
        local plantsFolder = plot:FindFirstChild("Plants")
        if plantsFolder then
            for _, plant in ipairs(plantsFolder:GetChildren()) do
                if not running then break end
                -- Имя растения: "userId_plantId" → берём только plantId
                local plantId = plant.Name:match("^%d+_(.+)$") or plant.Name

                for _, desc in ipairs(plant:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc:HasTag("HarvestPrompt") and desc.Enabled then
                        -- Ищем FruitId у любого предка между prompt и plant
                        local fruitId = ""
                        local ancestor = desc.Parent
                        while ancestor and ancestor ~= plant do
                            local fid = ancestor:GetAttribute("FruitId")
                            if fid then fruitId = fid; break end
                            ancestor = ancestor.Parent
                        end
                        collectFruit(plantId, fruitId)
                        count += 1
                        task.wait(0.05)
                    end
                end
            end
        end
    end
    if running then setStatus("Собрано: " .. count .. " плодов") end
end

local function sellAll()
    if not running then return end
    setStatus("Продажа...")
    local ok2, preview = pcall(function() return Networking.NPCS.PreviewSellAll:Fire() end)
    if ok2 and preview and (preview.FruitCount or 0) > 0 then
        local ok3, result = pcall(function() return Networking.NPCS.SellAll:Fire() end)
        if ok3 and result and result.Success then
            if running then
                setStatus("Продано " .. (result.SoldCount or "?") .. " за " .. (result.SellPrice or "?") .. "¢")
            end
        else
            if running then setStatus("Ошибка продажи") end
        end
    else
        -- fallback: просто отправить SellAll без проверки
        pcall(function() Networking.NPCS.SellAll:Fire() end)
        if running then setStatus("Продано") end
    end
end

local function buyAll(selected, remote, label)
    if not running then return end
    local count = 0
    for name, sel in pairs(selected) do
        if not running then break end
        if sel then
            pcall(function() remote:Fire(name) end)
            count += 1
            task.wait(0.1)
        end
    end
    if count > 0 and running then setStatus("Куплено " .. label .. ": " .. count) end
end

-- авто-сбор при появлении нового плода
local function watchPlant(plant)
    local plantId = plant.Name:match("^%d+_(.+)$") or plant.Name
    plant.DescendantAdded:Connect(function(obj)
        if not running or not getAutoHarvest() then return end
        if obj:IsA("ProximityPrompt") and obj:HasTag("HarvestPrompt") then
            task.wait(0.3)
            if not obj.Enabled or not running then return end
            local fruitId = ""
            local ancestor = obj.Parent
            while ancestor and ancestor ~= plant do
                local fid = ancestor:GetAttribute("FruitId")
                if fid then fruitId = fid; break end
                ancestor = ancestor.Parent
            end
            collectFruit(plantId, fruitId)
        end
    end)
end

for _, plot in ipairs(Gardens:GetChildren()) do
    local plantsFolder = plot:FindFirstChild("Plants")
    if plantsFolder then
        for _, plant in ipairs(plantsFolder:GetChildren()) do watchPlant(plant) end
        plantsFolder.ChildAdded:Connect(function(plant)
            task.wait(0.5)
            if running then watchPlant(plant) end
        end)
    end
end

-- ========== AUTO LOOPS ==========
task.spawn(function()
    local timer = 0
    local harvestTask = nil
    while running do
        task.wait(1)
        if getAutoHarvest() then
            timer += 1
            if timer >= getHarvestInterval() then
                timer = 0
                if harvestTask then pcall(task.cancel, harvestTask) end
                harvestTask = task.spawn(harvestAll)
            end
        else
            timer = 0
        end
    end
end)

task.spawn(function()
    local timer = 0
    while running do
        task.wait(1)
        if getAutoSell() then
            timer += 1
            local rem = getSellInterval() - timer
            if rem > 0 and running then setStatus("Продажа через: " .. rem .. "с") end
            if timer >= getSellInterval() then timer = 0; task.spawn(sellAll) end
        else
            timer = 0
        end
    end
end)

task.spawn(function()
    local timer = 0
    while running do
        task.wait(1)
        if getAutoBuy() then
            timer += 1
            if timer >= getSeedInterval() then
                timer = 0
                task.spawn(function() buyAll(selectedSeeds, Networking.SeedShop.PurchaseSeed, "семян") end)
            end
        else
            timer = 0
        end
    end
end)

local function findSeedTool(seedName)
    local bp = player:FindFirstChildOfClass("Backpack")
    local char = player.Character
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("SeedTool") == seedName then return t end
        end
    end
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("SeedTool") == seedName then return t end
        end
    end
    return nil
end

local function plantSeeds()
    if not running then return end
    local plotId = player:GetAttribute("PlotId")
    if not plotId then setStatus("Нет участка для посадки"); return end
    local plot = Gardens:FindFirstChild("Plot" .. plotId)
    if not plot then setStatus("Участок не найден"); return end

    -- PlantArea части в участке игрока
    local plantAreas = {}
    for _, part in ipairs(CollectionService:GetTagged("PlantArea")) do
        if part:IsDescendantOf(plot) then
            table.insert(plantAreas, part)
        end
    end
    if #plantAreas == 0 then setStatus("PlantArea не найдено"); return end

    -- Позиции существующих растений
    local existingXZ = {}
    local plantsFolder = plot:FindFirstChild("Plants")
    if plantsFolder then
        for _, plant in ipairs(plantsFolder:GetChildren()) do
            local cf = plant:GetPivot()
            table.insert(existingXZ, Vector2.new(cf.X, cf.Z))
        end
    end

    -- Ищем инструмент один раз до цикла
    local tool, seedName = nil, nil
    for name, sel in pairs(selectedPlant) do
        if sel then
            local t = findSeedTool(name)
            if t then tool = t; seedName = name; break end
        end
    end
    if not tool then setStatus("Нет инструмента для посадки"); return end

    local planted = 0
    local SPACING = 2
    for _, area in ipairs(plantAreas) do
        if not running then break end
        local cf = area.CFrame
        local size = area.Size
        local stepsX = math.max(1, math.floor(size.X / SPACING))
        local stepsZ = math.max(1, math.floor(size.Z / SPACING))
        for ix = 0, stepsX - 1 do
            if not running then break end
            for iz = 0, stepsZ - 1 do
                if not running then break end
                local wx = (cf.Position.X - size.X / 2) + ix * SPACING + SPACING / 2
                local wz = (cf.Position.Z - size.Z / 2) + iz * SPACING + SPACING / 2
                local pos2 = Vector2.new(wx, wz)
                local free = true
                for _, ep in ipairs(existingXZ) do
                    if (pos2 - ep).Magnitude < 1 then free = false; break end
                end
                if free then
                    local plantPos = Vector3.new(wx, cf.Position.Y + size.Y / 2, wz)
                    pcall(function() Networking.Plant.PlantSeed:Fire(plantPos, seedName, tool) end)
                    table.insert(existingXZ, pos2)
                    planted += 1
                    task.wait(0.1)
                end
            end
        end
    end
    if running then setStatus("Посажено: " .. planted) end
end

plantBtn.MouseButton1Click:Connect(function() task.spawn(plantSeeds) end)

task.spawn(function()
    local timer = 0
    while running do
        task.wait(1)
        if getAutoPlant() then
            timer += 1
            if timer >= getPlantInterval() then
                timer = 0
                task.spawn(plantSeeds)
            end
        else
            timer = 0
        end
    end
end)

task.spawn(function()
    local timer = 0
    while running do
        task.wait(1)
        if getAutoGear() then
            timer += 1
            if timer >= getGearInterval() then
                timer = 0
                task.spawn(function() buyAll(selectedGears, Networking.GearShop.PurchaseGear, "гиров") end)
            end
        else
            timer = 0
        end
    end
end)

task.spawn(function()
    local timer = 0
    while running do
        task.wait(1)
        if getAutoCrate() then
            timer += 1
            if timer >= getCrateInterval() then
                timer = 0
                task.spawn(function() buyAll(selectedCrates, Networking.CrateShop.PurchaseCrate, "ящиков") end)
            end
        else
            timer = 0
        end
    end
end)

harvestBtn.MouseButton1Click:Connect(function() task.spawn(harvestAll) end)
sellBtn.MouseButton1Click:Connect(function() task.spawn(sellAll) end)
