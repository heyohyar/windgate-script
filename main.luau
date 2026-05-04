-- ============================================================
--  Windgate GUI  |  KronHub-style Sidebar UI
--  Home, ESP (Wood/Stone/Metal), Player, Transport, Farm, Settings
-- ============================================================
 
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local lp               = Players.LocalPlayer
 
-- ============================================================
-- Helpers
-- ============================================================
local function BC(n)    return BrickColor.new(n).Color end
local function RGB(...) return Color3.fromRGB(...) end
local M = Enum.Material
 
-- ============================================================
-- Stone Fingerprint Database
-- ============================================================
local STONE_DB = {
    { Name = "Slate",     Color = BC("Hurricane grey"),  Material = M.Slate,    Quality = 1    },
    { Name = "Laterite",  Color = RGB(168, 82,  42),     Material = M.Concrete, Quality = 1.1  },
    { Name = "Kankar",    Color = RGB(204, 191, 159),    Material = M.Concrete, Quality = 1.1  },
    { Name = "Talc",      Color = RGB(142, 163, 143),    Material = M.Concrete, Quality = 1.15 },
    { Name = "Sandstone", Color = BC("Cashmere"),        Material = M.Slate,    Quality = 1.2  },
    { Name = "Marble",    Color = BC("Ghost grey"),      Material = M.Marble,   Quality = 1.5  },
    { Name = "Limestone", Color = BC("Khaki"),           Material = M.Slate,    Quality = 1.9  },
    { Name = "Schist",    Color = BC("Flint"),           Material = M.Slate,    Quality = 2.2  },
    { Name = "Apatite",   Color = BC("Pastel Blue"),     Material = M.Concrete, Quality = 2.3  },
    { Name = "Granite",   Color = BC("Light orange"),    Material = M.Granite,  Quality = 2.4  },
    { Name = "Gneiss",    Color = BC("Sand green"),      Material = M.Slate,    Quality = 3    },
    { Name = "Metite",    Color = BC("Cyan"),            Material = M.Granite,  Quality = 4.2  },
}
 
-- ============================================================
-- Metal Fingerprint Database
-- ============================================================
local METAL_DB = {
    { Name = "Tin",       Color = BC("Cloudy grey"),         Material = M.Metal, Quality = 1   },
    { Name = "Copper",    Color = BC("Dark orange"),         Material = M.Metal, Quality = 1.6 },
    { Name = "Gold",      Color = BC("Bright yellow"),       Material = M.Metal, Quality = 1.9 },
    { Name = "Aluminium", Color = BC("Ghost grey"),          Material = M.Metal, Quality = 2   },
    { Name = "Iron",      Color = BC("Flint"),               Material = M.Metal, Quality = 2.3 },
}
 
-- ============================================================
-- Wood Fingerprint Database
-- ============================================================
local WOOD_DB = {
    { Name = "Poplar",      Color = RGB(214, 171, 121), Material = M.Wood, Quality = 1   },
    { Name = "Birch",       Color = RGB(235, 221, 186), Material = M.Wood, Quality = 1.4 },
    { Name = "Pine",        Color = RGB(241, 220, 145), Material = M.Wood, Quality = 1.6 },
    { Name = "Cypress",     Color = RGB(124, 86,  62),  Material = M.Wood, Quality = 1.7 },
    { Name = "Baobab",      Color = BC("Burlap"),       Material = M.Wood, Quality = 1.8 },
    { Name = "Acacia",      Color = BC("Reddish brown"),Material = M.Wood, Quality = 2.0 },
    { Name = "Teak",        Color = RGB(159, 99,  61),  Material = M.Wood, Quality = 2.1 },
    { Name = "Ash",         Color = RGB(196, 133, 98),  Material = M.Wood, Quality = 2.35},
    { Name = "Oak",         Color = RGB(161, 117, 88),  Material = M.Wood, Quality = 2.4 },
    { Name = "Padauk",      Color = RGB(117, 55,  55),  Material = M.Wood, Quality = 2.5 },
    { Name = "BlueSpruce",  Color = BC("Cadet blue"),   Material = M.Wood, Quality = 2.6 },
    { Name = "Cedar",       Color = BC("Sand red"),     Material = M.Wood, Quality = 2.7 },
    { Name = "Willow",      Color = BC("Dirt brown"),   Material = M.Wood, Quality = 2.8 },
    { Name = "Cherry",      Color = BC("Medium red"),   Material = M.Wood, Quality = 3   },
    { Name = "Purpleheart", Color = RGB(117, 90,  113), Material = M.Wood, Quality = 3.2 },
    { Name = "Ebony",       Color = RGB(40,  63,  79),  Material = M.Wood, Quality = 4.3 },
    { Name = "Volcana",     Color = BC("Really red"),   Material = M.Wood, Quality = 4.4 },
    { Name = "Empyrid",     Color = RGB(86,  100, 96),  Material = M.Ice,  Quality = 4.5 },
    { Name = "Mudwort",     Color = RGB(40,  93,  112), Material = M.Wood, Quality = 4.65},
    { Name = "Rainbow",     Color = BC("White"),        Material = M.Ice,  Quality = 10  },
}
 
-- ============================================================
-- ESP State
-- ============================================================
local WoodESPEnabled  = false
local StoneESPEnabled = false
local MetalESPEnabled = false
 
local stoneEnabled = {}
for _, e in ipairs(STONE_DB) do stoneEnabled[e.Name] = true end
 
local woodEnabled = {}
for _, e in ipairs(WOOD_DB) do woodEnabled[e.Name] = true end
 
local metalEnabled = {}
for _, e in ipairs(METAL_DB) do metalEnabled[e.Name] = true end
 
-- ============================================================
-- Matching helpers
-- ============================================================
local COLOR_TOL  = 12 / 255
local METAL_TOL  = 15 / 255
local WOOD_TOL   = 18 / 255
 
local function colorsMatch(c1, c2, tol)
    tol = tol or COLOR_TOL
    return math.abs(c1.R - c2.R) <= tol
       and math.abs(c1.G - c2.G) <= tol
       and math.abs(c1.B - c2.B) <= tol
end
 
local MIN_DIM, MAX_DIM = 0.8, 16
local function withinStoneBounds(size)
    return size.X >= MIN_DIM and size.X <= MAX_DIM
       and size.Y >= MIN_DIM and size.Y <= MAX_DIM
       and size.Z >= MIN_DIM and size.Z <= MAX_DIM
end
 
local STONE_MATS = { [M.Slate]=true, [M.Concrete]=true, [M.Marble]=true, [M.Granite]=true }
local METAL_MATS = { [M.Metal]=true, [M.Foil]=true }
local WOOD_MATS  = { [M.Wood]=true, [M.Ice]=true }
 
local function identifyStone(part)
    if not STONE_MATS[part.Material]    then return nil end
    if not withinStoneBounds(part.Size) then return nil end
    for _, entry in ipairs(STONE_DB) do
        if entry.Material == part.Material and colorsMatch(part.Color, entry.Color) then
            return entry
        end
    end
end
 
local function identifyMetal(part)
    if not METAL_MATS[part.Material] then return nil end
    for _, entry in ipairs(METAL_DB) do
        if entry.Material == part.Material and colorsMatch(part.Color, entry.Color, METAL_TOL) then
            return entry
        end
    end
end
 
local function identifyWood(part)
    if not WOOD_MATS[part.Material] then return nil end
    for _, entry in ipairs(WOOD_DB) do
        if entry.Material == part.Material and colorsMatch(part.Color, entry.Color, WOOD_TOL) then
            return entry
        end
    end
end
 
local function scanForMetals(model)
    local found, seen = {}, {}
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name == "Bit" then
            local entry = identifyMetal(desc)
            if entry and not seen[entry.Name] then
                seen[entry.Name] = true
                table.insert(found, entry)
            end
        end
    end
    table.sort(found, function(a, b) return a.Quality < b.Quality end)
    return found
end
 
local function getStoneEntry(model)
    local primary = model.PrimaryPart
    if not primary             then return nil, nil, nil end
    if primary.Name ~= "Main" then return nil, nil, nil end
    if primary.Anchored        then return nil, nil, nil end
    if model:FindFirstChildOfClass("Humanoid") then return nil, nil, nil end
 
    local bpCount = 0
    for _, c in ipairs(model:GetChildren()) do
        if c:IsA("BasePart") then
            bpCount += 1
            if bpCount > 12 then return nil, nil, nil end
        end
    end
 
    local entry = identifyStone(primary)
    if not entry then return nil, nil, nil end
    if not stoneEnabled[entry.Name] then return nil, nil, nil end
 
    return entry, primary, scanForMetals(model)
end
 
local function getWoodEntry(model)
    if model:FindFirstChildOfClass("Humanoid") then return nil, nil end
    local trunk = model:FindFirstChild("Trunk")
    if not trunk or not trunk:IsA("BasePart") then return nil, nil end
    local entry = identifyWood(trunk)
    if not entry then return nil, nil end
    if not woodEnabled[entry.Name] then return nil, nil end
    return entry, trunk
end
 
local function brighten(c, f)
    f = f or 1.5
    return Color3.new(math.min(c.R*f,1), math.min(c.G*f,1), math.min(c.B*f,1))
end
 
-- ============================================================
-- ESP pool
-- ============================================================
local espObjects = {}
local tracked    = {}
 
local function destroyESP(data)
    pcall(function() data.highlight:Destroy() end)
    pcall(function() data.billboard:Destroy() end)
end
 
local function clearAll()
    for _, d in ipairs(espObjects) do destroyESP(d) end
    espObjects = {}
    tracked = {}
end
 
local function createESPGeneric(model, anchorPart, fillColor, labelLines)
    local glowColor = brighten(fillColor, 1.6)
 
    local hl = Instance.new("Highlight")
    hl.Adornee             = model
    hl.FillColor           = fillColor
    hl.OutlineColor        = glowColor
    hl.FillTransparency    = 0.6
    hl.OutlineTransparency = 0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent              = game.CoreGui
 
    local lineCount = #labelLines
    local bbHeight  = 10 + lineCount * 20
 
    local bb = Instance.new("BillboardGui")
    bb.Name        = "WindgateESP_BB"
    bb.Size        = UDim2.new(0, 140, 0, bbHeight)
    bb.StudsOffset = Vector3.new(0, 5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee     = anchorPart
    bb.Parent      = game.CoreGui
 
    local bg = Instance.new("Frame", bb)
    bg.Size                   = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3       = Color3.fromRGB(6, 6, 6)
    bg.BackgroundTransparency = 0.22
    bg.BorderSizePixel        = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 5)
 
    local accent = Instance.new("Frame", bg)
    accent.Size             = UDim2.new(0.80, 0, 0, 2)
    accent.Position         = UDim2.new(0.10, 0, 0, 2)
    accent.BackgroundColor3 = glowColor
    accent.BorderSizePixel  = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
 
    for i, line in ipairs(labelLines) do
        local lbl = Instance.new("TextLabel", bg)
        lbl.Size                   = UDim2.new(1, -6, 0, 18)
        lbl.Position               = UDim2.new(0, 3, 0, 4 + (i-1)*20)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextScaled             = true
        lbl.TextColor3             = line[2] or glowColor
        lbl.Text                   = line[1]
        lbl.TextXAlignment         = Enum.TextXAlignment.Center
        lbl.TextStrokeTransparency = 0.3
        lbl.TextStrokeColor3       = Color3.new(0,0,0)
    end
 
    return { highlight = hl, billboard = bb, model = model, anchorPart = anchorPart }
end
 
local function createStoneESP(model, entry, anchorPart, metals)
    local glowColor = brighten(entry.Color, 1.6)
    local lines = { { entry.Name, glowColor } }
    for _, m in ipairs(metals) do
        if MetalESPEnabled and metalEnabled[m.Name] then
            table.insert(lines, { "• " .. m.Name, brighten(m.Color, 1.9) })
        end
    end
    return createESPGeneric(model, anchorPart, entry.Color, lines)
end
 
local function createWoodESP(model, entry, anchorPart)
    local glowColor = brighten(entry.Color, 1.6)
    return createESPGeneric(model, anchorPart, entry.Color, {
        { entry.Name, glowColor },
        { "Wood", Color3.fromRGB(180, 140, 90) },
    })
end
 
local function rebuildESP()
    clearAll()
 
    local function tryAddModel(child)
        if not child:IsA("Model") then return end
        if tracked[child] then return end
 
        if StoneESPEnabled then
            local entry, anchor, metals = getStoneEntry(child)
            if entry then
                tracked[child] = true
                table.insert(espObjects, createStoneESP(child, entry, anchor, metals or {}))
                return
            end
        end
 
        if WoodESPEnabled then
            local entry, anchor = getWoodEntry(child)
            if entry then
                tracked[child] = true
                table.insert(espObjects, createWoodESP(child, entry, anchor))
            end
        end
    end
 
    local folders = {
        workspace:FindFirstChild("Objects"),
        workspace:FindFirstChild("Trees"),
        workspace,
    }
    for _, folder in ipairs(folders) do
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                tryAddModel(child)
            end
        end
    end
end
 
-- Polling
task.spawn(function()
    while true do
        task.wait(5)
        pcall(function()
            if not (WoodESPEnabled or StoneESPEnabled) then return end
 
            local stale = {}
            for i, data in ipairs(espObjects) do
                if not data.model or not data.model.Parent
                or not data.anchorPart or not data.anchorPart.Parent then
                    destroyESP(data)
                    tracked[data.model] = nil
                    table.insert(stale, i)
                end
            end
            for i = #stale, 1, -1 do table.remove(espObjects, stale[i]) end
 
            local folders = {
                workspace:FindFirstChild("Objects"),
                workspace:FindFirstChild("Trees"),
                workspace,
            }
            for _, folder in ipairs(folders) do
                if folder then
                    for _, child in ipairs(folder:GetChildren()) do
                        if child:IsA("Model") and not tracked[child] then
                            if StoneESPEnabled then
                                local sEntry, sAnchor, metals = getStoneEntry(child)
                                if sEntry then
                                    tracked[child] = true
                                    table.insert(espObjects, createStoneESP(child, sEntry, sAnchor, metals or {}))
                                    continue
                                end
                            end
                            if WoodESPEnabled then
                                local wEntry, wAnchor = getWoodEntry(child)
                                if wEntry then
                                    tracked[child] = true
                                    table.insert(espObjects, createWoodESP(child, wEntry, wAnchor))
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)
 
-- ============================================================
-- Walkspeed heartbeat
-- ============================================================
local targetWalkspeed = 16
RunService.Heartbeat:Connect(function()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= targetWalkspeed then
        hum.WalkSpeed = targetWalkspeed
    end
end)
 
-- ============================================================
-- UI Constants
-- ============================================================
local SIDEBAR_W    = 130
local TOTAL_W      = 530
local TOTAL_H      = 600
local CONTENT_W    = TOTAL_W - SIDEBAR_W
 
local ACCENT       = RGB(38, 120, 210)
local BG_DARKEST   = RGB(14, 14, 18)
local BG_DARK      = RGB(20, 20, 26)
local BG_MID       = RGB(28, 28, 36)
local BG_LIGHT     = RGB(38, 38, 48)
local BG_HOVER     = RGB(45, 45, 58)
local TEXT_MAIN    = RGB(220, 220, 228)
local TEXT_DIM     = RGB(110, 110, 125)
local TEXT_ACCENT  = RGB(80, 160, 255)
local GREEN_ON     = RGB(34, 150, 70)
local RED_OFF      = RGB(50, 50, 62)
local DIVIDER      = RGB(40, 40, 52)
 
-- ============================================================
-- Existing GUI cleanup
-- ============================================================
pcall(function()
    local old = game.CoreGui:FindFirstChild("WindgateHub_UI")
    if old then old:Destroy() end
end)
 
-- ============================================================
-- Root ScreenGui
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name           = "WindgateHub_UI"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = game.CoreGui
 
-- ============================================================
-- SPLASH SCREEN
-- ============================================================
local splash = Instance.new("Frame", gui)
splash.Name               = "Splash"
splash.Size               = UDim2.new(1, 0, 1, 0)
splash.BackgroundColor3   = RGB(8, 8, 12)
splash.BackgroundTransparency = 0
splash.ZIndex             = 100
 
local splashContent = Instance.new("Frame", splash)
splashContent.Size               = UDim2.new(0, 320, 0, 180)
splashContent.AnchorPoint        = Vector2.new(0.5, 0.5)
splashContent.Position           = UDim2.new(0.5, 0, 0.5, 0)
splashContent.BackgroundColor3   = BG_DARK
splashContent.BackgroundTransparency = 0
splashContent.BorderSizePixel    = 0
Instance.new("UICorner", splashContent).CornerRadius = UDim.new(0, 12)
local splashStroke = Instance.new("UIStroke", splashContent)
splashStroke.Color     = RGB(50, 100, 180)
splashStroke.Thickness = 1.5
 
-- Logo row
local splashLogoW = Instance.new("TextLabel", splashContent)
splashLogoW.Size                   = UDim2.new(0, 40, 0, 40)
splashLogoW.Position               = UDim2.new(0, 16, 0, 16)
splashLogoW.BackgroundTransparency = 1
splashLogoW.Font                   = Enum.Font.GothamBold
splashLogoW.TextSize               = 28
splashLogoW.TextColor3             = ACCENT
splashLogoW.Text                   = "W"
 
local splashTitle = Instance.new("TextLabel", splashContent)
splashTitle.Size                   = UDim2.new(1, -60, 0, 40)
splashTitle.Position               = UDim2.new(0, 56, 0, 16)
splashTitle.BackgroundTransparency = 1
splashTitle.Font                   = Enum.Font.GothamBold
splashTitle.TextSize               = 16
splashTitle.TextColor3             = TEXT_MAIN
splashTitle.Text                   = "Windgate"
splashTitle.TextXAlignment         = Enum.TextXAlignment.Left
 
-- Avatar image
local avatarHolder = Instance.new("Frame", splashContent)
avatarHolder.Size             = UDim2.new(0, 60, 0, 60)
avatarHolder.Position         = UDim2.new(0, 16, 0, 70)
avatarHolder.BackgroundColor3 = BG_MID
avatarHolder.BorderSizePixel  = 0
Instance.new("UICorner", avatarHolder).CornerRadius = UDim.new(0, 6)
 
local avatarImg = Instance.new("ImageLabel", avatarHolder)
avatarImg.Size                = UDim2.new(1, 0, 1, 0)
avatarImg.BackgroundTransparency = 1
avatarImg.BorderSizePixel     = 0
avatarImg.ScaleType           = Enum.ScaleType.Fit
Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 6)
 
-- Try to load avatar
pcall(function()
    local userId = lp.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size100x100
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    avatarImg.Image = content
end)
 
local welcomeLabel = Instance.new("TextLabel", splashContent)
welcomeLabel.Size                   = UDim2.new(1, -92, 0, 28)
welcomeLabel.Position               = UDim2.new(0, 86, 0, 72)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Font                   = Enum.Font.GothamBold
welcomeLabel.TextSize               = 14
welcomeLabel.TextColor3             = TEXT_MAIN
welcomeLabel.Text                   = "Welcome,"
welcomeLabel.TextXAlignment         = Enum.TextXAlignment.Left
 
local usernameLabel = Instance.new("TextLabel", splashContent)
usernameLabel.Size                   = UDim2.new(1, -92, 0, 24)
usernameLabel.Position               = UDim2.new(0, 86, 0, 96)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Font                   = Enum.Font.GothamBold
usernameLabel.TextSize               = 18
usernameLabel.TextColor3             = TEXT_ACCENT
usernameLabel.Text                   = lp.DisplayName or lp.Name
usernameLabel.TextXAlignment         = Enum.TextXAlignment.Left
 
local loadingBar = Instance.new("Frame", splashContent)
loadingBar.Size             = UDim2.new(0, 0, 0, 3)
loadingBar.Position         = UDim2.new(0, 0, 1, -3)
loadingBar.BackgroundColor3 = ACCENT
loadingBar.BorderSizePixel  = 0
Instance.new("UICorner", loadingBar).CornerRadius = UDim.new(0, 2)
 
-- Animate loading bar then fade splash
TweenService:Create(loadingBar, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(1, 0, 0, 3)
}):Play()
 
task.delay(2.2, function()
    TweenService:Create(splash, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(splashContent, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.45, 0)
    }):Play()
    for _, d in ipairs(splashContent:GetDescendants()) do
        if d:IsA("GuiObject") then
            pcall(function()
                TweenService:Create(d, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            end)
            if d:IsA("TextLabel") then
                TweenService:Create(d, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            end
        end
    end
    task.delay(0.6, function()
        splash.Visible = false
    end)
end)
 
-- ============================================================
-- MAIN WINDOW
-- ============================================================
local mainFrame = Instance.new("Frame", gui)
mainFrame.Name               = "MainFrame"
mainFrame.Size               = UDim2.new(0, TOTAL_W, 0, TOTAL_H)
mainFrame.AnchorPoint        = Vector2.new(0.5, 0.5)
mainFrame.Position           = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3   = BG_DARKEST
mainFrame.BorderSizePixel    = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color     = RGB(45, 45, 60)
mainStroke.Thickness = 1
 
-- ── Title Bar ─────────────────────────────────────────────
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size             = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = BG_DARK
titleBar.BorderSizePixel  = 0
local tbCorner = Instance.new("UICorner", titleBar)
tbCorner.CornerRadius = UDim.new(0, 10)
-- Fill bottom corners
local tbFill = Instance.new("Frame", titleBar)
tbFill.Size             = UDim2.new(1, 0, 0, 10)
tbFill.Position         = UDim2.new(0, 0, 1, -10)
tbFill.BackgroundColor3 = BG_DARK
tbFill.BorderSizePixel  = 0
 
local tbLogoW = Instance.new("TextLabel", titleBar)
tbLogoW.Size                   = UDim2.new(0, 24, 1, 0)
tbLogoW.Position               = UDim2.new(0, 10, 0, 0)
tbLogoW.BackgroundTransparency = 1
tbLogoW.Font                   = Enum.Font.GothamBold
tbLogoW.TextSize               = 18
tbLogoW.TextColor3             = ACCENT
tbLogoW.Text                   = "W"
 
local tbTitle = Instance.new("TextLabel", titleBar)
tbTitle.Size                   = UDim2.new(0, 160, 1, 0)
tbTitle.Position               = UDim2.new(0, 36, 0, 0)
tbTitle.BackgroundTransparency = 1
tbTitle.Font                   = Enum.Font.GothamBold
tbTitle.TextSize               = 13
tbTitle.TextColor3             = TEXT_MAIN
tbTitle.Text                   = "Windgate"
tbTitle.TextXAlignment         = Enum.TextXAlignment.Left
 
-- Close button
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size             = UDim2.new(0, 26, 0, 26)
closeBtn.AnchorPoint      = Vector2.new(1, 0.5)
closeBtn.Position         = UDim2.new(1, -8, 0.5, 0)
closeBtn.BackgroundColor3 = RGB(180, 50, 50)
closeBtn.BorderSizePixel  = 0
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 14
closeBtn.TextColor3       = Color3.new(1,1,1)
closeBtn.Text             = "×"
closeBtn.AutoButtonColor  = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    clearAll()
end)
 
-- Minimize button
local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size             = UDim2.new(0, 26, 0, 26)
minBtn.AnchorPoint      = Vector2.new(1, 0.5)
minBtn.Position         = UDim2.new(1, -40, 0.5, 0)
minBtn.BackgroundColor3 = RGB(180, 140, 30)
minBtn.BorderSizePixel  = 0
minBtn.Font             = Enum.Font.GothamBold
minBtn.TextSize         = 14
minBtn.TextColor3       = Color3.new(1,1,1)
minBtn.Text             = "–"
minBtn.AutoButtonColor  = false
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)
 
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    -- Toggle sidebar + content area visibility
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child.Name ~= "TitleBar" and child ~= titleBar and child ~= tbFill then
            child.Visible = not minimized
        end
    end
    mainFrame.Size = minimized and UDim2.new(0, TOTAL_W, 0, 38) or UDim2.new(0, TOTAL_W, 0, TOTAL_H)
end)
 
-- ── Body ──────────────────────────────────────────────────
local body = Instance.new("Frame", mainFrame)
body.Name             = "Body"
body.Size             = UDim2.new(1, 0, 1, -38)
body.Position         = UDim2.new(0, 0, 0, 38)
body.BackgroundTransparency = 1
body.BorderSizePixel  = 0
 
-- ── Sidebar ───────────────────────────────────────────────
local sidebar = Instance.new("Frame", body)
sidebar.Name             = "Sidebar"
sidebar.Size             = UDim2.new(0, SIDEBAR_W, 1, 0)
sidebar.BackgroundColor3 = BG_DARK
sidebar.BorderSizePixel  = 0
local sbCorner = Instance.new("UICorner", sidebar)
sbCorner.CornerRadius = UDim.new(0, 10)
-- Fill right corners
local sbFill = Instance.new("Frame", sidebar)
sbFill.Size             = UDim2.new(0, 10, 1, 0)
sbFill.Position         = UDim2.new(1, -10, 0, 0)
sbFill.BackgroundColor3 = BG_DARK
sbFill.BorderSizePixel  = 0
 
-- Sidebar version label at bottom
local versionLabel = Instance.new("TextLabel", sidebar)
versionLabel.Size                   = UDim2.new(1, 0, 0, 18)
versionLabel.AnchorPoint            = Vector2.new(0, 1)
versionLabel.Position               = UDim2.new(0, 0, 1, -6)
versionLabel.BackgroundTransparency = 1
versionLabel.Font                   = Enum.Font.Gotham
versionLabel.TextSize               = 9
versionLabel.TextColor3             = TEXT_DIM
versionLabel.Text                   = "v2.0"
 
-- ── Content ───────────────────────────────────────────────
local contentArea = Instance.new("Frame", body)
contentArea.Name             = "Content"
contentArea.Size             = UDim2.new(0, CONTENT_W, 1, 0)
contentArea.Position         = UDim2.new(0, SIDEBAR_W, 0, 0)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel  = 0
contentArea.ClipsDescendants = true
 
-- ============================================================
-- Tab definitions
-- ============================================================
local TABS = {
    { name = "Home",      icon = "🏠", emoji = true },
    { name = "ESP",       icon = "👁",  emoji = true },
    { name = "Player",    icon = "🏃", emoji = true },
    { name = "Transport", icon = "⛵", emoji = true },
    { name = "Farm",      icon = "🌲", emoji = true },
    { name = "Settings",  icon = "⚙",  emoji = true },
}
 
local activeTabName = "Home"
local tabButtons    = {}
local tabPages      = {}
 
local sbLayout = Instance.new("UIListLayout", sidebar)
sbLayout.SortOrder   = Enum.SortOrder.LayoutOrder
sbLayout.Padding     = UDim.new(0, 2)
local sbPad = Instance.new("UIPadding", sidebar)
sbPad.PaddingTop    = UDim.new(0, 8)
sbPad.PaddingBottom = UDim.new(0, 28)
sbPad.PaddingLeft   = UDim.new(0, 6)
sbPad.PaddingRight  = UDim.new(0, 6)
 
local function setActiveTab(name)
    activeTabName = name
    for tname, btn in pairs(tabButtons) do
        local isActive = (tname == name)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isActive and BG_HOVER or BG_DARK,
        }):Play()
        -- Accent bar
        local bar = btn:FindFirstChild("AccentBar")
        if bar then bar.Visible = isActive end
        -- Text colors
        local lbl = btn:FindFirstChild("IconLabel")
        local txt = btn:FindFirstChild("TextLabel")
        if lbl then lbl.TextColor3 = isActive and ACCENT or TEXT_DIM end
        if txt then txt.TextColor3 = isActive and TEXT_MAIN or TEXT_DIM end
    end
    for tname, page in pairs(tabPages) do
        page.Visible = (tname == name)
    end
end
 
-- Build sidebar tab buttons
for i, tab in ipairs(TABS) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Name             = tab.name .. "Btn"
    btn.LayoutOrder      = i
    btn.Size             = UDim2.new(1, 0, 0, 68)
    btn.BackgroundColor3 = BG_DARK
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
 
    -- Accent bar on left
    local accentBar = Instance.new("Frame", btn)
    accentBar.Name            = "AccentBar"
    accentBar.Size            = UDim2.new(0, 3, 0.6, 0)
    accentBar.AnchorPoint     = Vector2.new(0, 0.5)
    accentBar.Position        = UDim2.new(0, 0, 0.5, 0)
    accentBar.BackgroundColor3= ACCENT
    accentBar.BorderSizePixel = 0
    accentBar.Visible         = false
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)
 
    -- Icon
    local iconLbl = Instance.new("TextLabel", btn)
    iconLbl.Name                   = "IconLabel"
    iconLbl.Size                   = UDim2.new(1, 0, 0, 30)
    iconLbl.Position               = UDim2.new(0, 0, 0, 10)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Font                   = Enum.Font.GothamBold
    iconLbl.TextSize               = 22
    iconLbl.TextColor3             = TEXT_DIM
    iconLbl.Text                   = tab.icon
    iconLbl.TextXAlignment         = Enum.TextXAlignment.Center
 
    -- Label
    local nameLbl = Instance.new("TextLabel", btn)
    nameLbl.Name                   = "TextLabel"
    nameLbl.Size                   = UDim2.new(1, 0, 0, 16)
    nameLbl.Position               = UDim2.new(0, 0, 0, 44)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font                   = Enum.Font.Gotham
    nameLbl.TextSize               = 10
    nameLbl.TextColor3             = TEXT_DIM
    nameLbl.Text                   = tab.name
    nameLbl.TextXAlignment         = Enum.TextXAlignment.Center
 
    tabButtons[tab.name] = btn
 
    btn.MouseButton1Click:Connect(function()
        setActiveTab(tab.name)
    end)
end
 
-- ============================================================
-- Page builder helpers
-- ============================================================
local function makePage(name)
    local page = Instance.new("ScrollingFrame", contentArea)
    page.Name                = name .. "Page"
    page.Size                = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel     = 0
    page.ScrollBarThickness  = 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize          = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible             = false
 
    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding   = UDim.new(0, 6)
 
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop    = UDim.new(0, 12)
    pad.PaddingLeft   = UDim.new(0, 10)
    pad.PaddingRight  = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 12)
 
    tabPages[name] = page
    return page
end
 
local function makeLabel(parent, text, order, textSize, color)
    local lbl = Instance.new("TextLabel", parent)
    lbl.LayoutOrder              = order
    lbl.Size                     = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency   = 1
    lbl.Font                     = Enum.Font.GothamBold
    lbl.TextSize                 = textSize or 10
    lbl.TextColor3               = color or TEXT_DIM
    lbl.Text                     = text
    lbl.TextXAlignment           = Enum.TextXAlignment.Left
    return lbl
end
 
local function makeDivider(parent, order)
    local d = Instance.new("Frame", parent)
    d.LayoutOrder            = order
    d.Size                   = UDim2.new(1, 0, 0, 1)
    d.BackgroundColor3       = DIVIDER
    d.BorderSizePixel        = 0
    return d
end
 
-- Toggle row: returns row frame and getter
local function makeToggle(parent, labelText, startOn, order, dotColor, onToggle)
    dotColor = dotColor or ACCENT
 
    local row = Instance.new("Frame", parent)
    row.LayoutOrder              = order
    row.Size                     = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3         = BG_LIGHT
    row.BorderSizePixel          = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
 
    local dot = Instance.new("Frame", row)
    dot.Size             = UDim2.new(0, 8, 0, 8)
    dot.AnchorPoint      = Vector2.new(0, 0.5)
    dot.Position         = UDim2.new(0, 8, 0.5, 0)
    dot.BackgroundColor3 = dotColor
    dot.BorderSizePixel  = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
 
    local lbl = Instance.new("TextLabel", row)
    lbl.Size                   = UDim2.new(1, -80, 1, 0)
    lbl.Position               = UDim2.new(0, 22, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font                   = Enum.Font.Gotham
    lbl.TextSize               = 12
    lbl.TextColor3             = TEXT_MAIN
    lbl.Text                   = labelText
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
 
    local togBtn = Instance.new("TextButton", row)
    togBtn.Size             = UDim2.new(0, 48, 0, 20)
    togBtn.AnchorPoint      = Vector2.new(1, 0.5)
    togBtn.Position         = UDim2.new(1, -8, 0.5, 0)
    togBtn.BackgroundColor3 = startOn and GREEN_ON or RED_OFF
    togBtn.BorderSizePixel  = 0
    togBtn.Font             = Enum.Font.GothamBold
    togBtn.TextSize         = 10
    togBtn.TextColor3       = startOn and Color3.new(1,1,1) or TEXT_DIM
    togBtn.Text             = startOn and "ON" or "OFF"
    togBtn.AutoButtonColor  = false
    Instance.new("UICorner", togBtn).CornerRadius = UDim.new(1, 0)
 
    local state = startOn
    togBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(togBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = state and GREEN_ON or RED_OFF
        }):Play()
        togBtn.TextColor3 = state and Color3.new(1,1,1) or TEXT_DIM
        togBtn.Text       = state and "ON" or "OFF"
        if onToggle then onToggle(state) end
    end)
 
    return row, function() return state end
end
 
-- Collapsible dropdown section
local function makeCollapsible(parent, title, db, enabledMap, startOrder, onToggleCb)
    local ORDER = startOrder
 
    local headerBtn = Instance.new("TextButton", parent)
    headerBtn.LayoutOrder              = ORDER; ORDER += 1
    headerBtn.Size                     = UDim2.new(1, 0, 0, 28)
    headerBtn.BackgroundColor3         = BG_MID
    headerBtn.BorderSizePixel          = 0
    headerBtn.Font                     = Enum.Font.GothamBold
    headerBtn.TextSize                 = 11
    headerBtn.TextColor3               = TEXT_MAIN
    headerBtn.Text                     = "▶  " .. title
    headerBtn.TextXAlignment           = Enum.TextXAlignment.Left
    headerBtn.AutoButtonColor          = false
    Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, 6)
    local hPad = Instance.new("UIPadding", headerBtn)
    hPad.PaddingLeft = UDim.new(0, 10)
 
    local container = Instance.new("Frame", parent)
    container.LayoutOrder              = ORDER; ORDER += 1
    container.Size                     = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency   = 1
    container.BorderSizePixel          = 0
    container.Visible                  = false
 
    local cLayout = Instance.new("UIListLayout", container)
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cLayout.Padding   = UDim.new(0, 3)
    local cPad = Instance.new("UIPadding", container)
    cPad.PaddingLeft  = UDim.new(0, 8)
    cPad.PaddingTop   = UDim.new(0, 3)
    cPad.PaddingBottom= UDim.new(0, 3)
 
    for idx, entry in ipairs(db) do
        local entryColor = entry.Color or ACCENT
        makeToggle(container, entry.Name, enabledMap[entry.Name], idx, entryColor, function(on)
            enabledMap[entry.Name] = on
            if onToggleCb then onToggleCb() end
        end)
    end
 
    local rowH   = 34
    local totalH = #db * rowH + (#db - 1) * 3 + 6
    container.Size = UDim2.new(1, 0, 0, totalH)
 
    local open = false
    headerBtn.MouseButton1Click:Connect(function()
        open = not open
        container.Visible = open
        headerBtn.Text    = (open and "▼  " or "▶  ") .. title
    end)
 
    return ORDER
end
 
-- ============================================================
-- HOME TAB
-- ============================================================
local homePage = makePage("Home")
local ho = 1
 
-- Welcome card
local welcomeCard = Instance.new("Frame", homePage)
welcomeCard.LayoutOrder      = ho; ho += 1
welcomeCard.Size             = UDim2.new(1, 0, 0, 80)
welcomeCard.BackgroundColor3 = BG_MID
welcomeCard.BorderSizePixel  = 0
Instance.new("UICorner", welcomeCard).CornerRadius = UDim.new(0, 8)
local wcStroke = Instance.new("UIStroke", welcomeCard)
wcStroke.Color     = RGB(40, 80, 140)
wcStroke.Thickness = 1
 
local wcAvatarFrame = Instance.new("Frame", welcomeCard)
wcAvatarFrame.Size             = UDim2.new(0, 54, 0, 54)
wcAvatarFrame.AnchorPoint      = Vector2.new(0, 0.5)
wcAvatarFrame.Position         = UDim2.new(0, 12, 0.5, 0)
wcAvatarFrame.BackgroundColor3 = BG_LIGHT
wcAvatarFrame.BorderSizePixel  = 0
Instance.new("UICorner", wcAvatarFrame).CornerRadius = UDim.new(0, 8)
 
local wcAvatar = Instance.new("ImageLabel", wcAvatarFrame)
wcAvatar.Size                = UDim2.new(1, 0, 1, 0)
wcAvatar.BackgroundTransparency = 1
wcAvatar.ScaleType           = Enum.ScaleType.Fit
Instance.new("UICorner", wcAvatar).CornerRadius = UDim.new(0, 8)
pcall(function()
    local content, _ = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    wcAvatar.Image = content
end)
 
local wcWelcome = Instance.new("TextLabel", welcomeCard)
wcWelcome.Size                   = UDim2.new(1, -80, 0, 22)
wcWelcome.Position               = UDim2.new(0, 76, 0, 16)
wcWelcome.BackgroundTransparency = 1
wcWelcome.Font                   = Enum.Font.Gotham
wcWelcome.TextSize               = 11
wcWelcome.TextColor3             = TEXT_DIM
wcWelcome.Text                   = "Welcome back,"
wcWelcome.TextXAlignment         = Enum.TextXAlignment.Left
 
local wcName = Instance.new("TextLabel", welcomeCard)
wcName.Size                   = UDim2.new(1, -80, 0, 26)
wcName.Position               = UDim2.new(0, 76, 0, 34)
wcName.BackgroundTransparency = 1
wcName.Font                   = Enum.Font.GothamBold
wcName.TextSize               = 16
wcName.TextColor3             = TEXT_MAIN
wcName.Text                   = lp.DisplayName or lp.Name
wcName.TextXAlignment         = Enum.TextXAlignment.Left
 
-- Section label
makeLabel(homePage, "QUICK ACTIONS", ho, 9, TEXT_DIM); ho += 1
 
-- Rejoin button
local rejoinBtn = Instance.new("TextButton", homePage)
rejoinBtn.LayoutOrder      = ho; ho += 1
rejoinBtn.Size             = UDim2.new(1, 0, 0, 36)
rejoinBtn.BackgroundColor3 = ACCENT
rejoinBtn.BorderSizePixel  = 0
rejoinBtn.Font             = Enum.Font.GothamBold
rejoinBtn.TextSize         = 13
rejoinBtn.TextColor3       = Color3.new(1,1,1)
rejoinBtn.Text             = "🔄  Rejoin Server"
rejoinBtn.AutoButtonColor  = false
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 6)
rejoinBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, lp)
    end)
end)
rejoinBtn.MouseEnter:Connect(function()
    TweenService:Create(rejoinBtn, TweenInfo.new(0.12), {BackgroundColor3 = RGB(55, 140, 240)}):Play()
end)
rejoinBtn.MouseLeave:Connect(function()
    TweenService:Create(rejoinBtn, TweenInfo.new(0.12), {BackgroundColor3 = ACCENT}):Play()
end)
 
-- ============================================================
-- ESP TAB
-- ============================================================
local espPage = makePage("ESP")
local eo = 1
 
makeLabel(espPage, "ESP CONTROLS", eo, 9, TEXT_DIM); eo += 1
 
-- Wood ESP toggle
makeToggle(espPage, "Wood ESP", false, eo, RGB(180, 140, 90), function(on)
    WoodESPEnabled = on
    rebuildESP()
end); eo += 1
 
-- Wood dropdown
eo = makeCollapsible(espPage, "Wood Types", WOOD_DB, woodEnabled, eo, rebuildESP)
 
makeDivider(espPage, eo); eo += 1
 
-- Stone ESP toggle
makeToggle(espPage, "Stone ESP", false, eo, RGB(180, 180, 200), function(on)
    StoneESPEnabled = on
    rebuildESP()
end); eo += 1
 
-- Stone dropdown
eo = makeCollapsible(espPage, "Stone Types", STONE_DB, stoneEnabled, eo, rebuildESP)
 
makeDivider(espPage, eo); eo += 1
makeLabel(espPage, "METAL DETECTION", eo, 9, TEXT_DIM); eo += 1
 
-- Metal ESP toggle (linked to stone)
makeToggle(espPage, "Metal ESP (with Stone)", false, eo, RGB(220, 190, 60), function(on)
    MetalESPEnabled = on
    if StoneESPEnabled then rebuildESP() end
end); eo += 1
 
-- Metal dropdown
eo = makeCollapsible(espPage, "Metal Types", METAL_DB, metalEnabled, eo, function()
    if StoneESPEnabled and MetalESPEnabled then rebuildESP() end
end)
 
-- ============================================================
-- PLAYER TAB
-- ============================================================
local playerPage = makePage("Player")
local po = 1
 
makeLabel(playerPage, "MOVEMENT", po, 9, TEXT_DIM); po += 1
 
-- Walkspeed card
local wsCard = Instance.new("Frame", playerPage)
wsCard.LayoutOrder      = po; po += 1
wsCard.Size             = UDim2.new(1, 0, 0, 80)
wsCard.BackgroundColor3 = BG_LIGHT
wsCard.BorderSizePixel  = 0
Instance.new("UICorner", wsCard).CornerRadius = UDim.new(0, 8)
 
local wsLabel = Instance.new("TextLabel", wsCard)
wsLabel.Size                   = UDim2.new(0, 100, 0, 22)
wsLabel.Position               = UDim2.new(0, 10, 0, 8)
wsLabel.BackgroundTransparency = 1
wsLabel.Font                   = Enum.Font.Gotham
wsLabel.TextSize               = 12
wsLabel.TextColor3             = TEXT_MAIN
wsLabel.Text                   = "Walkspeed"
wsLabel.TextXAlignment         = Enum.TextXAlignment.Left
 
-- Number input box (clickable)
local wsNumBox = Instance.new("TextBox", wsCard)
wsNumBox.Size             = UDim2.new(0, 52, 0, 22)
wsNumBox.Position         = UDim2.new(1, -62, 0, 8)
wsNumBox.BackgroundColor3 = BG_MID
wsNumBox.BorderSizePixel  = 0
wsNumBox.Font             = Enum.Font.GothamBold
wsNumBox.TextSize         = 13
wsNumBox.TextColor3       = TEXT_ACCENT
wsNumBox.Text             = "16"
wsNumBox.TextXAlignment   = Enum.TextXAlignment.Center
wsNumBox.ClearTextOnFocus = true
Instance.new("UICorner", wsNumBox).CornerRadius = UDim.new(0, 4)
 
-- Slider track
local sliderTrack = Instance.new("Frame", wsCard)
sliderTrack.Size             = UDim2.new(1, -20, 0, 6)
sliderTrack.Position         = UDim2.new(0, 10, 0, 44)
sliderTrack.BackgroundColor3 = BG_MID
sliderTrack.BorderSizePixel  = 0
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)
 
local sliderFill = Instance.new("Frame", sliderTrack)
sliderFill.Size             = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = ACCENT
sliderFill.BorderSizePixel  = 0
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
 
local sliderKnob = Instance.new("TextButton", sliderTrack)
sliderKnob.Size             = UDim2.new(0, 16, 0, 16)
sliderKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
sliderKnob.Position         = UDim2.new(0, 0, 0.5, 0)
sliderKnob.BackgroundColor3 = Color3.new(1,1,1)
sliderKnob.BorderSizePixel  = 0
sliderKnob.Text             = ""
sliderKnob.AutoButtonColor  = false
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
 
local MIN_WS, MAX_WS = 16, 100
 
local function setWalkspeedUI(val)
    val = math.clamp(math.floor(val + 0.5), MIN_WS, MAX_WS)
    targetWalkspeed = val
    wsNumBox.Text = tostring(val)
    local frac = (val - MIN_WS) / (MAX_WS - MIN_WS)
    local trackW = sliderTrack.AbsoluteSize.X
    sliderFill.Size = UDim2.new(0, frac * trackW, 1, 0)
    sliderKnob.Position = UDim2.new(0, frac * trackW, 0.5, 0)
end
 
setWalkspeedUI(16)
 
-- Slider dragging
local sliderDragging = false
sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local trackPos = sliderTrack.AbsolutePosition.X
        local trackW   = sliderTrack.AbsoluteSize.X
        local frac     = math.clamp((input.Position.X - trackPos) / trackW, 0, 1)
        local val      = math.floor(MIN_WS + frac * (MAX_WS - MIN_WS) + 0.5)
        setWalkspeedUI(val)
    end
end)
sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local trackPos = sliderTrack.AbsolutePosition.X
        local trackW   = sliderTrack.AbsoluteSize.X
        local frac     = math.clamp((input.Position.X - trackPos) / trackW, 0, 1)
        local val      = math.floor(MIN_WS + frac * (MAX_WS - MIN_WS) + 0.5)
        setWalkspeedUI(val)
        sliderDragging = true
    end
end)
 
wsNumBox.FocusLost:Connect(function()
    local num = tonumber(wsNumBox.Text)
    if num then
        setWalkspeedUI(math.clamp(num, MIN_WS, MAX_WS))
    else
        wsNumBox.Text = tostring(targetWalkspeed)
    end
end)
 
-- Speed presets
local presetsLabel = makeLabel(playerPage, "PRESETS", po, 9, TEXT_DIM); po += 1
 
local presetsFrame = Instance.new("Frame", playerPage)
presetsFrame.LayoutOrder      = po; po += 1
presetsFrame.Size             = UDim2.new(1, 0, 0, 32)
presetsFrame.BackgroundTransparency = 1
local presetsLayout = Instance.new("UIListLayout", presetsFrame)
presetsLayout.FillDirection = Enum.FillDirection.Horizontal
presetsLayout.Padding       = UDim.new(0, 4)
 
for _, preset in ipairs({16, 32, 50, 100}) do
    local pb = Instance.new("TextButton", presetsFrame)
    pb.Size             = UDim2.new(0, 60, 1, 0)
    pb.BackgroundColor3 = BG_LIGHT
    pb.BorderSizePixel  = 0
    pb.Font             = Enum.Font.GothamBold
    pb.TextSize         = 11
    pb.TextColor3       = TEXT_MAIN
    pb.Text             = tostring(preset)
    pb.AutoButtonColor  = false
    Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 5)
    pb.MouseButton1Click:Connect(function()
        setWalkspeedUI(preset)
    end)
end
 
-- ============================================================
-- TRANSPORT TAB
-- ============================================================
local transportPage = makePage("Transport")
local to = 1
 
local tCenter = Instance.new("Frame", transportPage)
tCenter.LayoutOrder      = to; to += 1
tCenter.Size             = UDim2.new(1, 0, 0, 200)
tCenter.BackgroundTransparency = 1
 
local tIcon = Instance.new("TextLabel", tCenter)
tIcon.Size                   = UDim2.new(1, 0, 0, 80)
tIcon.Position               = UDim2.new(0, 0, 0, 30)
tIcon.BackgroundTransparency = 1
tIcon.Font                   = Enum.Font.GothamBold
tIcon.TextSize               = 60
tIcon.TextColor3             = TEXT_DIM
tIcon.Text                   = "⛵"
tIcon.TextXAlignment         = Enum.TextXAlignment.Center
 
local tLabel = Instance.new("TextLabel", tCenter)
tLabel.Size                   = UDim2.new(1, 0, 0, 24)
tLabel.Position               = UDim2.new(0, 0, 0, 118)
tLabel.BackgroundTransparency = 1
tLabel.Font                   = Enum.Font.GothamBold
tLabel.TextSize               = 14
tLabel.TextColor3             = TEXT_DIM
tLabel.Text                   = "Transport"
tLabel.TextXAlignment         = Enum.TextXAlignment.Center
 
local tSub = Instance.new("TextLabel", tCenter)
tSub.Size                   = UDim2.new(1, 0, 0, 18)
tSub.Position               = UDim2.new(0, 0, 0, 148)
tSub.BackgroundTransparency = 1
tSub.Font                   = Enum.Font.Gotham
tSub.TextSize               = 10
tSub.TextColor3             = TEXT_DIM
tSub.Text                   = "Coming soon..."
tSub.TextXAlignment         = Enum.TextXAlignment.Center
 
-- ============================================================
-- FARM TAB
-- ============================================================
local farmPage = makePage("Farm")
local fo = 1
 
local fCenter = Instance.new("Frame", farmPage)
fCenter.LayoutOrder      = fo; fo += 1
fCenter.Size             = UDim2.new(1, 0, 0, 200)
fCenter.BackgroundTransparency = 1
 
local fIcon = Instance.new("TextLabel", fCenter)
fIcon.Size                   = UDim2.new(1, 0, 0, 80)
fIcon.Position               = UDim2.new(0, 0, 0, 30)
fIcon.BackgroundTransparency = 1
fIcon.Font                   = Enum.Font.GothamBold
fIcon.TextSize               = 60
fIcon.TextColor3             = TEXT_DIM
fIcon.Text                   = "🌲"
fIcon.TextXAlignment         = Enum.TextXAlignment.Center
 
local fLabel = Instance.new("TextLabel", fCenter)
fLabel.Size                   = UDim2.new(1, 0, 0, 24)
fLabel.Position               = UDim2.new(0, 0, 0, 118)
fLabel.BackgroundTransparency = 1
fLabel.Font                   = Enum.Font.GothamBold
fLabel.TextSize               = 14
fLabel.TextColor3             = TEXT_DIM
fLabel.Text                   = "Farm"
fLabel.TextXAlignment         = Enum.TextXAlignment.Center
 
local fSub = Instance.new("TextLabel", fCenter)
fSub.Size                   = UDim2.new(1, 0, 0, 18)
fSub.Position               = UDim2.new(0, 0, 0, 148)
fSub.BackgroundTransparency = 1
fSub.Font                   = Enum.Font.Gotham
fSub.TextSize               = 10
fSub.TextColor3             = TEXT_DIM
fSub.Text                   = "Coming soon..."
fSub.TextXAlignment         = Enum.TextXAlignment.Center
 
-- ============================================================
-- SETTINGS TAB
-- ============================================================
local settingsPage = makePage("Settings")
local so = 1
 
makeLabel(settingsPage, "DISPLAY", so, 9, TEXT_DIM); so += 1
 
makeToggle(settingsPage, "Show Highlight Fill", true, so, ACCENT, function(on)
    for _, d in ipairs(espObjects) do
        pcall(function() d.highlight.FillTransparency = on and 0.6 or 1 end)
    end
end); so += 1
 
makeToggle(settingsPage, "Always On Top", true, so, ACCENT, function(on)
    for _, d in ipairs(espObjects) do
        pcall(function() d.highlight.DepthMode = on and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded end)
    end
end); so += 1
 
makeDivider(settingsPage, so); so += 1
makeLabel(settingsPage, "INFO", so, 9, TEXT_DIM); so += 1
 
local infoCard = Instance.new("Frame", settingsPage)
infoCard.LayoutOrder      = so; so += 1
infoCard.Size             = UDim2.new(1, 0, 0, 76)
infoCard.BackgroundColor3 = BG_LIGHT
infoCard.BorderSizePixel  = 0
Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0, 8)
 
local infoLbl = Instance.new("TextLabel", infoCard)
infoLbl.Size                     = UDim2.new(1, -16, 1, -16)
infoLbl.Position                 = UDim2.new(0, 8, 0, 8)
infoLbl.BackgroundTransparency   = 1
infoLbl.Font                     = Enum.Font.Gotham
infoLbl.TextSize                 = 10
infoLbl.TextColor3               = TEXT_DIM
infoLbl.Text                     = "Windgate Hub v2.0\nWood + Stone + Metal ESP\nPolls every 5s | Always-on-top\nWalkspeed override via Heartbeat"
infoLbl.TextXAlignment           = Enum.TextXAlignment.Left
infoLbl.TextYAlignment           = Enum.TextYAlignment.Top
infoLbl.TextWrapped              = true
 
-- ============================================================
-- Activate default tab
-- ============================================================
setActiveTab("Home")
 
-- ============================================================
-- Dragging (title bar)
-- ============================================================
local dragging, dragStart, startPos = false, nil, nil
 
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = mainFrame.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                  or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
 
-- ============================================================
-- L Alt: toggle GUI visibility
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.LeftAlt then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
 
