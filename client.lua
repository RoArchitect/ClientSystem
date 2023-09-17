local FrameworkModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("InitMain"))
local UserInputService = game:GetService("UserInputService")

local NewInstance = FrameworkModule.NewInstance;
local Get = FrameworkModule.Get;
local Services = FrameworkModule.Services;
local PlayerInfo = FrameworkModule.PlayerInfo();

local TweenService = Services.TweenService;
local ReplicatedStorage = Services.ReplicatedStorage;

local RunAnim = NewInstance("Animation","Run",script)
RunAnim.AnimationId = "rbxassetid://14739742819"

local Thread = task.spawn

local TweenInfo_Indicator = TweenInfo.new(
    0.3,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.In,
    0,
    false,
    0
)

local Players = Services.Players;
local Player = Players.LocalPlayer;
Services.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

---------------------------------------------------------

local Animator = PlayerInfo.Humanoid:WaitForChild("Animator");
local RunTrack = Animator:LoadAnimation(RunAnim);

local RunSpeed = 21.5;
local WalkSpeed = 16;

local Running = false

Services.UserInputService.InputBegan:Connect(function(Input , GP)
    if Input.KeyCode == Enum.KeyCode.LeftShift and not GP then

        if PlayerInfo.Humanoid.MoveDirection == Vector3.new(0,0,0) then return end
        if PlayerInfo.Humanoid.Health == 0 then return end
        RunTrack:Play()
        Running = true
        PlayerInfo.Humanoid.WalkSpeed = RunSpeed

    end
end)

Services.UserInputService.InputEnded:Connect(function(Input , GP)
    if Input.KeyCode == Enum.KeyCode.LeftShift and not GP then
        
        RunTrack:Stop()
        Running = false
        PlayerInfo.Humanoid.WalkSpeed = WalkSpeed

    end
end)

Thread(function()
    while task.wait() do
        if Running == true and PlayerInfo.Humanoid.MoveDirection == Vector3.new(0,0,0) or Running == true and PlayerInfo.Humanoid.Health == 0 then
            RunTrack:Stop()
            Running = false
            PlayerInfo.Humanoid.WalkSpeed = WalkSpeed
        end
    end
end)

local _workspace = workspace
local _game = game
local Camera = _workspace.CurrentCamera

local sensitivity = 0.1 
local deceleration = 10
local cam = workspace.Camera
local rotate = Vector3.zero
local max = math.max
local rad = math.pi/180

local mouseMove = Enum.UserInputType.MouseMovement
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == mouseMove then
		rotate -= input.Delta*sensitivity
	end    
end)

local Mouse = Player:GetMouse()
Services.RunService.RenderStepped:Connect(function(dt)
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter;
    UserInputService.MouseIconEnabled = true;
   -- Camera.CFrame = Camera.CFrame * CFrame.new(2,0,0)
    rotate *= 1-dt*deceleration
	cam.CFrame *= CFrame.fromOrientation(rotate.Y*rad,rotate.X*rad,0) * CFrame.new(2,0,0)
end)

local SelectedItem_Instance = nil
local SelectedItem_Info = nil
local LastIndicator = nil

-- // FINDING SELECTED ITEM
Thread(function()
    while task.wait() do
        local Target = Mouse.Target
        if Target and Target.Parent then

            if Target:FindFirstAncestor("Items") then

                local Info = Target:FindFirstChild("Info" , true) or Target.Parent:FindFirstChild("Info" , true)
                if Info and Info:IsA("Folder") then
                    local Rarity = Info.Rarity
                    local ItemName = Info.ItemName
                    
                    SelectedItem_Instance = Info.Parent.Parent
                    SelectedItem_Info = Info
                end

            else
                SelectedItem_Instance = nil
                SelectedItem_Info = nil
            end

        else
            SelectedItem_Instance = nil
            SelectedItem_Info = nil
        end
    end
end)

local MarkItem = ReplicatedStorage:WaitForChild("MarkItem")

local InteractKeybind = Enum.KeyCode.F

--// LOADING SELECTED ITEM UI
Thread(function()
    while task.wait() do
        if SelectedItem_Instance and SelectedItem_Info then
            local Rarity = SelectedItem_Info.Rarity
            local ItemName = SelectedItem_Info.ItemName
            local __MAIN__ = SelectedItem_Instance:FindFirstChild("__MAIN__" , true)
            
            if not __MAIN__:FindFirstChildWhichIsA("BillboardGui") then
                
                local Indicator = MarkItem:Clone()
                Indicator.Parent = __MAIN__
                
                local Tween = TweenService:Create(
                    Indicator:WaitForChild("Back"),
                    TweenInfo_Indicator,
                    {
                        Transparency = 0.6
                    }
                )
                Tween:Play()

                LastIndicator = Indicator
            end
            
        end

        if not SelectedItem_Instance and not SelectedItem_Info then
            if LastIndicator then
                local Tween = TweenService:Create(
                    LastIndicator:WaitForChild("Back"),
                    TweenInfo_Indicator,
                    {
                        Transparency = 1
                    }
                )

                Tween:Play()
                Tween.Completed:Wait()

                LastIndicator:Destroy()
                LastIndicator = nil
            end        
        end
    end
end)
