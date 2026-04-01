local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Limpeza de UI antiga
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "RV_Ultimate_Yuri" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "RV_Ultimate_Yuri"

local State = {
    FlightActive = false,
    BrutoActive = false,
    Height = 0,
    FlightSpeed = 100 -- Velocidade estável no ar
}

-- BOTÃO MESTRE "V" (DESIGN DISCRETO)
local Master = Instance.new("TextButton", ScreenGui)
Master.Size = UDim2.new(0, 50, 0, 50)
Master.Position = UDim2.new(0.1, 0, 0.5, 0)
Master.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Master.Text = "V"
Master.TextColor3 = Color3.new(1,1,1)
Master.Font = Enum.Font.GothamBold
Master.Draggable = true
Instance.new("UICorner", Master).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", Master).Color = Color3.new(1,1,1)

local Main = Instance.new("Frame", Master)
Main.Size = UDim2.new(0, 200, 0, 180)
Main.Position = UDim2.new(1.2, 0, 0, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Visible = false
Instance.new("UICorner", Main)

Master.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- --- FUNÇÃO VOO (Lógica V4 - OK) ---
local FlightBtn = Instance.new("TextButton", Main)
FlightBtn.Size = UDim2.new(0, 180, 0, 35)
FlightBtn.Position = UDim2.new(0.5, -90, 0, 15)
FlightBtn.Text = "VOO: OFF"
FlightBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FlightBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", FlightBtn)

local SliderFrame = Instance.new("Frame", Main)
SliderFrame.Size = UDim2.new(0, 160, 0, 6)
SliderFrame.Position = UDim2.new(0.5, -80, 0, 65)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderFrame.Visible = false
Instance.new("UICorner", SliderFrame)

local SliderBtn = Instance.new("TextButton", SliderFrame)
SliderBtn.Size = UDim2.new(0, 18, 0, 18)
SliderBtn.Position = UDim2.new(0, 0, 0.5, -9)
SliderBtn.Text = ""
Instance.new("UICorner", SliderBtn)

FlightBtn.MouseButton1Click:Connect(function()
    local seat = LocalPlayer.Character and LocalPlayer.Character.Humanoid.SeatPart
    if not State.FlightActive and seat then
        State.Height = seat.Position.Y
        SliderBtn.Position = UDim2.new(math.clamp(State.Height/1000, 0, 1), -9, 0.5, -9)
    end
    State.FlightActive = not State.FlightActive
    SliderFrame.Visible = State.FlightActive
    FlightBtn.Text = State.FlightActive and "VOO: ON" or "VOO: OFF"
    FlightBtn.BackgroundColor3 = State.FlightActive and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(45, 45, 45)
end)

-- Lógica Slider Altura
local dragging = false
SliderBtn.MouseButton1Down:Connect(function() dragging = true end)
game:GetService("UserInputService").InputEnded:Connect(function() dragging = false end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
        SliderBtn.Position = UDim2.new(pos, -9, 0.5, -9)
        State.Height = pos * 1000
    end
end)

-- --- FUNÇÃO BRUTO (Lógica V13 - OK) ---
local BrutoBtn = Instance.new("TextButton", Main)
BrutoBtn.Size = UDim2.new(0, 180, 0, 35)
BrutoBtn.Position = UDim2.new(0.5, -90, 0, 120)
BrutoBtn.Text = "BRUTO: OFF"
BrutoBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
BrutoBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", BrutoBtn)

BrutoBtn.MouseButton1Click:Connect(function()
    State.BrutoActive = not State.BrutoActive
    BrutoBtn.Text = State.BrutoActive and "BRUTO: ON" or "BRUTO: OFF"
    BrutoBtn.BackgroundColor3 = State.BrutoActive and Color3.fromRGB(255, 50, 0) or Color3.fromRGB(45, 45, 45)
end)

-- --- LOOP DE PROCESSAMENTO (HEARTBEAT) ---
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local seat = char and char.Humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        local carRoot = seat.Parent:FindFirstChild("DriveSeat") or seat
        
        -- PRIORIDADE 1: VOO (Lógica V4 estável)
        if State.FlightActive then
            carRoot.CFrame = CFrame.new(carRoot.Position.X, State.Height, carRoot.Position.Z) * CFrame.Angles(0, math.rad(seat.Orientation.Y), 0)
            carRoot.AssemblyLinearVelocity = carRoot.CFrame.LookVector * (seat.ThrottleFloat * State.FlightSpeed)
            carRoot.AssemblyAngularVelocity = Vector3.new(0, seat.SteerFloat * -3, 0)
            
        -- PRIORIDADE 2: BRUTO (Lógica V13 estável)
        elseif State.BrutoActive then
            -- Sucção Magnética ao Solo
            local ray = workspace:Raycast(carRoot.Position, Vector3.new(0, -15, 0))
            if ray then
                local dist = (carRoot.Position - ray.Position).Magnitude
                if dist > 3.6 then
                    carRoot.AssemblyLinearVelocity = Vector3.new(carRoot.AssemblyLinearVelocity.X, -25, carRoot.AssemblyLinearVelocity.Z)
                end
            end

            -- Aceleração 60% via Vetor (Só nos pedais)
            if seat.ThrottleFloat ~= 0 then
                local forward = carRoot.CFrame.LookVector
                if carRoot.AssemblyLinearVelocity.Magnitude < 190 then
                    carRoot.AssemblyLinearVelocity = carRoot.AssemblyLinearVelocity + (forward * seat.ThrottleFloat * 4)
                end
            end

            -- Anti-Tombo Suave (Lerp)
            local currentY = carRoot.Orientation.Y
            carRoot.CFrame = carRoot.CFrame:Lerp(CFrame.new(carRoot.Position) * CFrame.Angles(0, math.rad(currentY), 0), 0.15)
        end
    end
end)
