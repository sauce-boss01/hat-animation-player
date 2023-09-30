
--NOTE: this script will only work on some games that havent updated the character deletions (fuck roblox updates)
--It will only work if it prints out "Enum.RejectCharacterDeletions.Default true" when executed

--Required Hats:
--https://www.roblox.com/catalog/62724852/Chestnut-Bun
--https://www.roblox.com/catalog/451220849/Lavender-Updo
--https://www.roblox.com/catalog/63690008/Pal-Hair
--https://www.roblox.com/catalog/62234425/Brown-Hair

--Some Ids:
--12548488061 - default dance
--12548495363 - take the L
--12548510251 - i don't know
--12548549243 - whip
--12548572014 - orange justice
--12548588316 - recover

print(gethiddenproperty(game:GetService("Workspace"), "RejectCharacterDeletions"))

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if not getgenv().Network then
	getgenv().Network = {
		BaseParts = {};
		FakeConnections = {};
		Connections = {};
		Output = {
			Enabled = true;
			Prefix = "[NETWORK] ";
			Send = function(Type,Output,BypassOutput)
				if typeof(Type) == "function" and (Type == print or Type == warn or Type == error) and typeof(Output) == "string" and (typeof(BypassOutput) == "nil" or typeof(BypassOutput) == "boolean") then
					if Network["Output"].Enabled == true or BypassOutput == true then
						Type(Network["Output"].Prefix..Output);
					end;
				elseif Network["Output"].Enabled == true then
					error(Network["Output"].Prefix.."Output Send Error : Invalid syntax.");
				end;
			end;
		};
		CharacterRelative = false;
	}

	Network["Output"].Send(print,": Loading.")
	Network["Velocity"] = Vector3.new(14.46262424,14.46262424,14.46262424); --exactly 25.1 magnitude
	Network["RetainPart"] = function(Part,ReturnFakePart) --function for retaining ownership of unanchored parts
		assert(typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(workspace),Network["Output"].Prefix.."RetainPart Error : Invalid syntax: Arg1 (Part) must be a BasePart which is a descendant of workspace.")
		assert(typeof(ReturnFakePart) == "boolean" or typeof(ReturnFakePart) == "nil",Network["Output"].Prefix.."RetainPart Error : Invalid syntax: Arg2 (ReturnFakePart) must be a boolean or nil.")
		if not table.find(Network["BaseParts"],Part) then
			if Network.CharacterRelative == true then
				local Character = LocalPlayer.Character
				if Character and Character.PrimaryPart then
					local Distance = (Character.PrimaryPart.Position-Part.Position).Magnitude
					if Distance > 1000 then
						Network["Output"].Send(warn,"RetainPart Warning : PartOwnership not applied to BasePart "..Part:GetFullName()..", as it is more than "..gethiddenproperty(LocalPlayer,"MaximumSimulationRadius").." studs away.")
						return false
					end
				else
					Network["Output"].Send(warn,"RetainPart Warning : PartOwnership not applied to BasePart "..Part:GetFullName()..", as the LocalPlayer Character's PrimaryPart does not exist.")
					return false
				end
			end
			table.insert(Network["BaseParts"],Part)
			Part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
			Network["Output"].Send(print,"PartOwnership Output : PartOwnership applied to BasePart "..Part:GetFullName()..".")
			if ReturnFakePart == true then
				return FakePart
			end
		else
			Network["Output"].Send(warn,"RetainPart Warning : PartOwnership not applied to BasePart "..Part:GetFullName()..", as it already active.")
			return false
		end
	end

	Network["RemovePart"] = function(Part) --function for removing ownership of unanchored part
		assert(typeof(Part) == "Instance" and Part:IsA("BasePart"),Network["Output"].Prefix.."RemovePart Error : Invalid syntax: Arg1 (Part) must be a BasePart.")
		local Index = table.find(Network["BaseParts"],Part)
		if Index then
			table.remove(Network["BaseParts"],Index)
			Network["Output"].Send(print,"RemovePart Output: PartOwnership removed from BasePart "..Part:GetFullName()..".")
		else
			Network["Output"].Send(warn,"RemovePart Warning : BasePart "..Part:GetFullName().." not found in BaseParts table.")
		end
	end

	Network["SuperStepper"] = Instance.new("BindableEvent") --make super fast event to connect to
	for _,Event in pairs({RunService.Stepped,RunService.Heartbeat}) do
		Event:Connect(function()
			return Network["SuperStepper"]:Fire(Network["SuperStepper"],tick())
		end)
	end

	Network["PartOwnership"] = {};
	Network["PartOwnership"]["PreMethodSettings"] = {};
	Network["PartOwnership"]["Enabled"] = false;
	Network["PartOwnership"]["Enable"] = coroutine.create(function() --creating a thread for network stuff
		if Network["PartOwnership"]["Enabled"] == false then
			Network["PartOwnership"]["Enabled"] = true --do cool network stuff before doing more cool network stuff
			Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus = LocalPlayer.ReplicationFocus
			LocalPlayer.ReplicationFocus = workspace
			Network["PartOwnership"]["PreMethodSettings"].SimulationRadius = gethiddenproperty(LocalPlayer,"SimulationRadius")
			Network["PartOwnership"]["Connection"] = Network["SuperStepper"].Event:Connect(function() --super fast asynchronous loop
				sethiddenproperty(LocalPlayer,"SimulationRadius",1/0)
				for _,Part in pairs(Network["BaseParts"]) do --loop through parts and do network stuff
					coroutine.wrap(function()
						if Part:IsDescendantOf(workspace) then
							if Network.CharacterRelative == true then
								local Character = LocalPlayer.Character;
								if Character and Character.PrimaryPart then
									local Distance = (Character.PrimaryPart.Position - Part.Position).Magnitude
									if Distance > 1000 then
										Network["Output"].Send(warn,"PartOwnership Warning : PartOwnership not applied to BasePart "..Part:GetFullName()..", as it is more than "..gethiddenproperty(LocalPlayer,"MaximumSimulationRadius").." studs away.")
										Lost = true;
										Network["RemovePart"](Part)
									end
								else
									Network["Output"].Send(warn,"PartOwnership Warning : PartOwnership not applied to BasePart "..Part:GetFullName()..", as the LocalPlayer Character's PrimaryPart does not exist.")
								end
							end
							Part.Velocity = Network["Velocity"]+Vector3.new(0,math.cos(tick()*10)/100,0) --keep network by sending physics packets of 30 magnitude + an everchanging addition in the y level so roblox doesnt get triggered and fuck your ownership
						else
							Network["RemovePart"](Part)
						end
					end)()
				end
			end)
			Network["Output"].Send(print,"PartOwnership Output : PartOwnership enabled.")
		else
			Network["Output"].Send(warn,"PartOwnership Output : PartOwnership already enabled.")
		end
	end)
	Network["PartOwnership"]["Disable"] = coroutine.create(function()
		if Network["PartOwnership"]["Connection"] then
			Network["PartOwnership"]["Connection"]:Disconnect()
			LocalPlayer.ReplicationFocus = Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus
			sethiddenproperty(LocalPlayer,"SimulationRadius",Network["PartOwnership"]["PreMethodSettings"].SimulationRadius)
			Network["PartOwnership"]["PreMethodSettings"] = {}
			for _,Part in pairs(Network["BaseParts"]) do
				Network["RemovePart"](Part)
			end
			Network["PartOwnership"]["Enabled"] = false
			Network["Output"].Send(print,"PartOwnership Output : PartOwnership disabled.")
		else
			Network["Output"].Send(warn,"PartOwnership Output : PartOwnership already disabled.")
		end
	end)
	Network["Output"].Send(print,": Loaded.")
end

coroutine.resume(Network["PartOwnership"]["Enable"])
Network.CharacterRelative = false

Player = game.Players.LocalPlayer
OldChar = Player.Character

for i,v in pairs(OldChar.Humanoid:GetPlayingAnimationTracks()) do
	v:Stop()
end

OldChar.Archivable = true

NewChar = OldChar:Clone()
NewChar.Parent = workspace

NewChar.Name = "New"

NewChar.Head.face:Destroy()

for i,v in pairs(NewChar:GetDescendants()) do
	if v:IsA("Part") then
		v.Transparency = 1
	end
end

vbreak = false


OldChar.Torso["Left Shoulder"]:Destroy()
OldChar.Torso["Right Shoulder"]:Destroy()
OldChar.Torso["Left Hip"]:Destroy()
OldChar.Torso["Right Hip"]:Destroy()


function rotate(X,Y,Z)
	return CFrame.Angles(math.rad(X),math.rad(Y),math.rad(Z))
end

function Join(Hat,Part,Offset,Rotation,Mesh)
	if Mesh == false then Hat.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy() end
	Hat.Handle.AccessoryWeld:Destroy()
	local method = Instance.new("RopeConstraint",OldChar)
	method.Length = math.huge
	method.Attachment0 = Instance.new("Attachment",OldChar.Head)
	method.Attachment1 = Instance.new("Attachment",Hat.Handle)
	coroutine.wrap(function()
		while task.wait() do
			Hat.Handle.CFrame = (Part.CFrame + Part.CFrame.LookVector * Offset.Z + Part.CFrame.RightVector * Offset.X + Part.CFrame.UpVector * Offset.Y) * Rotation
			if vbreak == true then break end
		end
	end)()
end

Join(
	OldChar["Pal Hair"], -- the Accessory
	NewChar["Left Arm"], -- Part to attach to
	Vector3.new(0,0,0), -- offset
	rotate(90,0,0), -- Rotation
	false -- Keep mesh
)

Join(
	OldChar["Hat1"], -- the Accessory
	NewChar["Right Arm"], -- Part to attach to
	Vector3.new(0,0,0), -- offset
	rotate(90,0,0), -- Rotation
	false -- Keep mesh
)

Join(
	OldChar["Pink Hair"], -- the Accessory
	NewChar["Right Leg"], -- Part to attach to
	Vector3.new(0,0,0), -- offset
	rotate(90,0,0), -- Rotation
	false -- Keep mesh
)

Join(
	OldChar["LavanderHair"], -- the Accessory
	NewChar["Left Leg"], -- Part to attach to
	Vector3.new(0,0,0), -- offset
	rotate(90,0,0), -- Rotation
	false -- Keep mesh
)

Player.Character = NewChar

NewChar.Animate.Disabled = true
NewChar.Animate.Disabled = false
OldChar.Animate.Disabled = true


for i,v in next, OldChar:GetDescendants() do
	if v:IsA("BasePart") and v.Name ~="HumanoidRootPart" then 
		Network.RetainPart(v)
	end
end

game:GetService("RunService").Stepped:Connect(function()
	if vbreak == true then return end
	if OldChar:FindFirstChild("Torso") == nil then return end
	OldChar.Torso.CanCollide = false
	OldChar.Head.CanCollide = false
end)


coroutine.wrap(function()
	while task.wait() do
		OldChar.HumanoidRootPart.CFrame = NewChar.Torso.CFrame

		if NewChar.Humanoid.Health == 0 then
			Player.Character = OldChar
			OldChar.Head:Destroy()
			vbreak = true
			break
		end

	end
end)()


local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local aniid = Instance.new("TextBox")
local Looped = Instance.new("TextButton")
local Play = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")


ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(116, 116, 116)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 5
Frame.Position = UDim2.new(0.322779924, 0, 0.720987678, 0)
Frame.Size = UDim2.new(0.353667945, 0, 0.177777782, 0)
Frame.Draggable = true
Frame.Active = true

aniid.Name = "aniid"
aniid.Parent = Frame
aniid.BackgroundColor3 = Color3.fromRGB(84, 84, 84)
aniid.BorderColor3 = Color3.fromRGB(0, 0, 0)
aniid.BorderSizePixel = 2
aniid.Position = UDim2.new(0.0393013097, 0, 0.465277791, 0)
aniid.Size = UDim2.new(0.624454141, 0, 0.451388896, 0)
aniid.Font = Enum.Font.SourceSans
aniid.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
aniid.PlaceholderText = "Animation Id"
aniid.Text = ""
aniid.TextColor3 = Color3.fromRGB(0, 0, 0)
aniid.TextScaled = true
aniid.TextSize = 14.000
aniid.TextWrapped = true

Looped.Name = "Looped"
Looped.Parent = Frame
Looped.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Looped.BorderColor3 = Color3.fromRGB(0, 0, 0)
Looped.BorderSizePixel = 2
Looped.Position = UDim2.new(0.698689938, 0, 0.0972222164, 0)
Looped.Size = UDim2.new(0.281659395, 0, 0.319444448, 0)
Looped.Font = Enum.Font.SourceSans
Looped.Text = "Loop"
Looped.TextColor3 = Color3.fromRGB(0, 0, 0)
Looped.TextScaled = true
Looped.TextSize = 14.000
Looped.TextWrapped = true

Play.Name = "Play"
Play.Parent = Frame
Play.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Play.BorderColor3 = Color3.fromRGB(0, 0, 0)
Play.BorderSizePixel = 2
Play.Position = UDim2.new(0.698689938, 0, 0.597222209, 0)
Play.Size = UDim2.new(0.281659395, 0, 0.319444448, 0)
Play.Font = Enum.Font.SourceSans
Play.Text = "Play"
Play.TextColor3 = Color3.fromRGB(0, 0, 0)
Play.TextScaled = true
Play.TextSize = 14.000
Play.TextWrapped = true

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.Position = UDim2.new(0.0240174681, 0, 0.0625, 0)
TextLabel.Size = UDim2.new(0.639737964, 0, 0.354166657, 0)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Rouxhavers animation player"
TextLabel.TextColor3 = Color3.fromRGB(197, 197, 197)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

Islooping = false

Looped.MouseButton1Up:Connect(function()
	if Islooping == false then do
			Islooping = true
			Looped.BackgroundColor3 = Color3.fromRGB(0,255,0)
		end else
		Islooping = false
		Looped.BackgroundColor3 = Color3.fromRGB(255,0,0)
	end
end)


local TweenService = game:GetService("TweenService")

function tween(Part, Target, Time)
	local tweenInfo = TweenInfo.new(Time,Enum.EasingStyle.Linear)
	local Tween = TweenService:Create(Part, tweenInfo, {
		Transform = Target,
	})
	Tween:Play()
end






Playing = false

Play.MouseButton1Up:Connect(function()
	if Playing == false then
		Play.BackgroundColor3 = Color3.fromRGB(0,255,0)
		Playing = true
		--NewChar.HumanoidRootPart.Anchored = true

		local Frames = nil

		local obj1 = game:GetObjects("rbxassetid://"..aniid.Text)
		for i,v in pairs(obj1) do
			Frames = v:GetChildren()
		end

		table.sort(Frames, function(a,b)
			return a.Time < b.Time
		end)

		NewChar.Animate.Disabled = true

		for i,v in pairs(NewChar.Humanoid:GetPlayingAnimationTracks()) do
			v:Stop()
		end

		while true do
			local Last_time = 0

			for i,Frame in pairs(Frames) do

				local TS = Frame:FindFirstChild("Torso", true)
				if TS and TS.Weight == 1 then
					tween(NewChar.HumanoidRootPart["RootJoint"], TS.CFrame, Frame.Time - Last_time)
				end

				local LA = Frame:FindFirstChild("Left Arm", true)
				if LA and LA.Weight == 1 then
					tween(NewChar.Torso["Left Shoulder"], LA.CFrame, Frame.Time - Last_time)
				end

				local RA = Frame:FindFirstChild("Right Arm", true)
				if RA and RA.Weight == 1 then
					tween(NewChar.Torso["Right Shoulder"], RA.CFrame, Frame.Time - Last_time)
				end

				local RL = Frame:FindFirstChild("Right Leg", true)
				if RL and RL.Weight == 1 then
					tween(NewChar.Torso["Right Hip"], RL.CFrame, Frame.Time - Last_time)
				end

				local LL = Frame:FindFirstChild("Left Leg", true)
				if LL and LL.Weight == 1 then
					tween(NewChar.Torso["Left Hip"], LL.CFrame, Frame.Time - Last_time)
				end

				wait(Frame.Time - Last_time)
				Last_time = Frame.Time
			end
			if Islooping == false then
				break
			end
		end

		NewChar.Animate.Disabled = false
		Playing = false
		Play.BackgroundColor3 = Color3.fromRGB(255,0,0)
	end
end)
