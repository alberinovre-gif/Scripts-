--[[ 
    GOAT EXTERNAL - VERSÃO DEFINITIVA UNIVERSAL
    - FIX: Aimbot agora mira em QUALQUER jogo (Independente de Time).
    - FIX: Mantida a hierarquia das 12 funções e interface original.
--]]

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

if CoreGui:FindFirstChild("GoatGui") then CoreGui.GoatGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "GoatGui"; ScreenGui.ResetOnSpawn = false

getgenv().GoatConfig = {
    AimActive = false, AimValue = 500, FlyActive = false, FlyValue = 50,
    SpeedActive = false, SpeedValue = 100, JumpActive = false, JumpValue = 100,
    OpoFindActive = false, VerTodosActive = false, PortasActive = false,
    NoMoviActive = false, TravarVeicActive = false, TravarTarget = nil,
    PrenderActive = false, PrenderTarget = nil, PrenderSize = 20,
    Aim2Active = false, Aim2Target = nil, GrudeActive = false, GrudeTarget = nil
}
local _G_DATA = getgenv().GoatConfig

-- [ UI MASTER ]
local MasterFrame = Instance.new("Frame", ScreenGui)
MasterFrame.Size = UDim2.new(0, 60, 0, 60); MasterFrame.Position = UDim2.new(0.5, -30, 0.2, 0); MasterFrame.BackgroundTransparency = 1; MasterFrame.Active = true

local GoatBtn = Instance.new("TextButton", MasterFrame)
GoatBtn.Size = UDim2.new(1, 0, 1, 0); GoatBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255); GoatBtn.Text = "GOAT"; GoatBtn.TextColor3 = Color3.new(1, 1, 1); GoatBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", GoatBtn)

local MainFrame = Instance.new("ScrollingFrame", MasterFrame)
MainFrame.Size = UDim2.new(0, 200, 0, 300); MainFrame.Position = UDim2.new(1, 15, 0, 0); MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Visible = false; MainFrame.ScrollBarThickness = 4; MainFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; Instance.new("UICorner", MainFrame)
local mainLayout = Instance.new("UIListLayout", MainFrame); mainLayout.Padding = UDim.new(0, 5); mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidePanel = Instance.new("ScrollingFrame", MasterFrame)
SidePanel.Size = UDim2.new(0, 170, 0, 250); SidePanel.Position = UDim2.new(1, 225, 0, 0); SidePanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15); SidePanel.Visible = false; SidePanel.AutomaticCanvasSize = Enum.AutomaticSize.Y; Instance.new("UICorner", SidePanel)
Instance.new("UIListLayout", SidePanel).Padding = UDim.new(0, 5)

-- ARRASTE
local drag, dStart, sPos
GoatBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; dStart = i.Position; sPos = MasterFrame.Position end end)
UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - dStart; MasterFrame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function() drag = false end)
GoatBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible; SidePanel.Visible = false end)

local function OpenSide(mode)
    SidePanel.Visible = true; SidePanel:ClearAllChildren(); Instance.new("UIListLayout", SidePanel).Padding = UDim.new(0, 5)
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= Player then
            local b = Instance.new("TextButton", SidePanel); b.Size = UDim2.new(1,-10,0,30); b.Text = p.Name; b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                if mode == "Prender" then _G_DATA.PrenderTarget = p 
                elseif mode == "TravarVeic" then _G_DATA.TravarTarget = p
                elseif mode == "Aim2" then _G_DATA.Aim2Target = p 
                elseif mode == "Grude" then _G_DATA.GrudeTarget = p end
            end)
        end
    end
end

local function Create(name, icon, key, hasVal, def)
    local f = Instance.new("Frame", MainFrame); f.Size = UDim2.new(0, 180, 0, 35); f.BackgroundTransparency = 1; f.AutomaticSize = Enum.AutomaticSize.Y
    local c = Instance.new("Frame", f); c.Size = UDim2.new(1, 0, 0, 35); c.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", c)
    local t = Instance.new("TextButton", c); t.Size = UDim2.new(1, -45, 1, 0); t.Text = " "..icon.." "..name; t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(1, 1, 1); t.TextXAlignment = 0; t.TextSize = 10
    local ck = Instance.new("TextButton", c); ck.Size = UDim2.new(0, 25, 0, 25); ck.Position = UDim2.new(1, -30, 0.5, -12); ck.Text = ""; ck.BackgroundColor3 = Color3.fromRGB(20, 20, 20); ck.TextColor3 = Color3.new(0,1,0); Instance.new("UICorner", ck)

    if hasVal then
        local box = Instance.new("TextBox", f); box.Size = UDim2.new(1, -10, 0, 25); box.Position = UDim2.new(0, 5, 0, 38); box.Visible = false; box.Text = tostring(def); box.BackgroundColor3 = Color3.new(0, 0, 0); box.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", box)
        box.FocusLost:Connect(function() _G_DATA[key.."Value"] = tonumber(box.Text) or def end)
        t.MouseButton1Click:Connect(function() box.Visible = not box.Visible end)
    else
        t.MouseButton1Click:Connect(function() if key == "Grude" or key == "Aim2" or key == "Prender" or key == "TravarVeic" then OpenSide(key) end end)
    end
    ck.MouseButton1Click:Connect(function() _G_DATA[key.."Active"] = not _G_DATA[key.."Active"]; ck.Text = _G_DATA[key.."Active"] and "X" or "" end)
end

local list = {{"Aimbot","🎯","Aim",true,500},{"Fly Hack","🚀","Fly",true,50},{"Speed","⚡","Speed",true,100},{"Jump","👟","Jump",true,100},{"Opo Find","👁️","OpoFind"},{"Ver Todos","🔥","VerTodos"},{"Fechar Portas","🚪","Portas"},{"Travar Veic","🚫","TravarVeic"},{"Prender Agr","⚖️","Prender"},{"No Movi","💎","NoMovi"},{"Aim Lock 2","🔫","Aim2"},{"Grude","🔗","Grude"}}
for _,v in pairs(list) do Create(v[1],v[2],v[3],v[4],v[5]) end

-- [ LÓGICA DE ALTA PRIORIDADE ]
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = Player.Character; if not char then return end
        local hum = char:FindFirstChild("Humanoid"); local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        -- 1. AIMBOT UNIVERSAL (MIRA NO MAIS PRÓXIMO QUE NÃO SEJA VOCÊ)
        if _G_DATA.AimActive then
            local target = nil
            local dist = _G_DATA.AimValue
            for _,p in pairs(game.Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local d = (hrp.Position - p.Character.Head.Position).Magnitude
                    if d < dist then
                        target = p.Character
                        dist = d
                    end
                end
            end
            if target then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Head.Position)
            end
        end

        -- 11. AIM LOCK 2 (MIRA NO ALVO SELECIONADO NO PAINEL)
        if _G_DATA.Aim2Active and _G_DATA.Aim2Target and _G_DATA.Aim2Target.Character and _G_DATA.Aim2Target.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, _G_DATA.Aim2Target.Character.Head.Position)
        end

        -- OUTRAS FUNÇÕES
        if _G_DATA.FlyActive then hrp.Velocity = (workspace.CurrentCamera.CFrame:VectorToWorldSpace(hum.MoveDirection * _G_DATA.FlyValue)) end
        if _G_DATA.SpeedActive then hum.WalkSpeed = _G_DATA.SpeedValue else hum.WalkSpeed = 16 end
        if _G_DATA.JumpActive then hum.JumpPower = _G_DATA.JumpValue; hum.UseJumpPower = true else hum.UseJumpPower = false end
        if _G_DATA.GrudeActive and _G_DATA.GrudeTarget and _G_DATA.GrudeTarget.Character then hrp.CFrame = _G_DATA.GrudeTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
        if _G_DATA.NoMoviActive then for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CustomPhysicalProperties = PhysicalProperties.new(100,0.3,0.5) end end end
    end)
end)

-- [ ESP E LOOPS ]
RunService.RenderStepped:Connect(function()
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            if _G_DATA.OpoFindActive and (p.Team ~= Player.Team or p.Team == nil) then
                if not head:FindFirstChild("OpoESP") then
                    local bg = Instance.new("BillboardGui", head); bg.Name = "OpoESP"; bg.Size = UDim2.new(0,100,0,40); bg.AlwaysOnTop = true; bg.ExtentsOffset = Vector3.new(0,3,0)
                    local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.Text = p.Name; tl.TextColor3 = Color3.new(1,0,0); tl.BackgroundTransparency = 1; tl.Font = Enum.Font.GothamBold; tl.TextSize = 14
                end
            elseif head:FindFirstChild("OpoESP") then head.OpoESP:Destroy() end
            if _G_DATA.VerTodosActive then
                if not p.Character:FindFirstChild("GH") then local h = Instance.new("Highlight", p.Character); h.Name = "GH"; h.FillColor = Color3.new(1,0,0) end
            elseif p.Character:FindFirstChild("GH") then p.Character.GH:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if _G_DATA.PortasActive then for _,v in pairs(workspace:GetDescendants()) do if v.Name == "Door" and v:IsA("Model") and v:FindFirstChild("DoorInvis") then v.DoorInvis.CanCollide = true; v.DoorInvis.Anchored = true end end end
        if _G_DATA.TravarVeicActive and _G_DATA.TravarTarget then pcall(function() local s = _G_DATA.TravarTarget.Character.Humanoid.SeatPart; if s then s.MaxSpeed = 0; s.Parent.PrimaryPart.Anchored = true end end) end
        if _G_DATA.PrenderActive and _G_DATA.PrenderTarget and _G_DATA.PrenderTarget.Character then
            pcall(function() local hb = _G_DATA.PrenderTarget.Character.HumanoidRootPart; hb.Size = Vector3.new(_G_DATA.PrenderSize, _G_DATA.PrenderSize, _G_DATA.PrenderSize); hb.CanCollide = true; hb.Transparency = 0.8 end)
        end
    end
end)
