local Character = {}
local instance = {}

local player_service = game:GetService("Players");
local shared = game:GetService("ReplicatedStorage");
local pkgs = shared.Packages;
local Crze = pkgs.Crze
local character_folder = Crze:WaitForChild("Characters")

local remotes = Crze:WaitForChild("Events")
local CR = remotes:WaitForChild("Character") -- Character Remote
local MR = remotes:WaitForChild("Move")

function Character.new(Properties: table)
	local configs = require(script.Parent.Parent).Configurations
	local default_properties = configs.Default_Properties -- Lazy loading
	Properties = Properties or {}

	local character = instance.spawn(configs.Character_Loading)
	default_properties.CHARACTER = character
	
	if character:GetAttribute("HipHeight") then
		default_properties.HIP_HEIGHT = character:GetAttribute("HipHeight")
	end

	if Properties.PLAYER then -- If it's a player, do the following
		local player = player_service:WaitForChild(Properties.PLAYER.Name)

		character.Name = player.Name
		player.Character = character
		character.Parent = game.Workspace
	end

	return setmetatable(Properties, default_properties) -- Return all properties of character object
end

function instance.spawn(_Enum)
	if _Enum == 01 then -- "NoSave"
		local all_characters = character_folder:GetChildren()

		local ac_count = #all_characters -- All characters count
		if ac_count == 0 then return nil, warn("No character models found in 'ReplicatedStorage/Packages/Crze/Characters'. exiting...") end

		local new_character = all_characters[math.random(1, ac_count)]:Clone()
		if not new_character:IsA("Model") then return nil, warn("Chosen Character: " ..new_character.Name.. " is not a model. exiting...") end
		if not new_character.PrimaryPart then return nil, warn("No PrimaryPart found on model. exiting...") end

		new_character.Name = "StarterCharacter"
		return new_character
	end
end

MR.OnServerEvent:Connect(function()
	
end)

return setmetatable(Character, { __index = instance })