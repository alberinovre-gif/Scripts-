local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ZombieStairs_V4_Yuri"

local OpenCloseBtn = Instance.new("TextButton")
local MainFrame = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local WeaponFrame = Instance.new("Frame")

-- Botão Central (Redondo e Móvel)
OpenCloseBtn.Parent = ScreenGui
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
OpenCloseBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
OpenCloseBtn.Size = UDim2.new(0, 50, 0, 50)
OpenCloseBtn.Text = "HUB"
OpenCloseBtn.Draggable = true
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = OpenCloseBtn

-- Painel Principal
MainFrame.Parent = OpenCloseBtn
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(1.2, 0, 0, 0)
MainFrame.Size = UDim2.new(0, 190, 0, 320)
MainFrame.Visible = false

ScrollingFrame.Parent = MainFrame
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2.5, 0)
ScrollingFrame.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", ScrollingFrame)
UIList.Padding = UDim.new(0, 5)

-- Painel "TUDO" (Armas)
WeaponFrame.Parent = MainFrame
WeaponFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
WeaponFrame.Position = UDim2.new(1.05, 0, 0, 0)
WeaponFrame.Size = UDim2.new(0, 160, 0, 320)
WeaponFrame.Visible = false

OpenCloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    WeaponFrame.Visible = false
end)

local function CreateBtn(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

--- FUNÇÕES ---

-- 1. AIMBOT (MATOU -> TROCA)
_G.Aim = false
task.spawn(function()
    while task.wait() do
        if _G.Aim then
            local target = nil
            local dist = 1000
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Humanoid") and v.Parent ~= game.Players.LocalPlayer.Character and v.Health > 0 then
                    local head = v.Parent:FindFirstChild("Head")
                    if head and not game.Players:GetPlayerFromCharacter(v.Parent) then
                        local mag = (head.Position - game.Players.LocalPlayer.Character.Head.Position).Magnitude
                        if mag < dist then dist = mag target = head end
                    end
                end
            end
            if target then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
            end
        end
    end
end)
CreateBtn(ScrollingFrame, "Aimbot: OFF", Color3.fromRGB(40,40,40), function(s) _G.Aim = not _G.Aim end)

-- 2. FLY SEM CHÃO INVISÍVEL
_G.Fly = false
CreateBtn(ScrollingFrame, "Fly (Ativar)", Color3.fromRGB(40, 40, 40), function()
    _G.Fly = not _G.Fly
    local root = game.Players.LocalPlayer.Character.HumanoidRootPart
    if _G.Fly then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "YuriV"
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Velocity = Vector3.new(0, 0, 0)
    else
        if root:FindFirstChild("YuriV") then root.YuriV:Destroy() end
        -- Limpa qualquer força residual que crie o "chão invisível"
        for _, v in pairs(root:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyPosition") then v:Destroy() end end
    end
end)
CreateBtn(ScrollingFrame, "Subir Fly (+)", Color3.fromRGB(0, 100, 200), function()
    if _G.Fly then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 15, 0) end
end)

-- 3. BARREIRA (QUADRADO REALMENTE PEQUENO)
local ShieldParts = {}
CreateBtn(ScrollingFrame, "Cubo Mini", Color3.fromRGB(0, 120, 0), function()
    if #ShieldParts > 0 then
        for _, p in pairs(ShieldParts) do p:Destroy() end
        ShieldParts = {}
        return
    end
    local root = game.Players.LocalPlayer.Character.HumanoidRootPart
    -- Tamanho reduzido para 2.5 studs (bem rente ao corpo)
    local offsets = {
        {Vector3.new(2.5, 0, 0), Vector3.new(1, 8, 5)},   -- Dir
        {Vector3.new(-2.5, 0, 0), Vector3.new(1, 8, 5)},  -- Esq
        {Vector3.new(0, 0, 2.5), Vector3.new(5, 8, 1)},   -- Frente
        {Vector3.new(0, 0, -2.5), Vector3.new(5, 8, 1)},  -- Atrás
        {Vector3.new(0, 4.5, 0), Vector3.new(5, 1, 5)}    -- Teto
    }
    for _, info in pairs(offsets) do
        local p = Instance.new("Part", workspace)
        p.Size = info[2]
        p.CanCollide = true
        p.Transparency = 0.8
        p.Color = Color3.fromRGB(0, 255, 255)
        local weld = Instance.new("WeldConstraint", p)
        p.Position = root.Position + info[1]
        weld.Part0 = p
        weld.Part1 = root
        table.insert(ShieldParts, p)
    end
end)

-- 4. BALA INFINITA METRALHADORA (MODO BRUTO)
_G.InfAmmo = false
CreateBtn(ScrollingFrame, "Metralhadora Inf", Color3.fromRGB(200, 0, 0), function()
    _G.InfAmmo = not _G.InfAmmo
    task.spawn(function()
        while _G.InfAmmo do
            local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                -- Força o disparo sem delay e sem recarregar
                pcall(function()
                    -- Procura variáveis de controle de tiro
                    for _, v in pairs(tool:GetDescendants()) do
                        if v.Name:lower():find("ammo") or v.Name:lower():find("clip") or v.Name:lower():find("count") then
                            v.Value = 999
                        elseif v.Name:lower():find("delay") or v.Name:lower():find("firerate") or v.Name:lower():find("cooldown") then
                            v.Value = 0 -- Metralhadora pura
                        elseif v.Name:lower():find("reload") then
                            v.Value = false -- Tira o tempo de recarga
                        end
                    end
                end)
            end
            task.wait(0.1)
        end
    end)
end)

-- 5. FUNÇÃO TUDO (SCANNER PROFUNDO DE ARMAS)
local function GetGameWeapons()
    for _, v in pairs(WeaponFrame:GetChildren()) do if v:IsA("ScrollingFrame") then v:Destroy() end end
    local S = Instance.new("ScrollingFrame", WeaponFrame)
    S.Size = UDim2.new(1, 0, 1, 0)
    S.CanvasSize = UDim2.new(0, 0, 15, 0) -- Muita rolagem
    S.BackgroundTransparency = 1
    Instance.new("UIListLayout", S)
    
    -- Busca em locais onde o jogo esconde as armas (ServerStorage/Lighting/Folder)
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Tool") and v.Name ~= "Lantern" and v.Name ~= "Flashlight" then
            CreateBtn(S, v.Name, Color3.fromRGB(40,40,40), function()
                local c = v:Clone()
                c.Parent = game.Players.LocalPlayer.Backpack
            end)
        end
    end
end

CreateBtn(ScrollingFrame, "TUDO (Armas)", Color3.fromRGB(0, 80, 255), function()
    WeaponFrame.Visible = not WeaponFrame.Visible
    GetGameWeapons() -- Atualiza a lista na hora que abre
end)
