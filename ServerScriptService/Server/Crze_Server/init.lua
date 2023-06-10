local player_service = game:GetService("Players")
local shared = game:GetService("ReplicatedStorage")
local src = script:WaitForChild("src")
local pkgs = shared:WaitForChild("Packages")
local crze = pkgs:WaitForChild("Crze")
local remotes = crze:WaitForChild("Events")
local CR = remotes:WaitForChild("Character")

local module = {
	Enums = require(src:WaitForChild("Enums"));
	Character = require(src:WaitForChild("Character"));
	Configurations = require(src:WaitForChild("Configurations"));
	Players = {}
}

if module.Configurations.Startup then
	player_service.CharacterAutoLoads = false

	player_service.PlayerAdded:Connect(function(player)
		player:LoadCharacter()
		local character = module.Character.new({
			PLAYER = player,
			CAMERA_VIEW = module.Configurations.Camera_View or 14,
			CAMERA_HEIGHT_OFFSET = module.Configurations.Camera_Height_Offset or 0
		})
		module.Players[player.Name] = character

		wait(3)
		CR:FireClient(player, "SetObject", character, getmetatable(character))
		CR:FireClient(player, "Enable")
	end)
end

return module