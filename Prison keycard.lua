local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Limpeza de interfaces antigas
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "Yuri_Minimal_V9" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Yuri_Minimal_V9"

local State = {
    KeycardActive = false,
    StickActive = false,
    TargetPlayer = nil,
    OldPos = nil
}

-- INTERFACE PRINCIPAL
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 150)
Main.Position = UDim2.new(0.5, -100, 0.5, -75)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Visible = false
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 150)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "YURI SUPREMACIA"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 5)

-- BOTÃO MESTRE "Y"
local Master = Instance.new("TextButton", ScreenGui)
Master.Size = UDim2.new(0, 50, 0, 50)
Master.Position = UDim2.new(0.1, 0, 0.5, 0)
Master.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
Master.Text = "Y"
Master.Draggable = true
Instance.new("UICorner", Master).CornerRadius = UDim.new(1, 0)
Master.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- PAINEL DE JOGADORES (TODOS OS TIMES)
local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0, 160, 0, 200)
Side.Position = UDim2.new(1.1, 0, 0, 0)
Side.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Side.Visible = false
Instance.new("UICorner", Side)

local SideScroll = Instance.new("ScrollingFrame", Side)
SideScroll.Size = UDim2.new(1, -5, 1, -5)
SideScroll.Position = UDim2.new(0, 2.5, 0, 2.5)
SideScroll.BackgroundTransparency = 1
SideScroll.ScrollBarThickness = 4
SideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Mantendo a correção
Instance.new("UIListLayout", SideScroll).Padding = UDim.new(0, 2)

-- FUNÇÃO KEYCARD
local function ToggleKeycard(active)
    State.KeycardActive = active
    if active then
        local k = Instance.new("Tool", LocalPlayer.Backpack)
        k.Name = "Key card"
        local h = Instance.new("Part", k)
        h.Name = "Handle"
        task.spawn(function()
            while State.KeycardActive do
                for _, d in pairs(workspace:GetDescendants()) do
                    if d.Name == "Detector" and d:IsA("ClickDetector") then
                        fireclickdetector(d)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end

-- FUNÇÃO GRUDE
local function StartStick(player)
    if not State.StickActive then
        State.OldPos = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
    State.TargetPlayer = player
    State.StickActive = true
    Side.Visible = false
end

-- CRIAR BOTÕES
local function CreateBtn(name, callback, isToggle)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        if isToggle then
            local active = btn.BackgroundColor3 == Color3.fromRGB(30, 30, 30)
            btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(30, 30, 30)
            callback(active)
        else
            callback()
        end
    end)
end

CreateBtn("Keycard (Ativar)", function(a) ToggleKeycard(a) end, true)

CreateBtn("Grude (Jogadores)", function()
    Side.Visible = not Side.Visible
    for _, v in pairs(SideScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    
    -- Botão Desativar
    local off = Instance.new("TextButton", SideScroll)
    off.Size = UDim2.new(1, 0, 0, 35)
    off.Text = "[ SOLTAR / VOLTAR ]"
    off.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    off.TextColor3 = Color3.new(1,1,1)
    off.MouseButton1Click:Connect(function()
        if State.StickActive and State.OldPos then
            LocalPlayer.Character.HumanoidRootPart.CFrame = State.OldPos
        end
        State.StickActive = false
        State.TargetPlayer = nil
        Side.Visible = false
    end)

    -- PUXAR TODOS OS JOGADORES (SEM FILTRO DE TIME)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", SideScroll)
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.Text = p.Name
            pBtn.BackgroundTransparency = 0.8
            pBtn.TextColor3 = Color3.new(1,1,1)
            pBtn.MouseButton1Click:Connect(function() StartStick(p) end)
        end
    end
end, false)

-- LOOP DO GRUDE (15 METROS ABAIXO)
RunService.Heartbeat:Connect(function()
    if State.StickActive and State.TargetPlayer and State.TargetPlayer.Character then
        local targetHRP = State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            -- Fica 15 metros abaixo do alvo
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, -15, 0)
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)
