--// KYYSTARBOYZZ BOOMBOX - ANDROID & PC FIXED

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local player = Players.LocalPlayer

--// SAFE LOAD ORION
local OrionLib
pcall(function()
    OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

if not OrionLib then
    warn("Orion gagal load. Pastikan executor support HttpGet.")
    return
end

--// WINDOW
local Window = OrionLib:MakeWindow({
	Name = "KYYSTARBOYZZ BOOMBOX",
	HidePremium = false,
	SaveConfig = false,
	IntroEnabled = false
})

local MainTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local InfoTab = Window:MakeTab({
	Name = "Info",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

--// VARIABLES
local playlist = {}
local index = 1
local volume = 5
local antiSit = false

--// GET BOOMBOX
local function getSound()
	local char = player.Character
	if not char then return nil end

	for _,tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			local handle = tool:FindFirstChild("Handle")
			if handle then
				local sound = handle:FindFirstChildWhichIsA("Sound")
				if sound then
					return sound
				end
			end
		end
	end
	return nil
end

--// PLAY
local function playCurrent()
	local sound = getSound()
	if not sound then
		OrionLib:MakeNotification({
			Name = "Error",
			Content = "Boombox tidak ditemukan di character",
			Time = 3
		})
		return
	end

	if playlist[index] then
		sound.SoundId = "rbxassetid://"..playlist[index]
		sound.Volume = volume
		sound:Play()
	end
end

--// ADD MUSIC
MainTab:AddTextbox({
	Name = "Masukkan Music ID",
	Default = "",
	TextDisappear = false,
	Callback = function(text)
		local id = tonumber(text)
		if not id then
			OrionLib:MakeNotification({
				Name = "Invalid",
				Content = "Music ID harus angka",
				Time = 3
			})
			return
		end

		table.insert(playlist, id)
		index = #playlist
		playCurrent()

		OrionLib:MakeNotification({
			Name = "Berhasil",
			Content = "Music ditambahkan",
			Time = 3
		})
	end
})

--// BUTTONS
MainTab:AddButton({
	Name = "Play",
	Callback = function()
		playCurrent()
	end
})

MainTab:AddButton({
	Name = "Previous",
	Callback = function()
		if #playlist == 0 then return end
		index = math.max(1, index - 1)
		playCurrent()
	end
})

MainTab:AddButton({
	Name = "Next",
	Callback = function()
		if #playlist == 0 then return end
		index = math.min(#playlist, index + 1)
		playCurrent()
	end
})

--// VOLUME
MainTab:AddSlider({
	Name = "Volume",
	Min = 0,
	Max = 10,
	Default = 5,
	Increment = 1,
	ValueName = "",
	Callback = function(val)
		volume = val
		local sound = getSound()
		if sound then
			sound.Volume = volume
		end
	end
})

--// ANTI SIT
MainTab:AddToggle({
	Name = "Anti Sit",
	Default = false,
	Callback = function(state)
		antiSit = state
	end
})

--// PERFORMANCE INFO
local perfLabel = InfoTab:AddParagraph("Performance", "Loading...")

RunService.RenderStepped:Connect(function(dt)
	local fps = math.floor(1/dt)
	local ping = 0

	pcall(function()
		ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
	end)

	perfLabel:Set("Performance",
		"FPS : "..fps..
		"\nPing : "..ping.." ms"..
		"\nPlaylist : "..#playlist
	)
end)

--// ANTISIT LOOP
RunService.Heartbeat:Connect(function()
	if antiSit and player.Character then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Sit = false
		end
	end
end)

OrionLib:Init()
