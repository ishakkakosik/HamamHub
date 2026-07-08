-- [[ GUI LIBRARY LOAD ]]
local NullLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ginzuss/nullui/refs/heads/main/NullUI.lua"))()

local Window = NullLib:CreateWindow({
    Name = "GithubProject",
    Title = "Github Project",
    Subtitle = "by Fluxx",
    BadgeText = "v2.9",
    Icon = "https://i.postimg.cc/QxPqrLGq/image-Photoroom.png",
    WatermarkIcon = "https://i.postimg.cc/QxPqrLGq/image-Photoroom.png",
    ToggleKey = Enum.KeyCode.LeftControl,
    ConfigFolder = "NullUI_MM2",
    ConfigName = "Default",
    TabPosition = "Bottom",
    ShowTabTitle = true,
    WelcomeNotification = true
})

-- Forward declaration of local functions to avoid scope issues
local updateXrayTransparency
local disableXray
local setTime
local saveSettings
local loadSettings
local equipGun
local shootMurdererOnce
local shootAtCursor
local fireShot
local findRemote
local getGunFiredRemote
local updateRadio
local addTextboxToSection
local localDupeItem
local playDupeAnimation
local updateDropdownValues
local updateWeaponsList

-- [[ VARIABLES AND SYNCHRONIZATION TABLES ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local scriptRunning = true
local espEnabled = false
local gunEspEnabled = false
local autoPickupEnabled = false
local noclipEnabled = false
local antiFlingEnabled = false
local walkSpeedValue = 16
local jumpPowerValue = 50
local MAX_DISTANCE = 500

-- ESP Colors definition to prevent nil indexing errors
local COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Innocent = Color3.fromRGB(0, 255, 0)
}

-- Fly & Infinite Jump & Spin Bot variables
local flyEnabled = false
local flySpeedValue = 50
local infiniteJumpEnabled = false
local spinBotEnabled = false
local spinBotSpeed = 100

-- Visual Radio variables
local radioSoundId = "5410086218"
local radioVolume = 0.5
local radioPlaying = false
local radioSoundObject = nil

-- Duplication configuration and dynamic states
local dupeWeaponType = "Knife"
local dupeRarity = "Godly"
local dupeWeaponName = "Luger"
local dupeQuantity = 1
local weaponNameDropdown

-- [[ MM2VALUES.COM COMPLETE RARITY DATABASE ]]
local MM2_ITEMS_DB = {
    Common = {
        Knife = {
            "Default Knife", "Prismatic", "Combat", "Leaf", "Clover", "Splat", "Imbued", "Shiny", "Checker", "Sketch", "Cane", "Gingerbread", "Snowman", "Nutcracker", "Holly", "Elf", "Denis", "Alex", "Sub", "Corl", "Sketchy", "Bacon"
        },
        Gun = {
            "Default Gun", "Clown", "High Tech", "Blue", "Green", "Red", "Yellow", "Orange", "Purple", "Pink", "Sandy", "Wave", "Balloons"
        },
        Pet = {
            "Default Pet", "Dog", "Cat", "Pumpkin", "Pig", "Fox", "Cow"
        }
    },
    Uncommon = {
        Knife = {
            "Bronze", "Chips", "Envy", "Checker", "Bluesteel", "Adurite", "Tree", "Wanwood", "Stalker", "Missing", "Cheesy", "Circuit", "Doge", "Paper", "Hazmat", "Melon", "Hive", "Brush", "Jelly_sh", "Turtle"
        },
        Gun = {
            "Bluesteel", "Adurite", "Circuit", "Paper", "Melon", "Hive", "Popsicle"
        },
        Pet = {
            "Bear", "Reindeer", "Snowman Pet", "Elf Pet"
        }
    },
    Rare = {
        Knife = {
            "Cane Knife 2018", "Dungeon Knife 2019", "Darkknife", "Silent Night Knife 2020", "Makeshift Knife 2022", "Zombified Knife 2022", "Swirl Knife 2021", "Aurora Knife 2019", "Floral Knife", "Rainbow Fire", "Deep Sea", "Galaxy", "Spectrum", "Krypto", "Nova", "Vortex"
        },
        Gun = {
            "Silent Night Gun 2020", "Magma Gun 2021", "Watcher Gun 2021", "Starry Gun 2021", "Nightfire", "Rainbow Gun", "Aurora Gun 2019", "Floral Gun"
        },
        Pet = {
            "Ghost Pet", "Pumpkin Pet", "Elite Pet"
        }
    },
    Legendary = {
        Knife = {
            "Latte Knife", "Spectral Knife", "Cotton Candy", "JD", "Beach Knife", "Cavern Knife", "Green Elite", "Ghost Knife", "Santas Spirit", "Witched", "Santas Magic", "Scratch", "Blue Elite", "Elite", "Shiny", "Fusion", "Fade", "Plasmite", "Rune", "Splash", "Overseer"
        },
        Gun = {
            "Latte Gun", "Traveler Gun", "Aurora Gun", "Vampire Gun", "Beach Gun", "Arctic Gun", "Broken", "Icedriller", "Universe", "Overseer Gun", "Predator Gun", "Viper", "Splash Gun"
        },
        Pet = {
            "Chroma Fire Dog", "Chroma Fire Cat", "Fire Bunny", "Fire Bat", "Fire Fox", "Fire Pig"
        }
    },
    Vintage = {
        Knife = {
            "Ghost", "Blood", "Laser", "Shadow", "Phaser", "Prince", "Golden", "Splitter"
        },
        Gun = {
            "America", "Cowboy"
        },
        Pet = {
            "None"
        }
    },
    Godly = {
        Knife = {
            "Evergreen", "Sakura", "Spirit", "Rainbow", "Bloom", "Heart Wand", "Waves", "Xenoknife", "Flowerwood Knife", "Sweet", "Australis", "Bat", "Pearl", "Candy", "Heartblade", "Candleflame", "Elderwood Blade", "Phantom", "Icebreaker", "Ice Wing", "Nightblade", "Heat", "Pixel", "Shark", "Slasher", "Deathshard", "Virtual"
        },
        Gun = {
            "Traveler's Gun", "Evergun", "Luger Cane", "Jinglegun", "Minty", "Gingermint", "Rainbow Gun", "Luger", "Green Luger", "Ornament", "Iceblaster", "Lightbringer", "Darkbringer", "Blaster"
        },
        Pet = {
            "Seer Pet", "Skelly", "Icey", "Ghosty", "Traveller", "DeathSpeaker"
        }
    },
    Ancient = {
        Knife = {
            "Niks Scythe", "Travelers Axe", "Celestial", "Vampires Axe", "Icebreaker", "Batwing", "Elderwood Scythe", "SwirlyAxe", "Hallowscythe", "Log Chopper", "Ice Wing"
        },
        Gun = {
            "Gingerscope", "Harvester", "Icepiercer"
        },
        Pet = {
            "None"
        }
    },
    Unique = {
        Knife = {
            "Corrupt", "Gold Gingerscythe", "Gold LogChopper", "Gold Minty", "Gold Vampires Edge", "Gold Candy", "Gold Hallows", "Gold Sugar", "Gold Icebreaker", "Gold Gingerscope", "Gold Harvester", "Gold Swirly Axe", "Gold Travelers Axe", "Gold Vampires Axe", "Gold Synthwave"
        },
        Gun = {
            "Sharkseeker", "Dartbringer", "Gold Iceblaster", "Gold Swirly Gun"
        },
        Pet = {
            "None"
        }
    },
    Chroma = {
        Knife = {
            "Chroma Evergreen", "Chroma Alienbeam", "Chroma Sunset", "Chroma Heart Wand", "Chroma Snow Dagger", "Chroma Snowstorm", "Chroma Treat", "Chroma Laser", "Chroma Candleflame", "Chroma Elderwood Blade", "Chroma Slasher", "Chroma DeathShard", "Chroma Tides", "Chroma Gemstone"
        },
        Gun = {
            "Chroma Travelers Gun", "Chroma Evergun", "Chroma Bauble", "Chroma Vampires Gun", "Chroma Constellation", "Chroma Raygun", "Chroma Sunrise", "Chroma Snowcannon", "Chroma Blizzard", "Chroma WaterGun", "Chroma Darkbringer", "Chroma Lightbringer", "Chroma Luger"
        },
        Pet = {
            "Chroma Fire Bunny", "Chroma Fire Bat", "Chroma Fire Fox"
        }
    }
}

-- Language translation tables
local currentLang = "RU"
local langData = {
    RU = {
        rejoin = "Переподключение к текущему игровому серверу.",
        configs = "Сохранение, загрузка и сброс настроек чита.",
        unload = "Полное отключение читов и удаление меню скрипта.",
        esp = "Отображение игроков сквозь стены по ролям и цветам.",
        xray = "Настройки прозрачности стен и ночного режима карты.",
        notifications = "Включение оповещений о шерифе, пистолете и ролях.",
        movement = "Изменение скорости, высоты прыжков, полета и спинбота.",
        radio_warn = "ВНИМАНИЕ: Слышать радио будете только вы (локальный звук).",
        radio_desc = "Воспроизведение музыки по Roblox Audio ID.",
        dupe_warn = "ВНИМАНИЕ: Оружие фантомное и будет видно только вам (локально).",
        dupe_desc = "Эмуляция оригинального открытия кейса с визуальным получением скина."
    },
    EN = {
        rejoin = "Reconnection to the current game server.",
        configs = "Saving, loading, and resetting cheat settings.",
        unload = "Fully disabling cheats and removing the script menu.",
        esp = "Highlighting players through walls by role and custom colors.",
        xray = "Wall transparency and night time mode configurations.",
        notifications = "Toggling notifications for sheriff, dropped gun, and roles.",
        movement = "Customizing walkspeed, jump height, flight, and spinbot.",
        radio_warn = "WARNING: Only you can hear this radio (client-side sound).",
        radio_desc = "Audio playback via Roblox ID.",
        dupe_warn = "WARNING: Items are phantom and visible only to you (client-side).",
        dupe_desc = "Simulate item unboxing with the game's native chest roll animation."
    }
}

local labelRejoin, labelConfigs, labelUnload, labelEsp, labelXray, labelNotifications, labelMovement, labelRadioWarn, labelRadioDesc, labelDupeWarn, labelDupeDesc

local function updateLanguageLabels()
    local t = langData[currentLang]
    pcall(function() if labelRejoin then labelRejoin:Set(t.rejoin) end end)
    pcall(function() if labelConfigs then labelConfigs:Set(t.configs) end end)
    pcall(function() if labelUnload then labelUnload:Set(t.unload) end end)
    pcall(function() if labelEsp then labelEsp:Set(t.esp) end end)
    pcall(function() if labelXray then labelXray:Set(t.xray) end end)
    pcall(function() if labelNotifications then labelNotifications:Set(t.notifications) end end)
    pcall(function() if labelMovement then labelMovement:Set(t.movement) end end)
    pcall(function() if labelRadioWarn then labelRadioWarn:Set(t.radio_warn) end end)
    pcall(function() if labelRadioDesc then labelRadioDesc:Set(t.radio_desc) end end)
    pcall(function() if labelDupeWarn then labelDupeWarn:Set(t.dupe_warn) end end)
    pcall(function() if labelDupeDesc then labelDupeDesc:Set(t.dupe_desc) end end)
end

-- Shoot Murderer variables
local shotType = "Default" -- "Default", "TP Bullet (Yoxi Hub)", "Teleport Player"
local forceTarget = nil
local forceHitPart = nil

-- Anti-AFK variable
local antiAfkEnabled = false

-- Notification Settings variables
local notifySheriffDeath = true
local notifyGunDrop = true
local notifyRoles = true
local notifyGunPickup = true

-- X-Ray & Lighting variables
local xrayEnabled = false
local xrayTransparency = 0.5
local originalTransparencies = setmetatable({}, { __mode = "k" }) 
local forceNightEnabled = false

-- Table to save original map lighting
local originalLighting = {
    ClockTime = 14,
    Brightness = 1,
    OutdoorAmbient = Color3.fromRGB(128, 128, 128),
    Ambient = Color3.fromRGB(128, 128, 128)
}
local savedLighting = false

-- Tables for managing HUD and shader colors
local toggles = {}
local hudStrokes = {}
local hudGlowColor = Color3.fromRGB(0, 255, 200)

-- Config file path
local CONFIG_FILE = "NullUI_MM2_Config.json"

-- Safe file utility functions
local function safeWriteFile(path, content)
    if writefile then
        pcall(writefile, path, content)
    end
end

local function safeReadFile(path)
    if readfile and isfile and isfile(path) then
        local success, result = pcall(readfile, path)
        if success then return result end
    end
    return nil
end

-- [[ HELPER FUNCTION TO FIND GUN PART ]]
local function getGunPart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("Part") or obj:FindFirstChildOfClass("MeshPart")
    if handle then return handle end
    return obj:FindFirstChildOfClass("BasePart", true)
end

-- [[ SHADER / GLOW APPLICATION FUNCTION ]]
local function applyShaders(frame, stroke)
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 28, 28))
    })
    bgGradient.Rotation = 45
    bgGradient.Parent = frame

    if stroke then
        local strokeGradient = Instance.new("UIGradient")
        strokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, hudGlowColor),
            ColorSequenceKeypoint.new(1, hudGlowColor:lerp(Color3.fromRGB(0, 0, 0), 0.5))
        })
        strokeGradient.Parent = stroke
    end
end

-- [[ SMART SELF-HEALING DROPDOWN UPDATER ]]
updateDropdownValues = function(dropdown, values)
    if not dropdown then return end
    local methods = {"Refresh", "refresh", "Update", "update", "UpdateDropdown", "SetValues", "setValues", "SetChoices"}
    local chosenMethod = nil
    
    for _, method in ipairs(methods) do
        if type(dropdown[method]) == "function" then
            chosenMethod = method
            break
        end
    end
    
    if not chosenMethod then
        for k, v in pairs(dropdown) do
            if type(v) == "function" then
                local lk = k:lower()
                if lk:find("refresh") or lk:find("update") or lk:find("choice") or lk:find("value") or lk:find("list") then
                    chosenMethod = k
                    break
                end
            end
        end
    end
    
    if chosenMethod then
        pcall(function()
            dropdown[chosenMethod](dropdown, values, true)
        end)
        pcall(function()
            dropdown[chosenMethod](dropdown, values)
        end)
    end
end

updateWeaponsList = function()
    local list = MM2_ITEMS_DB[dupeRarity] and MM2_ITEMS_DB[dupeRarity][dupeWeaponType]
    if not list then
        list = {"None"}
    end
    updateDropdownValues(weaponNameDropdown, list)
    dupeWeaponName = list[1] or "Luger"
end

-- [[ SMART SELF-HEALING TEXTBOX METHOD LOCATOR ]]
addTextboxToSection = function(section, config)
    local methods = {"AddTextbox", "AddTextBox", "AddInput", "AddBox", "AddTextInput"}
    local chosenMethod = nil
    
    for _, method in ipairs(methods) do
        if type(section[method]) == "function" then
            chosenMethod = method
            break
        end
    end
    
    if not chosenMethod then
        for k, v in pairs(section) do
            if type(v) == "function" then
                local lk = k:lower()
                if lk:find("box") or lk:find("input") or lk:find("text") then
                    chosenMethod = k
                    break
                end
            end
        end
    end
    
    if chosenMethod then
        return section[chosenMethod](section, {
            Name = config.Text or config.Name,
            Text = config.Text or config.Name,
            Default = config.Default,
            TextDisappear = config.TextDisappear or false,
            Callback = config.Callback
        })
    else
        pcall(function()
            if type(section.AddLabel) == "function" then
                section:AddLabel("Error: Textbox method not found")
            end
        end)
        return nil
    end
end

-- [[ CUSTOM TOP NOTIFICATION CONTAINER ]]
local NotificationGui
local success, err = pcall(function()
    NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "NullUI_Notifications"
    NotificationGui.ResetOnSpawn = false
    NotificationGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not success then
    NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "NullUI_Notifications"
    NotificationGui.ResetOnSpawn = false
    NotificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "Container"
NotificationContainer.Size = UDim2.new(0, 300, 0, 500)
NotificationContainer.Position = UDim2.new(0.5, -150, 0, 50) 
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = NotificationGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = NotificationContainer

local function showCustomNotification(title, text, duration)
    duration = duration or 4
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1 

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 1
    stroke.Parent = frame

    applyShaders(frame, stroke)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.TextTransparency = 1
    titleLabel.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 20)
    textLabel.Position = UDim2.new(0, 10, 0, 26)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 11
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Text = text
    textLabel.TextTransparency = 1
    textLabel.Parent = frame

    frame.Parent = NotificationContainer

    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(frame, info, {BackgroundTransparency = 0.15}):Play()
    TweenService:Create(stroke, info, {Transparency = 0}):Play()
    TweenService:Create(titleLabel, info, {TextTransparency = 0}):Play()
    TweenService:Create(textLabel, info, {TextTransparency = 0}):Play()

    task.wait(duration)

    if not frame or not frame.Parent then return end
    local fadeOut = TweenService:Create(frame, info, {BackgroundTransparency = 1})
    TweenService:Create(stroke, info, {Transparency = 1}):Play()
    TweenService:Create(titleLabel, info, {TextTransparency = 1}):Play()
    TweenService:Create(textLabel, info, {TextTransparency = 1}):Play()
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        frame:Destroy()
    end)
end

local function sendNotification(title, text, duration)
    task.spawn(function()
        showCustomNotification(title, text, duration)
    end)
end

-- [[ DRAG HANDLE FUNCTION ]]
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
end

-- [[ MAIN HORIZONTAL HUD BAR ]]
local hudFrame = Instance.new("Frame")
hudFrame.Name = "MainHUD_Bar"
hudFrame.Size = UDim2.new(0, 420, 0, 32)
hudFrame.Position = UDim2.new(0.5, -210, 0, 10) 
hudFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
hudFrame.BackgroundTransparency = 0.15
hudFrame.BorderSizePixel = 0
hudFrame.Visible = false 
hudFrame.Parent = NotificationGui

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 8)
hudCorner.Parent = hudFrame

local hudStroke = Instance.new("UIStroke")
hudStroke.Color = Color3.fromRGB(255, 255, 255)
hudStroke.Thickness = 1.5
hudStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
hudStroke.Parent = hudFrame

table.insert(hudStrokes, hudStroke)
applyShaders(hudFrame, hudStroke)
makeDraggable(hudFrame)

local hudText = Instance.new("TextLabel")
hudText.Size = UDim2.new(1, 0, 1, 0)
hudText.BackgroundTransparency = 1
hudText.TextColor3 = Color3.fromRGB(240, 240, 240)
hudText.Font = Enum.Font.GothamMedium
hudText.TextSize = 11
hudText.Text = "User: --  |  FPS: --  |  Players: --"
hudText.Parent = hudFrame

-- [[ ACTIVE FEATURES SIDE HUD PANEL ]]
local featuresFrame = Instance.new("Frame")
featuresFrame.Name = "FeaturesHUD_Panel"
featuresFrame.Size = UDim2.new(0, 180, 0, 180)
featuresFrame.Position = UDim2.new(0, 15, 0.45, 0) 
featuresFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
featuresFrame.BackgroundTransparency = 0.15
featuresFrame.BorderSizePixel = 0
featuresFrame.Visible = false 
featuresFrame.Parent = NotificationGui

local featCorner = Instance.new("UICorner")
featCorner.CornerRadius = UDim.new(0, 8)
featCorner.Parent = featuresFrame

local featStroke = Instance.new("UIStroke")
featStroke.Color = Color3.fromRGB(255, 255, 255)
featStroke.Thickness = 1.5
featStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
featStroke.Parent = featuresFrame

table.insert(hudStrokes, featStroke)
applyShaders(featuresFrame, featStroke)
makeDraggable(featuresFrame)

local featHeader = Instance.new("TextLabel")
featHeader.Size = UDim2.new(1, -20, 0, 25)
featHeader.Position = UDim2.new(0, 10, 0, 5)
featHeader.BackgroundTransparency = 1
featHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
featHeader.Font = Enum.Font.GothamBold
featHeader.TextSize = 11
featHeader.TextXAlignment = Enum.TextXAlignment.Left
featHeader.Text = "ACTIVE FEATURES"
featHeader.Parent = featuresFrame

local featDivider = Instance.new("Frame")
featDivider.Size = UDim2.new(1, -20, 0, 1)
featDivider.Position = UDim2.new(0, 10, 0, 30)
featDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
featDivider.BorderSizePixel = 0
featDivider.Parent = featuresFrame

local dividerGradient = Instance.new("UIGradient")
dividerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, hudGlowColor),
    ColorSequenceKeypoint.new(0.5, hudGlowColor:lerp(Color3.fromRGB(0,0,0), 0.5)),
    ColorSequenceKeypoint.new(1, hudGlowColor)
})
dividerGradient.Parent = featDivider

local activeLabel = Instance.new("TextLabel")
activeLabel.Size = UDim2.new(1, -20, 0, 130)
activeLabel.Position = UDim2.new(0, 10, 0, 40)
activeLabel.BackgroundTransparency = 1
activeLabel.TextColor3 = Color3.fromRGB(0, 255, 120) 
activeLabel.Font = Enum.Font.GothamMedium
activeLabel.TextSize = 11
activeLabel.TextXAlignment = Enum.TextXAlignment.Left
activeLabel.TextYAlignment = Enum.TextYAlignment.Top
activeLabel.Text = "• None"
activeLabel.LineHeight = 1.2
activeLabel.Parent = featuresFrame

-- [[ ROUND INFO HUD PANEL ]]
local mm2InfoFrame = Instance.new("Frame")
mm2InfoFrame.Name = "MM2InfoHUD_Panel"
mm2InfoFrame.Size = UDim2.new(0, 200, 0, 100)
mm2InfoFrame.Position = UDim2.new(0, 15, 0.2, 0) 
mm2InfoFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mm2InfoFrame.BackgroundTransparency = 0.15
mm2InfoFrame.BorderSizePixel = 0
mm2InfoFrame.Visible = false 
mm2InfoFrame.Parent = NotificationGui

local mm2Corner = Instance.new("UICorner")
mm2Corner.CornerRadius = UDim.new(0, 8)
mm2Corner.Parent = mm2InfoFrame

local mm2Stroke = Instance.new("UIStroke")
mm2Stroke.Color = Color3.fromRGB(255, 255, 255)
mm2Stroke.Thickness = 1.5
mm2Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mm2Stroke.Parent = mm2InfoFrame

table.insert(hudStrokes, mm2Stroke)
applyShaders(mm2InfoFrame, mm2Stroke)
makeDraggable(mm2InfoFrame)

local mm2Header = Instance.new("TextLabel")
mm2Header.Size = UDim2.new(1, -20, 0, 25)
mm2Header.Position = UDim2.new(0, 10, 0, 5)
mm2Header.BackgroundTransparency = 1
mm2Header.TextColor3 = Color3.fromRGB(255, 255, 255)
mm2Header.Font = Enum.Font.GothamBold
mm2Header.TextSize = 11
mm2Header.TextXAlignment = Enum.TextXAlignment.Left
mm2Header.Text = "ROUND INFO"
mm2Header.Parent = mm2InfoFrame

local mm2Divider = Instance.new("Frame")
mm2Divider.Size = UDim2.new(1, -20, 0, 1)
mm2Divider.Position = UDim2.new(0, 10, 0, 30)
mm2Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mm2Divider.BorderSizePixel = 0
mm2Divider.Parent = mm2InfoFrame

local divGrad = Instance.new("UIGradient")
divGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, hudGlowColor),
    ColorSequenceKeypoint.new(0.5, hudGlowColor:lerp(Color3.fromRGB(0,0,0), 0.5)),
    ColorSequenceKeypoint.new(1, hudGlowColor)
})
divGrad.Parent = mm2Divider

local mm2SheriffLabel = Instance.new("TextLabel")
mm2SheriffLabel.Size = UDim2.new(1, -20, 0, 20)
mm2SheriffLabel.Position = UDim2.new(0, 10, 0, 40)
mm2SheriffLabel.BackgroundTransparency = 1
mm2SheriffLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
mm2SheriffLabel.Font = Enum.Font.GothamMedium
mm2SheriffLabel.TextSize = 11
mm2SheriffLabel.TextXAlignment = Enum.TextXAlignment.Left
mm2SheriffLabel.Text = "Sheriff: None"
mm2SheriffLabel.Parent = mm2InfoFrame

local mm2GunLabel = Instance.new("TextLabel")
mm2GunLabel.Size = UDim2.new(1, -20, 0, 20)
mm2GunLabel.Position = UDim2.new(0, 10, 0, 65)
mm2GunLabel.BackgroundTransparency = 1
mm2GunLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
mm2GunLabel.Font = Enum.Font.GothamMedium
mm2GunLabel.TextSize = 11
mm2GunLabel.TextXAlignment = Enum.TextXAlignment.Left
mm2GunLabel.Text = "Gun: None"
mm2GunLabel.Parent = mm2InfoFrame

-- [[ HUD DYNAMIC GLOW UPDATE ]]
local function updateHudGlowColor(color)
    hudGlowColor = color
    for _, stroke in ipairs(hudStrokes) do
        if stroke and stroke.Parent then
            stroke.Color = color
            local grad = stroke:FindFirstChildOfClass("UIGradient")
            if grad then
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, color),
                    ColorSequenceKeypoint.new(1, color:lerp(Color3.fromRGB(0, 0, 0), 0.5))
                })
            end
        end
    end
    pcall(function()
        dividerGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(0.5, color:lerp(Color3.fromRGB(0,0,0), 0.5)),
            ColorSequenceKeypoint.new(1, color)
        })
        divGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(0.5, color:lerp(Color3.fromRGB(0,0,0), 0.5)),
            ColorSequenceKeypoint.new(1, color)
        })
    end)
end

-- [[ TOGGLE VISUAL STATE UPDATER ]]
local function updateToggleVisual(toggleObject, state)
    if not toggleObject then return end
    pcall(function()
        if toggleObject.Set then
            toggleObject:Set(state)
        elseif toggleObject.SetState then
            toggleObject:SetState(state)
        elseif toggleObject.UpdateToggle then
            toggleObject:UpdateToggle(state)
        end
    end)
end

-- [[ DISABLE FLY PHYSICS ]]
local function disableFly()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate = true
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp) 
        end)
    end
    
    if root then
        local bv = root:FindFirstChild("FlyVelocity")
        if bv then bv:Destroy() end
        local bg = root:FindFirstChild("FlyGyro")
        if bg then bg:Destroy() end
        root.Anchored = false
    end
end

-- [[ CONSOLIDATED FEATURE STATE CONTROLLER ]]
local updatingToggle = false
local function setFeatureState(name, state)
    if updatingToggle then return end 
    
    if name == "AutoPickup" then
        autoPickupEnabled = state
    elseif name == "ESP" then
        espEnabled = state
    elseif name == "Xray" then
        xrayEnabled = state
        if state then updateXrayTransparency() else disableXray() end
    elseif name == "NoClip" then
        noclipEnabled = state
        if not state then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    elseif name == "AntiFling" then
        antiFlingEnabled = state
        if not state then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local targetChar = player.Character
                    if targetChar then
                        for _, part in ipairs(targetChar:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = true
                            end
                        end
                    end
                end
            end
        end
    elseif name == "ForceNight" then
        setTime(state)
    elseif name == "Fly" then
        flyEnabled = state
        if not state then disableFly() end
    elseif name == "InfJump" then
        infiniteJumpEnabled = state
    elseif name == "AntiAfk" then
        antiAfkEnabled = state
    elseif name == "SpinBot" then
        spinBotEnabled = state
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if not state then
            if root then
                local bav = root:FindFirstChild("SpinBotVelocity")
                if bav then bav:Destroy() end
            end
            if hum then
                hum.AutoRotate = true
            end
            if char and not noclipEnabled then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                if root then root.CanCollide = true end
            end
        end
    end

    if toggles[name] then
        updatingToggle = true
        updateToggleVisual(toggles[name], state)
        updatingToggle = false
    end
end

-- [[ VISUAL LOCAL RADIO HANDLER ]]
updateRadio = function()
    if radioSoundObject then
        radioSoundObject:Stop()
        radioSoundObject:Destroy()
        radioSoundObject = nil
    end
    
    if radioPlaying then
        local Camera = Workspace.CurrentCamera
        local parent = Camera or LocalPlayer:FindFirstChildOfClass("PlayerGui") or game:GetService("SoundService")
        
        radioSoundObject = Instance.new("Sound")
        radioSoundObject.Name = "NullUI_VisualRadio"
        
        local cleanId = tostring(radioSoundId):gsub("%D", "")
        radioSoundObject.SoundId = "rbxassetid://" .. cleanId
        radioSoundObject.Volume = radioVolume
        radioSoundObject.Looped = true
        radioSoundObject.Parent = parent
        radioSoundObject:Play()
        
        sendNotification("Radio System", "Playing Audio ID: " .. cleanId, 3)
    end
end

-- [[ HELPER TO MATCH WEAPON DISPLAY NAME TO ACTUAL SYSTEM KEYS IN DB ]]
local function getDatabaseItemName(displayName, category)
    local db = nil
    pcall(function()
        db = require(game:GetService("ReplicatedStorage").Database.Sync)
    end)
    if not db then return displayName end
    
    local catTable = db[category]
    if not catTable then return displayName end
    
    -- Strip spaces, punctuation, and transform to lowercase for clean matching
    local targetName = displayName:lower():gsub("[%p%s]", "")
    
    -- Try to find exact case-insensitive matches with stripped keys
    for k, _ in pairs(catTable) do
        local dbKey = tostring(k):lower():gsub("[%p%s]", "")
        if dbKey == targetName then
            return k
        end
    end
    
    -- Partial substring fallbacks
    for k, _ in pairs(catTable) do
        local dbKey = tostring(k):lower():gsub("[%p%s]", "")
        if dbKey:find(targetName) or targetName:find(dbKey) then
            return k
        end
    end
    
    return displayName
end

-- [[ LOCAL NATIVE DUPLICATOR AND NATIVE ANIMATION HANDLER ]]
localDupeItem = function(itemName, weaponType, quantity)
    return true
end

playDupeAnimation = function(itemName, rarity, weaponType, quantity)
    -- Resolve Database category based on type
    local dbCategory = "Weapons"
    if weaponType == "Pet" then
        dbCategory = "Pets"
    elseif weaponType == "Radio" then
        dbCategory = "Radios"
    end

    -- Automatically find the exact internal database name
    local exactItemName = getDatabaseItemName(itemName, dbCategory)

    -- 1. Try to play the native MM2 unboxing carousel roll animation on the client
    pcall(function()
        local BoxModuleObj = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("BoxModule")
        if BoxModuleObj then
            local Unboxing = BoxModuleObj:FindFirstChild("Unboxing") or BoxModuleObj:FindFirstChild("Unboxing2")
            if Unboxing then
                local boxName = "StandardBox"
                -- Dynamically check which mystery crates exist in MM2
                local boxModuleData = require(BoxModuleObj)
                if boxModuleData and type(boxModuleData) == "table" then
                    local boxes = {}
                    for k, _ in pairs(boxModuleData) do
                        if type(k) == "string" then
                            table.insert(boxes, k)
                        end
                    end
                    if #boxes > 0 then
                        boxName = boxes[math.random(1, #boxes)]
                    end
                end
                
                local unboxFunc = require(Unboxing)
                if type(unboxFunc) == "function" then
                    task.spawn(function()
                        pcall(function() unboxFunc(exactItemName) end)
                        pcall(function() unboxFunc(boxName, exactItemName) end)
                    end)
                end
            end
        end
    end)

    -- 2. Local Signal Injector to register the item inside the MM2 Inventory GUI
    task.spawn(function()
        task.wait(0.4) -- Sync delay with unboxing wheel
        
        local added = false

        -- [METHOD A: FIRE CLIENT-SIDE REMOTE SIGNAL TO FORCE INVENTORY SYNC]
        if firesignal then
            pcall(function()
                local syncEvent = ReplicatedStorage:FindFirstChild("Remotes") 
                    and ReplicatedStorage.Remotes:FindFirstChild("Inventory") 
                    and ReplicatedStorage.Remotes.Inventory:FindFirstChild("ChangeInventoryItem")
                
                if syncEvent and syncEvent:IsA("RemoteEvent") then
                    firesignal(syncEvent.OnClientEvent, dbCategory, exactItemName, quantity or 1)
                    added = true
                end
            end)
        end

        -- [METHOD B: CRATE SCRIPT ENVIRONMENT CALL BACKUP]
        if not added and getsenv then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local mainGui = playerGui and (playerGui:FindFirstChild("MainGui") or playerGui:FindFirstChild("MainGUI"))
                local unboxScript = mainGui and mainGui:FindFirstChild("Shop", true) and mainGui.Shop:FindFirstChild("Unbox", true)
                
                if unboxScript then
                    local success, env = pcall(getsenv, unboxScript)
                    if success and env then
                        if env._G and env._G.NewItem then
                            pcall(function() env._G.NewItem(exactItemName, nil, nil, dbCategory, quantity or 1) end)
                            added = true
                        elseif env.NewItem then
                            pcall(function() env.NewItem(exactItemName, nil, nil, dbCategory, quantity or 1) end)
                            added = true
                        end
                    end
                end
            end)
        end

        -- [METHOD C: GLOBAL GAME STATE BACKUP]
        if not added and _G.NewItem then
            pcall(function() _G.NewItem(exactItemName, nil, nil, dbCategory, quantity or 1) end)
        end
        
        sendNotification("Dupe System", "Added " .. tostring(exactItemName) .. "! Switch tabs or reopen inventory to refresh.", 5)
    end)
end

-- [[ FPS MEASUREMENT & HUD DATA REFRESH ]]
local fps = 0
local lastTime = os.clock()
local frameCount = 0
local fpsConnection
fpsConnection = RS.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = os.clock()
    if currentTime - lastTime >= 1 then
        fps = frameCount
        frameCount = 0
        lastTime = currentTime
    end
end)

task.spawn(function()
    while scriptRunning do
        task.wait(0.2)
        local userName = LocalPlayer.DisplayName
        hudText.Text = string.format("User: %s  |  FPS: %d  |  Players: %d", userName, fps, #Players:GetPlayers())
        
        local activeList = {}
        if autoPickupEnabled then table.insert(activeList, "• Auto Pickup") end
        if espEnabled then table.insert(activeList, "• Player ESP") end
        if xrayEnabled then table.insert(activeList, "• X-Ray") end
        if noclipEnabled then table.insert(activeList, "• NoClip") end
        if antiFlingEnabled then table.insert(activeList, "• Anti-Fling") end
        if forceNightEnabled then table.insert(activeList, "• Force Night") end
        if flyEnabled then table.insert(activeList, "• Fly Mode") end
        if infiniteJumpEnabled then table.insert(activeList, "• Infinite Jump") end
        if antiAfkEnabled then table.insert(activeList, "• Anti-AFK") end
        if spinBotEnabled then table.insert(activeList, "• Spin Bot") end
        if radioPlaying then table.insert(activeList, "• Visual Radio") end
        
        if #activeList == 0 then
            activeLabel.Text = "• None"
            activeLabel.TextColor3 = Color3.fromRGB(120, 120, 120) 
        else
            activeLabel.Text = table.concat(activeList, "\n")
            activeLabel.TextColor3 = Color3.fromRGB(0, 255, 120) 
        end
    end
end)

-- [[ LIGHTING ENGINE (DAY/NIGHT) OVERRIDE ]]
local function saveOriginalLighting()
    if savedLighting then return end
    savedLighting = true
    local lighting = game:GetService("Lighting")
    originalLighting.ClockTime = lighting.ClockTime
    originalLighting.Brightness = lighting.Brightness
    originalLighting.OutdoorAmbient = lighting.OutdoorAmbient
    originalLighting.Ambient = lighting.Ambient
end

-- Restores original settings when night mode is disabled
local function restoreOriginalLighting()
    if not savedLighting then return end
    savedLighting = false
    local lighting = game:GetService("Lighting")
    lighting.ClockTime = originalLighting.ClockTime
    lighting.Brightness = originalLighting.Brightness
    lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    lighting.Ambient = originalLighting.Ambient
end

setTime = function(state)
    forceNightEnabled = state
    if not forceNightEnabled then
        restoreOriginalLighting()
    end
end

local renderSteppedConnection
renderSteppedConnection = RS.RenderStepped:Connect(function()
    if forceNightEnabled then
        saveOriginalLighting()
        local lighting = game:GetService("Lighting")
        lighting.ClockTime = 0
        lighting.Brightness = 0
        lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 20) 
        lighting.Ambient = Color3.fromRGB(10, 10, 20)
    end
end)

-- [[ X-RAY LOGIC WITH LAYER EXCLUSIONS ]]
local function isPlayerPart(part)
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char and part:IsDescendantOf(char) then
            return true
        end
    end
    return false
end

local function shouldSkipPart(part)
    local name = part.Name:lower()
    if name:find("floor") or name:find("baseplate") or name:find("ground") or name:find("spawn") or name:find("plate") or name:find("bottom") or name:find("road") then
        return true
    end
    return false
end

local function applyXrayToPart(part)
    if not part:IsA("BasePart") then return end
    if isPlayerPart(part) then return end
    if part:IsDescendantOf(Workspace.CurrentCamera) then return end
    if shouldSkipPart(part) then return end 
    
    if originalTransparencies[part] == nil then
        originalTransparencies[part] = {
            Transparency = part.Transparency,
            Textures = {}
        }
    end
    part.Transparency = xrayTransparency
    
    for _, child in ipairs(part:GetDescendants()) do
        if child:IsA("Decal") or child:IsA("Texture") then
            if originalTransparencies[part].Textures[child] == nil then
                originalTransparencies[part].Textures[child] = child.Transparency
            end
            child.Transparency = xrayTransparency
        end
    end
end

updateXrayTransparency = function()
    if not xrayEnabled then return end
    task.spawn(function()
        local descendants = Workspace:GetDescendants()
        for i, part in ipairs(descendants) do
            if not xrayEnabled then break end
            applyXrayToPart(part)
            if i % 150 == 0 then
                task.wait() 
            end
        end
    end)
end

disableXray = function()
    for part, data in pairs(originalTransparencies) do
        if part then
            pcall(function()
                part.Transparency = data.Transparency
                for texture, origTrans in pairs(data.Textures) do
                    if texture then
                        texture.Transparency = origTrans
                    end
                end
            end)
        end
    end
    table.clear(originalTransparencies)
end

local descendantAddedConnection
descendantAddedConnection = Workspace.DescendantAdded:Connect(function(descendant)
    if xrayEnabled and descendant:IsA("BasePart") then
        RS.Heartbeat:Wait()
        if xrayEnabled and descendant.Parent then
            applyXrayToPart(descendant)
        end
    end
end)

-- [[ AUTO-PICKUP VIA FIRETOUCHINTEREST & TELEPORT ]]
local lastPickupAttempt = 0

local function attemptPickup(obj)
    if not autoPickupEnabled or not scriptRunning then return end
    if tick() - lastPickupAttempt < 1.5 then return end 
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end
    
    local touchPart = getGunPart(obj)
    if not touchPart then return end
    
    lastPickupAttempt = tick()
    
    if firetouchinterest then
        firetouchinterest(root, touchPart, 0)
        task.wait()
        firetouchinterest(root, touchPart, 1)
    else
        local targetPos = touchPart.CFrame
        local oldCFrame = root.CFrame
        
        root.CFrame = targetPos
        task.wait(0.1)
        
        local GameplayRemotes = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("Gameplay", 5)
        local FakeGunRemote = GameplayRemotes and GameplayRemotes:FindFirstChild("FakeGun")
        local GiveWeaponRemote = GameplayRemotes and GameplayRemotes:FindFirstChild("GiveWeapon")
        
        if FakeGunRemote then FakeGunRemote:FireServer() end
        if GiveWeaponRemote then GiveWeaponRemote:FireServer() end
        
        task.wait(0.1)
        if root and root.Parent then
            root.CFrame = oldCFrame
        end
    end
end

task.spawn(function()
    while scriptRunning do
        task.wait(0.3) 
        if autoPickupEnabled then
            local gun = Workspace:FindFirstChild("GunDrop", true)
            if gun then
                attemptPickup(gun)
            end
        end
    end
end)

-- [[ ESP LOGIC ]]
local function getPlayerRole(player)
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    
    local function hasKnife(parent)
        if not parent then return false end
        for _, item in ipairs(parent:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("knife") or item.Name:lower():find("blade") or item.Name:lower():find("slash")) then
                return true
            end
        end
        return false
    end
    
    local function hasGun(parent)
        if not parent then return false end
        for _, item in ipairs(parent:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("revolver") or item.Name:lower():find("pistol")) then
                return true
            end
        end
        return false
    end

    if hasKnife(backpack) or hasKnife(char) then return "Murderer" end
    if hasGun(backpack) or hasGun(char) then return "Sheriff" end
    return "Innocent"
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        
        if char then
            local highlight = char:FindFirstChild("RoleESP")
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if head and root then
                local billboard = head:FindFirstChild("RoleNameESP")
                local textLabel = billboard and billboard:FindFirstChildOfClass("TextLabel")
                
                if espEnabled then
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local distance = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
                    
                    if distance <= MAX_DISTANCE then
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "RoleESP"
                            highlight.FillTransparency = 0.5
                            highlight.Parent = char
                        end
                        
                        if not billboard then
                            billboard = Instance.new("BillboardGui")
                            billboard.Name = "RoleNameESP"
                            billboard.Size = UDim2.new(0, 200, 0, 50)
                            billboard.AlwaysOnTop = true
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.Parent = head
                            
                            textLabel = Instance.new("TextLabel")
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.TextSize = 14
                            textLabel.Font = Enum.Font.GothamBold
                            textLabel.TextStrokeTransparency = 0
                            textLabel.Parent = billboard
                        end
                        
                        local role = getPlayerRole(player)
                        local color = COLORS[role] or COLORS.Innocent
                        
                        highlight.Enabled = true
                        highlight.FillColor = color
                        highlight.OutlineColor = color
                        
                        billboard.Enabled = true
                        textLabel.TextColor3 = color
                        textLabel.Text = string.format("%s (%s) [%dm]", player.DisplayName, role, distance)
                    else
                        if highlight then highlight:Destroy() end
                        if billboard then billboard:Destroy() end
                    end
                else
                    if highlight then highlight:Destroy() end
                    if billboard then billboard:Destroy() end
                end
            end
        else
            local oldHighlight = char and char:FindFirstChild("RoleESP")
            if oldHighlight then oldHighlight:Destroy() end
        end
    end
end

task.spawn(function()
    while scriptRunning do
        task.wait(0.25)
        pcall(updateESP)
    end
end)

-- [[ ROUND STATE TRACKING & SHERIFF MONITORING ]]
local currentSheriff = nil
local gunDroppedLastState = false

task.spawn(function()
    while scriptRunning do
        task.wait(0.3)
        local foundSheriff = nil
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            local hasGun = (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))
            if hasGun then
                foundSheriff = player
                break
            end
        end
        
        local gun = Workspace:FindFirstChild("GunDrop", true)
        
        if gun then
            if not gunDroppedLastState then
                gunDroppedLastState = true
                if notifyGunDrop then
                    sendNotification("MM2 Info", "The gun has dropped!", 5)
                end
            end
        else
            if not foundSheriff then
                gunDroppedLastState = false
            end
        end

        if foundSheriff and gunDroppedLastState then
            if notifyGunPickup then
                sendNotification("MM2 Info", foundSheriff.DisplayName .. " picked up the gun!", 5)
            end
            gunDroppedLastState = false
        end
        
        if foundSheriff then
            mm2SheriffLabel.Text = "Sheriff: " .. foundSheriff.DisplayName .. " (Alive)"
            mm2SheriffLabel.TextColor3 = Color3.fromRGB(0, 170, 255) 
            mm2GunLabel.Text = "Gun: Held by Sheriff"
            mm2GunLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        elseif gun then
            mm2SheriffLabel.Text = "Sheriff: Dead (Dropped!)"
            mm2SheriffLabel.TextColor3 = Color3.fromRGB(255, 0, 0) 
            
            local distText = "Dropped"
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local touchPart = getGunPart(gun)
                local gunPos = touchPart and touchPart.Position or gun:GetPivot().Position
                local distance = math.floor((gunPos - myRoot.Position).Magnitude)
                distText = "Dropped (" .. distance .. "m)"
            end
            mm2GunLabel.Text = "Gun: " .. distText
            mm2GunLabel.TextColor3 = Color3.fromRGB(0, 255, 120) 
        else
            mm2SheriffLabel.Text = "Sheriff: None"
            mm2SheriffLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
            mm2GunLabel.Text = "Gun: None"
            mm2GunLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        end

        if currentSheriff and not foundSheriff then
            if currentSheriff.Parent == Players then
                local char = currentSheriff.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not char or not hum or hum.Health <= 0 then
                    if notifySheriffDeath then
                        sendNotification("MM2 Info", "Sheriff (" .. currentSheriff.DisplayName .. ") died!", 5)
                    end
                end
            end
            currentSheriff = nil
        elseif foundSheriff and foundSheriff ~= currentSheriff then
            currentSheriff = foundSheriff
        end
    end
end)

-- [[ ROLE SNOOPER & NOTIFICATION RESET ]]
local notifiedRoles = {}
local function checkRoleNotifications()
    if not notifyRoles then return end
    
    local murdererFound = false
    local sheriffFound = false
    
    for _, player in ipairs(Players:GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        local char = player.Character
        
        local isMurderer = (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife"))
        local isSecretSecretSheriff = (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))
        
        if isMurderer then
            murdererFound = true
            if notifiedRoles[player] ~= "Murderer" then
                notifiedRoles[player] = "Murderer"
                sendNotification("MM2 Roles", player.DisplayName .. " — Murderer!", 5)
            end
        elseif isSecretSecretSheriff then
            sheriffFound = true
            if notifiedRoles[player] ~= "Sheriff" then
                notifiedRoles[player] = "Sheriff"
                sendNotification("MM2 Roles", player.DisplayName .. " — Sheriff!", 5)
            end
        end
    end
    
    if not murdererFound and not sheriffFound then
        table.clear(notifiedRoles)
    end
end

task.spawn(function()
    while scriptRunning do
        task.wait(0.5)
        pcall(checkRoleNotifications)
    end
end)

-- [[ REJOIN TO CURRENT INSTANCE / SERVER ]]
local function rejoinServer()
    local TeleportService = game:GetService("TeleportService")
    local success, err = pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
    if not success then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

-- [[ INF JUMP DETECTOR ]]
local jumpRequestConnection
jumpRequestConnection = UIS.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- [[ ANTI AFK BYPASS ]]
local idledConnection
idledConnection = LocalPlayer.Idled:Connect(function()
    if antiAfkEnabled then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- [[ CHARACTER MOVEMENT AND PHYSICS HANDLERS ]]
local steppedConnection
steppedConnection = RS.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        if not flyEnabled then
            if hum.WalkSpeed ~= walkSpeedValue then hum.WalkSpeed = walkSpeedValue end
            if hum.JumpPower ~= jumpPowerValue then hum.JumpPower = jumpPowerValue end
        end
    end
    
    -- Optimized Fly Mode
    if flyEnabled and root and hum then
        hum.PlatformStand = true 
        hum.AutoRotate = false   
        
        local bv = root:FindFirstChild("FlyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) 
            bv.Parent = root
        end
        
        local bg = root:FindFirstChild("FlyGyro")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name = "FlyGyro"
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.Parent = root
        end
        
        local camera = Workspace.CurrentCamera
        local dir = Vector3.new(0, 0, 0)
        
        if not UIS:GetFocusedTextBox() then
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        end
        
        if dir.Magnitude > 0 then
            bv.Velocity = dir.Unit * flySpeedValue
        else
            bv.Velocity = Vector3.new(0, 0, 0) 
        end
        
        bg.CFrame = camera.CFrame
    else
        if root then
            local bv = root:FindFirstChild("FlyVelocity")
            if bv then bv:Destroy() end
            local bg = root:FindFirstChild("FlyGyro")
            if bg then bg:Destroy() end
        end
    end
    
    -- NoClip / Spin Collision control
    if noclipEnabled or spinBotEnabled then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        if root then root.CanCollide = false end
    end
    
    -- Anti Fling Hook
    if antiFlingEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetChar = player.Character
                if targetChar then
                    for _, part in ipairs(targetChar:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end

    -- SpinBot Physics
    if root then
        local bav = root:FindFirstChild("SpinBotVelocity")
        if spinBotEnabled then
            if not bav then
                bav = Instance.new("BodyAngularVelocity")
                bav.Name = "SpinBotVelocity"
                bav.MaxTorque = Vector3.new(0, 9e9, 0)
                bav.AngularVelocity = Vector3.new(0, spinBotSpeed, 0)
                bav.Parent = root
            else
                bav.AngularVelocity = Vector3.new(0, spinBotSpeed, 0)
            end
            if hum then
                hum.AutoRotate = false
            end
        else
            if bav then
                bav:Destroy()
                if hum and not flyEnabled then
                    hum.AutoRotate = true
                end
            end
        end
    end
end)

-- [[ OPTIMIZED SAFE NATIVE REMOTE SCANNER ]]
findRemote = function(name)
    local success, result = pcall(function()
        local char = LocalPlayer.Character
        if char then
            local gun = char:FindFirstChild("Gun")
            if gun then
                local remote = gun:FindFirstChild(name, true) 
                if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                    return remote
                end
            end
        end

        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            local gun = backpack:FindFirstChild("Gun")
            if gun then
                local remote = gun:FindFirstChild(name, true) 
                if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                    return remote
                end
            end
        end

        local rep = game:GetService("ReplicatedStorage")
        local remote = rep:FindFirstChild(name, true)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            return remote
        end

        local wRemote = Workspace:FindFirstChild(name, true)
        if wRemote and (wRemote:IsA("RemoteEvent") or wRemote:IsA("RemoteFunction")) then
            return wRemote
        end
    end)
    
    if success and result then
        return result
    end
    return nil
end

getGunFiredRemote = function()
    local success, remote = pcall(function()
        return game:GetService("ReplicatedStorage").ClientServices.WeaponService.GunFired
    end)
    if success and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
        return remote
    end
    
    return findRemote("GunFired") or findRemote("ShootGun") or findRemote("Shoot")
end

-- [[ AUTO SHOOT MURDERER CORE LOGIC ]]
equipGun = function()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local gun = char:FindFirstChild("Gun")
    if gun then return gun end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local bGun = backpack and backpack:FindFirstChild("Gun")
    if bGun then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(bGun)
            local startTime = tick()
            while tick() - startTime < 1 do
                local equippedGun = char:FindFirstChild("Gun")
                if equippedGun then
                    return equippedGun
                end
                task.wait(0.05)
            end
        end
    end
    return char:FindFirstChild("Gun")
end

fireShot = function(gun, targetPart)
    if not targetPart or not gun then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    forceTarget = targetPart.Position
    forceHitPart = targetPart
    
    if shotType == "Teleport Player" then
        local oldCFrame = root.CFrame
        root.CFrame = targetPart.CFrame * CFrame.new(0, 4, 0)
        task.wait(0.12) 
        
        pcall(function()
            gun:Activate()
        end)
        
        task.wait(0.08)
        if root and root.Parent then
            root.CFrame = oldCFrame
        end
    else
        pcall(function()
            gun:Activate()
        end)
    end
    
    task.spawn(function()
        task.wait(0.25)
        forceTarget = nil
        forceHitPart = nil
    end)
end

shootMurdererOnce = function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local gun = equipGun()
    if not gun then
        sendNotification("Gun System", "You do not have the Gun in your Backpack!", 3)
        return
    end
    
    local handle = gun:FindFirstChild("Handle") or gun:FindFirstChildOfClass("Part") or gun:FindFirstChildOfClass("MeshPart")
    if not handle then
        sendNotification("Gun System", "Gun Handle not found!", 3)
        return
    end
    
    local gunFiredRemote = getGunFiredRemote()
    if not gunFiredRemote then
        sendNotification("Gun System", "GunFired / ShootGun Remote not found! Scan failed.", 3)
        return
    end
    
    local murderer = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getPlayerRole(p) == "Murderer" then
            local mChar = p.Character
            local mHum = mChar and mChar:FindFirstChildOfClass("Humanoid")
            if mChar and mHum and mHum.Health > 0 then
                murderer = p
                break
            end
        end
    end
    
    if murderer then
        local targetPart = murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            fireShot(gun, targetPart)
            sendNotification("Gun System", "Fired shot at the murderer!", 3)
        end
    else
        sendNotification("Gun System", "Murderer not found or dead!", 3)
    end
end

shootAtCursor = function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local gun = equipGun()
    if not gun then
        sendNotification("Gun System", "Equip the Gun manually first!", 3)
        return
    end
    
    local handle = gun:FindFirstChild("Handle") or gun:FindFirstChildOfClass("Part") or gun:FindFirstChildOfClass("MeshPart")
    if not handle then
        sendNotification("Gun System", "Gun Handle not found!", 3)
        return
    end
    
    local gunFiredRemote = getGunFiredRemote()
    if not gunFiredRemote then
        sendNotification("Gun System", "Remote not found!", 3)
        return
    end
    
    local mouse = LocalPlayer:GetMouse()
    local targetPos = mouse.Hit.Position
    local hitPart = mouse.Target or Workspace
    
    forceTarget = targetPos
    forceHitPart = hitPart
    
    pcall(function()
        gun:Activate()
    end)
    
    task.spawn(function()
        task.wait(0.2)
        forceTarget = nil
        forceHitPart = nil
    end)
    
    sendNotification("Gun System", "Fired shot at cursor!", 3)
end

-- [[ METATABLE HOOK BYPASS COUPLING ]]
local mouse = LocalPlayer:GetMouse()

local hasMouseHook = pcall(function()
    assert(hookmetamethod, "Legacy Metatable Hooking not supported.")
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and self == mouse then
            if key == "Hit" and forceTarget then
                return CFrame.new(forceTarget) 
            elseif key == "Target" and forceHitPart then
                return forceHitPart
            end
        end
        return oldIndex(self, key)
    end)
end)

if not hasMouseHook then
    sendNotification("Warning", "Mouse Hooking not supported by this injector.", 5)
end

local hasHooks = pcall(function()
    assert(hookfunction, "Your exploit does not support hookfunction.")
    
    local oldFireServer
    oldFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
        local args = {...}
        
        if typeof(self) == "Instance" and self:IsA("RemoteEvent") then
            if self.Name == "GunFired" then
                if forceTarget and forceHitPart then
                    args[1] = forceTarget 
                    
                    if shotType == "TP Bullet (Yoxi Hub)" then
                        args[2] = forceTarget + Vector3.new(0, 1, 0)
                    else
                        local char = LocalPlayer.Character
                        local head = char and char:FindFirstChild("Head")
                        args[2] = head and head.Position or forceTarget
                    end
                    
                    args[3] = forceHitPart 
                    
                    return oldFireServer(self, table.unpack(args))
                end
            elseif self.Name == "ShootGun" or self.Name == "Shoot" then
                if forceTarget then
                    args[1] = forceTarget
                    return oldFireServer(self, table.unpack(args))
                end
            end
        end
        return oldFireServer(self, ...)
    end)
end)

if not hasHooks then
    sendNotification("Warning", "Network Hook Bypass failed. Fallback activated.", 5)
    
    pcall(function()
        assert(hookmetamethod, "Legacy Hooking not supported.")
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if not checkcaller() and typeof(self) == "Instance" then
                if self:IsA("RemoteEvent") and self.Name == "GunFired" and method == "FireServer" then
                    if forceTarget and forceHitPart then
                        args[1] = forceTarget
                        
                        if shotType == "TP Bullet (Yoxi Hub)" then
                            args[2] = forceTarget + Vector3.new(0, 1, 0)
                        else
                            local char = LocalPlayer.Character
                            local head = char and char:FindFirstChild("Head")
                            args[2] = head and head.Position or forceTarget
                        end
                        
                        args[3] = forceHitPart
                        
                        return oldNamecall(self, table.unpack(args))
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end

task.spawn(function()
    task.wait(1)
    local foundRemote = getGunFiredRemote()
    if foundRemote then
        sendNotification("Debug Info", "Found remote at: " .. foundRemote:GetFullName(), 7)
    else
        sendNotification("Debug Info", "GunFired remote NOT found!", 7)
    end
end)

-- [[ CONFIGURATION PERSISTENCE LAYER ]]
saveSettings = function()
    local config = {
        autoPickupEnabled = autoPickupEnabled,
        espEnabled = espEnabled,
        xrayEnabled = xrayEnabled,
        xrayTransparency = xrayTransparency,
        forceNightEnabled = forceNightEnabled,
        walkSpeedValue = walkSpeedValue,
        jumpPowerValue = jumpPowerValue,
        noclipEnabled = noclipEnabled,
        antiFlingEnabled = antiFlingEnabled,
        MAX_DISTANCE = MAX_DISTANCE,
        
        flyEnabled = flyEnabled,
        flySpeedValue = flySpeedValue,
        infiniteJumpEnabled = infiniteJumpEnabled,
        spinBotEnabled = spinBotEnabled,
        spinBotSpeed = spinBotSpeed,
        
        radioSoundId = radioSoundId,
        radioVolume = radioVolume,
        radioPlaying = radioPlaying,
        
        shotType = shotType,
        antiAfkEnabled = antiAfkEnabled,
        
        notifySheriffDeath = notifySheriffDeath,
        notifyGunDrop = notifyGunDrop,
        notifyRoles = notifyRoles,
        notifyGunPickup = notifyGunPickup,
        
        hudVisible = hudFrame.Visible,
        featuresVisible = featuresFrame.Visible,
        mm2InfoVisible = mm2InfoFrame.Visible,
        hudGlowColor = {hudGlowColor.R, hudGlowColor.G, hudGlowColor.B}
    }
    
    local success, json = pcall(function()
        return HttpService:JSONEncode(config)
    end)
    
    if success then
        safeWriteFile(CONFIG_FILE, json)
        sendNotification("Config System", "Config saved successfully!", 3)
    else
        sendNotification("Config System", "Failed to encode settings!", 3)
    end
end

loadSettings = function()
    local json = safeReadFile(CONFIG_FILE)
    if not json then
        sendNotification("Config System", "Config file not found!", 3)
        return
    end
    
    local success, config = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    
    if success and config then
        if config.autoPickupEnabled ~= nil then setFeatureState("AutoPickup", config.autoPickupEnabled) end
        if config.espEnabled ~= nil then setFeatureState("ESP", config.espEnabled) end
        if config.xrayEnabled ~= nil then setFeatureState("Xray", config.xrayEnabled) end
        if config.xrayTransparency ~= nil then 
            xrayTransparency = config.xrayTransparency 
            updateXrayTransparency()
        end
        if config.forceNightEnabled ~= nil then setFeatureState("ForceNight", config.forceNightEnabled) end
        if config.walkSpeedValue ~= nil then walkSpeedValue = config.walkSpeedValue end
        if config.jumpPowerValue ~= nil then jumpPowerValue = config.jumpPowerValue end
        if config.noclipEnabled ~= nil then setFeatureState("NoClip", config.noclipEnabled) end
        if config.antiFlingEnabled ~= nil then setFeatureState("AntiFling", config.antiFlingEnabled) end
        if config.MAX_DISTANCE ~= nil then MAX_DISTANCE = config.MAX_DISTANCE end
        
        if config.flyEnabled ~= nil then setFeatureState("Fly", config.flyEnabled) end
        if config.flySpeedValue ~= nil then flySpeedValue = config.flySpeedValue end
        if config.infiniteJumpEnabled ~= nil then setFeatureState("InfJump", config.infiniteJumpEnabled) end
        if config.spinBotEnabled ~= nil then setFeatureState("SpinBot", config.spinBotEnabled) end
        if config.spinBotSpeed ~= nil then spinBotSpeed = config.spinBotSpeed end
        
        if config.radioSoundId ~= nil then radioSoundId = config.radioSoundId else radioSoundId = "5410086218" end
        if config.radioVolume ~= nil then radioVolume = config.radioVolume end
        if config.radioPlaying ~= nil then
            radioPlaying = config.radioPlaying
            updateRadio()
        end
        
        if config.shotType ~= nil then shotType = config.shotType end
        if config.antiAfkEnabled ~= nil then setFeatureState("AntiAfk", config.antiAfkEnabled) end
        
        if config.notifySheriffDeath ~= nil then notifySheriffDeath = config.notifySheriffDeath end
        if config.notifyGunDrop ~= nil then notifyGunDrop = config.notifyGunDrop end
        if config.notifyRoles ~= nil then notifyRoles = config.notifyRoles end
        if config.notifyGunPickup ~= nil then notifyGunPickup = config.notifyGunPickup end
        
        if config.hudVisible ~= nil then hudFrame.Visible = config.hudVisible end
        if config.featuresVisible ~= nil then featuresFrame.Visible = config.featuresVisible end
        if config.mm2InfoVisible ~= nil then mm2InfoFrame.Visible = config.mm2InfoVisible end
        if config.hudGlowColor ~= nil then
            local col = Color3.new(config.hudGlowColor[1], config.hudGlowColor[2], config.hudGlowColor[3])
            updateHudGlowColor(col)
        end
        
        pcall(function()
            updateToggleVisual(toggles.AutoPickup, autoPickupEnabled)
            updateToggleVisual(toggles.ESP, espEnabled)
            updateToggleVisual(toggles.Xray, xrayEnabled)
            updateToggleVisual(toggles.NoClip, noclipEnabled)
            updateToggleVisual(toggles.AntiFling, antiFlingEnabled)
            updateToggleVisual(toggles.ForceNight, forceNightEnabled)
            
            updateToggleVisual(toggles.Fly, flyEnabled)
            updateToggleVisual(toggles.InfJump, infiniteJumpEnabled)
            updateToggleVisual(toggles.SpinBot, spinBotEnabled)
            updateToggleVisual(toggles.RadioPlay, radioPlaying)
            updateToggleVisual(toggles.AntiAfk, antiAfkEnabled)
            
            updateToggleVisual(toggles.NotifySheriff, notifySheriffDeath)
            updateToggleVisual(toggles.NotifyGunDrop, notifyGunDrop)
            updateToggleVisual(toggles.NotifyRoles, notifyRoles)
            updateToggleVisual(toggles.NotifyGunPickup, notifyGunPickup)
            
            updateToggleVisual(toggles.ShowHud, hudFrame.Visible)
            updateToggleVisual(toggles.ShowFeatures, featuresFrame.Visible)
            updateToggleVisual(toggles.ShowRoundInfo, mm2InfoFrame.Visible)
        end)
        
        sendNotification("Config System", "Config loaded successfully!", 3)
    else
        sendNotification("Config System", "Failed to parse config file!", 3)
    end
end

-- [[ TABS & SECTIONS SETUP ]]
local MainTab = Window:CreateTab({ Name = "Main", Icon = "🏠 " })
local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "⚔️ " })
local DupeTab = Window:CreateTab({ Name = "Dupe", Icon = "💎 " })
local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "👁️ " })
local MovementTab = Window:CreateTab({ Name = "Movement", Icon = "⚡ " })
local RadioTab = Window:CreateTab({ Name = "Radio", Icon = "🎵 " })
local HudTab = Window:CreateTab({ Name = "HUD Settings", Icon = "⚙️ " })
local BindsTab = Window:CreateTab({ Name = "Keybinds", Icon = "⌨️ " })

-- [[ MAIN TAB ]]
local MainSection = MainTab:CreateSection({ Title = "Main Controls" })
local ConfigSection = MainTab:CreateSection({ Title = "Config System" })
local UnloadSection = MainTab:CreateSection({ Title = "Script Unload" })

MainSection:AddDropdown({
    Text = "Language / Язык",
    Values = {"RU", "EN"},
    Default = "RU",
    Callback = function(v)
        currentLang = v
        updateLanguageLabels()
    end
})

MainSection:AddButton({
    Text = "Rejoin Server",
    Callback = rejoinServer
})
labelRejoin = MainSection:AddLabel(langData[currentLang].rejoin)

ConfigSection:AddButton({
    Text = "Save Config",
    Callback = saveSettings
})

ConfigSection:AddButton({
    Text = "Load Config",
    Callback = loadSettings
})

ConfigSection:AddButton({
    Text = "Reset Config",
    Callback = function()
        setFeatureState("AutoPickup", false)
        setFeatureState("ESP", false)
        setFeatureState("Xray", false)
        setFeatureState("NoClip", false)
        setFeatureState("AntiFling", false)
        setFeatureState("ForceNight", false)
        setFeatureState("Fly", false)
        setFeatureState("InfJump", false)
        setFeatureState("AntiAfk", false)
        setFeatureState("SpinBot", false)
        
        radioPlaying = false
        radioSoundId = "5410086218"
        radioVolume = 0.5
        updateRadio()
        
        walkSpeedValue = 16
        jumpPowerValue = 50
        MAX_DISTANCE = 500
        flySpeedValue = 50
        spinBotSpeed = 100
        shotType = "Default"
        
        notifySheriffDeath = true
        notifyGunDrop = true
        notifyRoles = true
        notifyGunPickup = true
        
        hudFrame.Visible = false
        featuresFrame.Visible = false
        mm2InfoFrame.Visible = false
        updateHudGlowColor(Color3.fromRGB(0, 255, 200))
        
        pcall(function()
            updateToggleVisual(toggles.NotifySheriff, true)
            updateToggleVisual(toggles.NotifyGunDrop, true)
            updateToggleVisual(toggles.NotifyRoles, true)
            updateToggleVisual(toggles.NotifyGunPickup, true)
            
            updateToggleVisual(toggles.ShowHud, false)
            updateToggleVisual(toggles.ShowFeatures, false)
            updateToggleVisual(toggles.ShowRoundInfo, false)
            updateToggleVisual(toggles.RadioPlay, false)
        end)
        
        sendNotification("Config System", "Config has been reset!", 3)
    end
})
labelConfigs = ConfigSection:AddLabel(langData[currentLang].configs)

UnloadSection:AddButton({
    Text = "Self Destruct",
    Callback = function()
        scriptRunning = false
        setFeatureState("AutoPickup", false)
        setFeatureState("ESP", false)
        setFeatureState("Xray", false)
        setFeatureState("NoClip", false)
        setFeatureState("AntiFling", false)
        setFeatureState("ForceNight", false)
        setFeatureState("Fly", false)
        setFeatureState("InfJump", false)
        setFeatureState("AntiAfk", false)
        setFeatureState("SpinBot", false)
        
        if radioSoundObject then
            radioSoundObject:Stop()
            radioSoundObject:Destroy()
            radioSoundObject = nil
        end
        
        pcall(function() renderSteppedConnection:Disconnect() end)
        pcall(function() steppedConnection:Disconnect() end)
        pcall(function() descendantAddedConnection:Disconnect() end)
        pcall(function() jumpRequestConnection:Disconnect() end)
        pcall(function() idledConnection:Disconnect() end)
        pcall(function() fpsConnection:Disconnect() end)
        
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            if char then
                local highlight = char:FindFirstChild("RoleESP")
                if highlight then highlight:Destroy() end
                local head = char:FindFirstChild("Head")
                if head then
                    local billboard = head:FindFirstChild("RoleNameESP")
                    if billboard then billboard:Destroy() end
                end
            end
        end
        
        pcall(function()
            local animGui = (gethui and gethui():FindFirstChild("NullUI_DupeAnimation")) or LocalPlayer:FindFirstChild("NullUI_DupeAnimation", true)
            if animGui then animGui:Destroy() end
        end)
        
        pcall(function() hudFrame:Destroy() end)
        pcall(function() featuresFrame:Destroy() end)
        pcall(function() mm2InfoFrame:Destroy() end)
        pcall(function() NotificationGui:Destroy() end)
        
        pcall(function() Window:Destroy() end)
        pcall(function() NullLib:Destroy() end)
        
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "NullUI" or gui.Name:lower():find("null") or gui.Name == "Orion" or gui.Name:lower():find("githubproject")) then
                pcall(function() gui:Destroy() end)
            end
        end
        for _, gui in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "NullUI" or gui.Name:lower():find("null") or gui.Name == "Orion" or gui.Name:lower():find("githubproject")) then
                pcall(function() gui:Destroy() end)
            end
        end
    end
})
labelUnload = UnloadSection:AddLabel(langData[currentLang].unload)

-- [[ COMBAT TAB ]]
local CombatSection = CombatTab:CreateSection({ Title = "Weapons & Target Assistance" })

CombatSection:AddDropdown({
    Text = "Shot Type",
    Values = {"Default", "TP Bullet (Yoxi Hub)", "Teleport Player"},
    Default = "Default",
    Callback = function(v)
        shotType = v
    end
})

CombatSection:AddButton({
    Text = "Shoot Murderer Once",
    Callback = shootMurdererOnce
})

CombatSection:AddButton({
    Text = "Shoot at Cursor (Test)",
    Callback = shootAtCursor
})

toggles.AutoPickup = CombatSection:AddToggle({
    Text = "Auto Pickup Gun",
    Flag = "AutoPickup",
    Callback = function(state) 
        setFeatureState("AutoPickup", state)
    end
})

toggles.AntiAfk = CombatSection:AddToggle({
    Text = "Anti-AFK (Stay Online)",
    Flag = "AntiAfk",
    Callback = function(state)
        setFeatureState("AntiAfk", state)
    end
})

-- [[ DUPE TAB ]]
local DupeSection = DupeTab:CreateSection({ Title = "Phantom Skin Duplicator" })
labelDupeWarn = DupeSection:AddLabel(langData[currentLang].dupe_warn)

DupeSection:AddDropdown({
    Text = "Weapon Type",
    Values = {"Knife", "Gun", "Pet"},
    Default = "Knife",
    Callback = function(v)
        dupeWeaponType = v
        updateWeaponsList()
    end
})

DupeSection:AddDropdown({
    Text = "Rarity",
    Values = {"Common", "Uncommon", "Rare", "Legendary", "Vintage", "Godly", "Ancient", "Unique", "Chroma"},
    Default = "Godly",
    Callback = function(v)
        dupeRarity = v
        updateWeaponsList()
    end
})

weaponNameDropdown = DupeSection:AddDropdown({
    Text = "Weapon Name",
    Values = MM2_ITEMS_DB[dupeRarity][dupeWeaponType],
    Default = MM2_ITEMS_DB[dupeRarity][dupeWeaponType][1] or "Luger",
    Callback = function(v)
        dupeWeaponName = v
    end
})

DupeSection:AddSlider({
    Text = "Quantity",
    Min = 1, Max = 100, Default = 1,
    Callback = function(v)
        dupeQuantity = v
    end
})

DupeSection:AddButton({
    Text = "Dupe & Play Animation",
    Callback = function()
        playDupeAnimation(dupeWeaponName, dupeRarity, dupeWeaponType, dupeQuantity)
    end
})
labelDupeDesc = DupeSection:AddLabel(langData[currentLang].dupe_desc)

-- [[ VISUALS TAB ]]
local EspMainSection = VisualsTab:CreateSection({ Title = "ESP Settings", Side = "Left" })
local XraySection = VisualsTab:CreateSection({ Title = "X-Ray & Lighting", Side = "Right" }) 
local NotificationSection = VisualsTab:CreateSection({ Title = "Notification Settings", Side = "Right" })

toggles.ESP = EspMainSection:AddToggle({
    Text = "Enable Player ESP",
    Flag = "PlayerESP",
    Callback = function(state) 
        setFeatureState("ESP", state)
    end
})

EspMainSection:AddSlider({
    Text = "Max Distance",
    Min = 50, Max = 3000, Default = 500,
    Callback = function(v) MAX_DISTANCE = v end
})

EspMainSection:AddColorPicker({ Text = "Murderer Color", DefaultColor = COLORS.Murderer, Callback = function(c) COLORS.Murderer = c end })
EspMainSection:AddColorPicker({ Text = "Sheriff Color", DefaultColor = COLORS.Sheriff, Callback = function(c) COLORS.Sheriff = c end })
EspMainSection:AddColorPicker({ Text = "Innocent Color", DefaultColor = COLORS.Innocent, Callback = function(c) COLORS.Innocent = c end })
labelEsp = EspMainSection:AddLabel(langData[currentLang].esp)

toggles.Xray = XraySection:AddToggle({
    Text = "Enable X-Ray",
    Flag = "XrayToggle",
    Callback = function(state)
        setFeatureState("Xray", state)
    end
})

XraySection:AddSlider({
    Text = "Wall Transparency",
    Min = 0, Max = 100, Default = 50,
    Callback = function(v)
        xrayTransparency = v / 100
        updateXrayTransparency()
    end
})

toggles.ForceNight = XraySection:AddToggle({
    Text = "Force Night Mode",
    Flag = "ForceNight",
    Callback = function(state)
        setFeatureState("ForceNight", state)
    end
})
labelXray = XraySection:AddLabel(langData[currentLang].xray)

toggles.NotifySheriff = NotificationSection:AddToggle({
    Text = "Notify Sheriff Death",
    Default = true,
    Callback = function(state) notifySheriffDeath = state end
})

toggles.NotifyGunDrop = NotificationSection:AddToggle({
    Text = "Notify Gun Drop",
    Default = true,
    Callback = function(state) notifyGunDrop = state end
})

toggles.NotifyRoles = NotificationSection:AddToggle({
    Text = "Notify Role Distribution",
    Default = true,
    Callback = function(state) notifyRoles = state end
})

toggles.NotifyGunPickup = NotificationSection:AddToggle({
    Text = "Notify Gun Pickup",
    Default = true,
    Callback = function(state) notifyGunPickup = state end
})
labelNotifications = NotificationSection:AddLabel(langData[currentLang].notifications)

-- [[ MOVEMENT TAB ]]
local MoveSection = MovementTab:CreateSection({ Title = "Character Customization" })
MoveSection:AddSlider({ Text = "WalkSpeed", Min = 16, Max = 150, Default = 16, Callback = function(v) walkSpeedValue = v end })
MoveSection:AddSlider({ Text = "JumpPower", Min = 50, Max = 250, Default = 50, Callback = function(v) jumpPowerValue = v end })

toggles.NoClip = MoveSection:AddToggle({ 
    Text = "NoClip (Pass through walls)", 
    Callback = function(s) 
        setFeatureState("NoClip", s)
    end 
})

toggles.AntiFling = MoveSection:AddToggle({ 
    Text = "Anti-Fling", 
    Callback = function(s) 
        setFeatureState("AntiFling", s)
    end 
})

toggles.Fly = MoveSection:AddToggle({
    Text = "Fly Mode",
    Callback = function(s)
        setFeatureState("Fly", s)
    end
})

MoveSection:AddSlider({
    Text = "Fly Speed",
    Min = 10, Max = 300, Default = 50,
    Callback = function(v) flySpeedValue = v end
})

toggles.InfJump = MoveSection:AddToggle({
    Text = "Infinite Jump",
    Callback = function(s)
        setFeatureState("InfJump", s)
    end
})

toggles.SpinBot = MoveSection:AddToggle({
    Text = "Spin Bot",
    Callback = function(s)
        setFeatureState("SpinBot", s)
    end
})

MoveSection:AddSlider({
    Text = "Spin Speed",
    Min = 10, Max = 500, Default = 100,
    Callback = function(v) spinBotSpeed = v end
})
labelMovement = MoveSection:AddLabel(langData[currentLang].movement)

-- [[ RADIO TAB ]]
local RadioSection = RadioTab:CreateSection({ Title = "Visual Radio (Local Sound)" })
labelRadioWarn = RadioSection:AddLabel(langData[currentLang].radio_warn)

toggles.RadioPlay = RadioSection:AddToggle({
    Text = "Enable Radio",
    Callback = function(state)
        radioPlaying = state
        updateRadio()
    end
})

addTextboxToSection(RadioSection, {
    Text = "Audio ID",
    Default = "5410086218",
    Callback = function(val)
        radioSoundId = val
        if radioPlaying then
            updateRadio()
        end
    end
})

RadioSection:AddSlider({
    Text = "Volume",
    Min = 0, Max = 100, Default = 50,
    Callback = function(val)
        radioVolume = val / 100
        if radioSoundObject then
            radioSoundObject.Volume = radioVolume
        end
    end
})
labelRadioDesc = RadioSection:AddLabel(langData[currentLang].radio_desc)

-- [[ HUD SETTINGS TAB ]]
local HudSection = HudTab:CreateSection({ Title = "HUD Panels Configuration" })

toggles.ShowHud = HudSection:AddToggle({
    Text = "Show Main HUD Bar",
    Default = false, 
    Callback = function(state)
        hudFrame.Visible = state
    end
})

toggles.ShowFeatures = HudSection:AddToggle({
    Text = "Show Active Features Panel",
    Default = false, 
    Callback = function(state)
        featuresFrame.Visible = state
    end
})

toggles.ShowRoundInfo = HudSection:AddToggle({
    Text = "Show Round Info Panel",
    Default = false, 
    Callback = function(state)
        mm2InfoFrame.Visible = state
    end
})

HudSection:AddColorPicker({
    Text = "HUD Neon Color",
    DefaultColor = Color3.fromRGB(0, 255, 200),
    Callback = function(color)
        updateHudGlowColor(color)
    end
})

-- [[ KEYBINDS TAB ]]
local BindsSection = BindsTab:CreateSection({ Title = "Hotkeys" })

BindsSection:AddKeybind({ 
    Text = "Toggle Menu Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Callback = function() Window:Toggle() end 
})

BindsSection:AddKeybind({ 
    Text = "Auto Pickup Gun Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        setFeatureState("AutoPickup", s)
    end 
})

BindsSection:AddKeybind({ 
    Text = "Player ESP Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        setFeatureState("ESP", s)
    end 
})

BindsSection:AddKeybind({ 
    Text = "X-Ray Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        setFeatureState("Xray", s)
    end 
})

BindsSection:AddKeybind({ 
    Text = "NoClip Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        setFeatureState("NoClip", s)
    end 
})

BindsSection:AddKeybind({ 
    Text = "Anti-Fling Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        setFeatureState("AntiFling", s)
    end 
})

BindsSection:AddKeybind({ 
    Text = "Force Night Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        setFeatureState("ForceNight", s)
    end 
})

BindsSection:AddKeybind({ 
    Text = "Fly Mode Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        setFeatureState("Fly", s)
    end 
})

BindsSection:AddKeybind({ 
    Text = "Infinite Jump Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        setFeatureState("InfJump", s)
    end 
})

BindsSection:AddKeybind({ 
    Text = "Spin Bot Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        setFeatureState("SpinBot", s)
    end 
})

BindsSection:AddKeybind({ 
    Text = "Shoot Murderer Once Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        if s then
            shootMurdererOnce()
        end
    end 
})

BindsSection:AddKeybind({ 
    Text = "Shoot at Cursor Bind", 
    DefaultKey = Enum.KeyCode.Unknown, 
    Mode = "Toggle", 
    Callback = function(s) 
        if s then
            shootAtCursor()
        end
    end 
})

updateLanguageLabels()