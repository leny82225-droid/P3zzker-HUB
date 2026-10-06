-- DELTA GUI AUTO JOB MAXGEN
-- Owner: brukontop

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------
-- 1. PENGATURAN DATA MAP (Silakan isi nama objek di sini)
---------------------------------------------------------
local MAP_DATA = {
    -- Nama/Path tempat pendaftaran job merah
    JobStartName = "BedilPusat/ActiveJobs", 
    
    -- Nama/Path tanda arah kuning / destination
    TargetYellowName = "DeliveryBeam/DummyTarget_11684197545/Target", 
    
    -- Nama RemoteEvent / Notifikasi jika ada
    NotificationName = "InfoUI/INFO/Textlabel"
}

---------------------------------------------------------
-- 2. GUI MENGAMBANG (DELTA STYLE)
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrukOntop_FloatingGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 110)
MainFrame.Active = true
MainFrame.Draggable = true -- Membuat GUI bisa digeser/mengambang

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local OwnerLabel = Instance.new("TextLabel")
OwnerLabel.Parent = MainFrame
OwnerLabel.Text = "OWNER: BRUKONTOP"
OwnerLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
OwnerLabel.Size = UDim2.new(1, 0, 0, 30)
OwnerLabel.Font = Enum.Font.SourceSansBold
OwnerLabel.TextSize = 12

local BtnAutoJob = Instance.new("TextButton")
BtnAutoJob.Parent = MainFrame
BtnAutoJob.Text = "AUTO JOB MAXGEN"
BtnAutoJob.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnAutoJob.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnAutoJob.Position = UDim2.new(0.1, 0, 0.4, 0)
BtnAutoJob.Size = UDim2.new(0.8, 0, 0.45, 0)
BtnAutoJob.Font = Enum.Font.SourceSansBold
BtnAutoJob.TextSize = 11

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = BtnAutoJob

---------------------------------------------------------
-- 3. LOGIKA DAN FUNGSI AUTO JOB
---------------------------------------------------------
local isRunning = false

-- Noclip Karakter & Mobil (Tembus Tembok)
local function applyNoclip(targetModel)
    if not targetModel then return end
    for _, part in pairs(targetModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Pergerakan Mulus (Tweening)
local function smoothMove(modelOrPart, targetCFrame, speed)
    local rootPart = modelOrPart:IsA("Model") and modelOrPart.PrimaryPart or modelOrPart
    if not rootPart then return end
    
    applyNoclip(modelOrPart)
    
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / (speed or 30) -- Kecepatan disesuaikan agar stabil
    
    local tween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- Cari Kendaraan Player
local function getPlayerVehicle()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local seat = char.Humanoid.SeatPart
        if seat and seat.Parent then
            return seat.Parent -- Model mobil
        end
    end
    return nil
end

-- Alur Kerja Auto Job Loop
local function startAutoJobLoop()
    task.spawn(function()
        while isRunning do
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart")
            
            -- Langkah 1: Jalan ke Lokasi Job Merah Maxgen
            local jobStartObj = Workspace:FindFirstChild(MAP_DATA.JobStartName, true)
            if jobStartObj then
                smoothMove(char, jobStartObj:GetPivot(), 25)
                task.wait(1)
            end
            
            -- Langkah 2: Cek & Naik ke Mobil
            local vehicle = getPlayerVehicle()
            if not vehicle then
                -- Tunggu sebentar sampai mobil spawn / naik manual
                task.wait(2)
                vehicle = getPlayerVehicle()
            end
            
            -- Langkah 3: Auto Driver ke Tanda Kuning
            local targetYellow = Workspace:FindFirstChild(MAP_DATA.TargetYellowName, true)
            if targetYellow then
                local targetCF = targetYellow:GetPivot()
                
                if vehicle then
                    -- Pergerakan mobil terbatas (agak terangkat sedikit agar tidak masuk sungai)
                    smoothMove(vehicle, targetCF + Vector3.new(0, 2, 0), 35)
                else
                    -- Jika tidak ada mobil, jalan dengan karakter
                    smoothMove(char, targetCF, 25)
                end
                
                -- Langkah 4: Tunggu Notifikasi / Selesai
                task.wait(3) -- Jeda penanganan notifikasi
                
                -- Langkah 5: Balik ke Tanda Kuning / Poin Akhir jika diperlukan
                if vehicle and vehicle.Parent then
                    smoothMove(vehicle, targetCF, 35)
                end
            end
            
            -- Jika mobil hilang/respawn, loop akan otomatis mengulang dari awal (jalan ke job)
            task.wait(2)
        end
    end)
end

---------------------------------------------------------
-- 4. TOGGLE BUTTON EVENT
---------------------------------------------------------
BtnAutoJob.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        BtnAutoJob.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        BtnAutoJob.Text = "STATUS: ON"
        startAutoJobLoop()
    else
        BtnAutoJob.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnAutoJob.Text = "AUTO JOB MAXGEN"
    end
end)
