local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- // Configuration
local LIBRARY_NAME = "Zvios Hub"
local THEME = {
    Accent = Color3.fromRGB(220, 20, 40),      -- Red
    Main = Color3.fromRGB(10, 10, 12),         -- Dark Black
    Secondary = Color3.fromRGB(18, 18, 20),    -- Light Black
    Text = Color3.fromRGB(240, 240, 240),
    Gradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 0, 0))
    }
}

-- // Cleanup Old Instances
if Player.PlayerGui:FindFirstChild(LIBRARY_NAME) then
    Player.PlayerGui[LIBRARY_NAME]:Destroy()
end
if game.CoreGui:FindFirstChild(LIBRARY_NAME) then
    game.CoreGui[LIBRARY_NAME]:Destroy()
end

local Library = {}

-- // Utility
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function Tween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(topbar, widget)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        Tween(widget, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {Position = targetPos})
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = widget.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Library:CreateWindow(options)
    local WindowName = options.Name or "Zvios Hub"
    local InviteCode = options.DiscordInvite or ""
    local IsOpen = true
    
    -- // UI Base
    local ScreenGui = Create("ScreenGui", {
        Name = LIBRARY_NAME,
        Parent = Player:WaitForChild("PlayerGui"), -- Forced PlayerGui for compatibility
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    -- // Main Window
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = THEME.Main,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(0, 0),
        ZIndex = 1
    })
    
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)})
    
    local GlowStroke = Create("UIStroke", {
        Parent = MainFrame,
        Thickness = 2,
        Transparency = 0,
        Color = Color3.fromRGB(255,255,255)
    })
    Create("UIGradient", {Parent = GlowStroke, Color = THEME.Gradient, Rotation = 45})

    -- // Topbar
    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = THEME.Secondary,
        Size = UDim2.new(1, 0, 0, 35),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Create("UICorner", {Parent = Topbar, CornerRadius = UDim.new(0, 6)})
    
    -- Filler to hide bottom corners of Topbar
    Create("Frame", {
        Parent = Topbar,
        BackgroundColor3 = THEME.Secondary,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BorderSizePixel = 0
    })

    local TitleLabel = Create("TextLabel", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = string.upper(WindowName),
        TextColor3 = THEME.Accent,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- // Close Button
    local CloseBtn = Create("TextButton", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Text = "×",
        Font = Enum.Font.GothamMedium,
        TextSize = 24,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        AutoButtonColor = false
    })
    Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(0, 8)})

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.9, BackgroundColor3 = THEME.Accent})
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1})
    end)
    
    -- // Mobile Toggle
    local MobileToggle = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = THEME.Secondary,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.1, 0, 0.1, 0),
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Visible = false
    })
    Create("UICorner", {Parent = MobileToggle, CornerRadius = UDim.new(0, 10)})
    
    local ToggleStroke = Create("UIStroke", {
        Parent = MobileToggle,
        Thickness = 2,
        Transparency = 0,
        Color = Color3.fromRGB(255,255,255)
    })
    Create("UIGradient", {Parent = ToggleStroke, Color = THEME.Gradient, Rotation = 45})
    
    local MobileBtn = Create("TextButton", {
        Parent = MobileToggle,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "ZV",
        Font = Enum.Font.GothamBlack,
        TextColor3 = THEME.Accent,
        TextSize = 16
    })

    -- // Toggle Logic
    local function ToggleUI(bool)
        IsOpen = bool
        if IsOpen then
            MobileToggle.Visible = false
            MainFrame.Visible = true
            Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 600, 0, 400),
                Position = UDim2.new(0.5, -300, 0.5, -200)
            })
        else
            local closeAnim = Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            closeAnim.Completed:Wait()
            MainFrame.Visible = false
            MobileToggle.Visible = true
        end
    end

    CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)
    MobileBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightControl then
            ToggleUI(not IsOpen)
        end
    end)

    MakeDraggable(Topbar, MainFrame)

    -- // Sidebar
    local Sidebar = Create("ScrollingFrame", {
        Parent = MainFrame,
        BackgroundColor3 = THEME.Secondary,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 160, 1, -35),
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Create("UIPadding", {Parent = Sidebar, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 90)})

    -- // Discord Integration
    if InviteCode ~= "" then
        local DiscordFrame = Create("Frame", {
            Parent = MainFrame,
            BackgroundColor3 = Color3.fromRGB(15, 15, 17),
            Position = UDim2.new(0, 10, 1, -85),
            Size = UDim2.new(0, 140, 0, 75),
            ZIndex = 5
        })
        Create("UICorner", {Parent = DiscordFrame, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = DiscordFrame, Color = Color3.fromRGB(35, 35, 40), Thickness = 1})
        
        Create("ImageLabel", {
            Parent = DiscordFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0, 30, 0, 30),
            Image = "rbxassetid://9057864139", 
            ScaleType = Enum.ScaleType.Fit
        })

        local ServerNameLbl = Create("TextLabel", {
            Parent = DiscordFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 45, 0, 8),
            Size = UDim2.new(1, -50, 0, 15),
            Font = Enum.Font.GothamBold,
            Text = "Fetching...",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })

        local MembersLbl = Create("TextLabel", {
            Parent = DiscordFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 45, 0, 23),
            Size = UDim2.new(1, -50, 0, 15),
            Font = Enum.Font.Gotham,
            Text = "...",
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local JoinBtn = Create("TextButton", {
            Parent = DiscordFrame,
            BackgroundColor3 = Color3.fromRGB(88, 101, 242),
            Position = UDim2.new(0, 8, 1, -28),
            Size = UDim2.new(1, -16, 0, 20),
            Text = "Join Server",
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 11,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = JoinBtn, CornerRadius = UDim.new(0, 4)})

        JoinBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard("https://discord.gg/" .. InviteCode)
            end
            -- Attempt request join
            local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
            if req then
                req({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json", ["Origin"] = "https://discord.com"},
                    Body = HttpService:JSONEncode({cmd = "INVITE_BROWSER", args = {code = InviteCode}, nonce = HttpService:GenerateGUID(false)})
                })
            end
        end)

        -- Fetch Data in Spawn to prevent yielding main thread
        task.spawn(function()
            local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
            if req then
                local success, result = pcall(function()
                    return req({Url = "https://discord.com/api/v9/invites/" .. InviteCode .. "?with_counts=true", Method = "GET"})
                end)
                
                if success and result and result.Body then
                    local data = HttpService:JSONDecode(result.Body)
                    if data and data.guild then
                        ServerNameLbl.Text = data.guild.name
                        MembersLbl.Text = data.approximate_member_count .. " Members"
                    end
                else
                    ServerNameLbl.Text = "Zvios Hub"
                    MembersLbl.Text = "Join Discord"
                end
            else
                ServerNameLbl.Text = "Zvios Hub"
                MembersLbl.Text = "Join Discord"
            end
        end)
    end

    local ContentArea = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 170, 0, 35),
        Size = UDim2.new(1, -170, 1, -35),
        ClipsDescendants = true,
        ZIndex = 2
    })

    -- // Tabs & Logic
    local WindowAPI = {}
    local Tabs = {}
    local FirstTab = true

    function WindowAPI:CreateTab(name)
        local TabBtn = Create("TextButton", {
            Parent = Sidebar,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = Color3.fromRGB(120, 120, 120),
            TextSize = 13,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})

        local Indicator = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 2, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundTransparency = 1
        })
        Create("UIGradient", {Parent = Indicator, Color = THEME.Gradient, Rotation = 90})

        local TabContainer = Create("ScrollingFrame", {
            Parent = ContentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
        Create("UIPadding", {Parent = TabContainer, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10)})

        local TabObj = {Button = TabBtn, Container = TabContainer, Indicator = Indicator}
        table.insert(Tabs, TabObj)

        local function Activate()
            for _, t in pairs(Tabs) do
                t.Container.Visible = false
                Tween(t.Button, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(120, 120, 120)})
                Tween(t.Indicator, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            end
            
            TabContainer.Visible = true
            TabContainer.CanvasPosition = Vector2.new(0,0)
            TabContainer.Position = UDim2.new(0, 10, 0, 0)
            Tween(TabContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0,0,0,0)})
            
            Tween(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.95, TextColor3 = Color3.fromRGB(255, 255, 255)})
            Tween(Indicator, TweenInfo.new(0.3), {BackgroundTransparency = 0})
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        if FirstTab then FirstTab = false; Activate() end

        local TabAPI = {}
        function TabAPI:CreateSection(sectName)
            local SectionContainer = Create("Frame", {
                Parent = TabContainer,
                BackgroundColor3 = THEME.Secondary,
                BackgroundTransparency = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0
            })
            Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = SectionContainer, Color = Color3.fromRGB(35, 35, 40), Thickness = 1})
            Create("UIPadding", {Parent = SectionContainer, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
            Create("TextLabel", {
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Text = string.upper(sectName),
                TextColor3 = THEME.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                Size = UDim2.new(1, 0, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            Create("UIListLayout", {Parent = SectionContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})

            local SectionAPI = {}
            function SectionAPI:CreateButton(bOptions)
                local BtnFrame = Create("Frame", {
                    Parent = SectionContainer, BackgroundColor3 = Color3.fromRGB(25, 25, 28), Size = UDim2.new(1, 0, 0, 32)
                })
                Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = BtnFrame, Color = Color3.fromRGB(45, 45, 50), Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
                local Interact = Create("TextButton", {
                    Parent = BtnFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = bOptions.Name or "Button", Font = Enum.Font.GothamMedium, TextColor3 = Color3.fromRGB(230, 230, 230), TextSize = 13, AutoButtonColor = false
                })
                Interact.MouseEnter:Connect(function() Tween(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 38)}) end)
                Interact.MouseLeave:Connect(function() Tween(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 28)}) end)
                Interact.MouseButton1Click:Connect(function() bOptions.Callback() end)
            end

            function SectionAPI:CreateToggle(tOptions)
                local Toggled = tOptions.Default or false
                local ToggleFrame = Create("Frame", {Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32)})
                Create("TextLabel", {Parent = ToggleFrame, BackgroundTransparency = 1, Text = tOptions.Name or "Toggle", TextColor3 = Color3.fromRGB(230, 230, 230), Font = Enum.Font.GothamMedium, TextSize = 13, Size = UDim2.new(0.7, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left})
                local Switch = Create("Frame", {Parent = ToggleFrame, BackgroundColor3 = Color3.fromRGB(25, 25, 28), Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -44, 0.5, -11)})
                Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
                local SwitchStroke = Create("UIStroke", {Parent = Switch, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})
                local Knob = Create("Frame", {Parent = Switch, BackgroundColor3 = Color3.fromRGB(120, 120, 120), Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 3, 0.5, -8)})
                Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
                local Trigger = Create("TextButton", {Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})
                
                local function UpdateState()
                    if Toggled then
                        Tween(SwitchStroke, TweenInfo.new(0.3), {Color = THEME.Accent})
                        Tween(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = THEME.Accent})
                    else
                        Tween(SwitchStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(45, 45, 50)})
                        Tween(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(120, 120, 120)})
                    end
                    tOptions.Callback(Toggled)
                end
                if Toggled then UpdateState() end
                Trigger.MouseButton1Click:Connect(function() Toggled = not Toggled; UpdateState() end)
            end
            return SectionAPI
        end
        return TabAPI
    end
    
    return WindowAPI
end


-- // ==============================
-- // EXECUTION
-- // ==============================

local Window = Library:CreateWindow({
    Name = "Zvios Hub",
    DiscordInvite = "aAVZyVDhNq"
})

local MainTab = Window:CreateTab("Main")
local MainSection = MainTab:CreateSection("Character")

MainSection:CreateToggle({
    Name = "WalkSpeed",
    Default = false,
    Callback = function(Value)
        if Value then
            Player.Character.Humanoid.WalkSpeed = 50
        else
            Player.Character.Humanoid.WalkSpeed = 16
        end
    end
})

MainSection:CreateButton({
    Name = "Fly Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end
})

local SettingsTab = Window:CreateTab("Settings")
local ConfigSection = SettingsTab:CreateSection("UI Config")

ConfigSection:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        if Player.PlayerGui:FindFirstChild(LIBRARY_NAME) then
            Player.PlayerGui[LIBRARY_NAME]:Destroy()
        end
    end
})

print("Zvios Hub Loaded Successfully")
