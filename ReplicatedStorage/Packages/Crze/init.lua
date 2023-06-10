local shared = game:GetService("ReplicatedStorage")
local pkgs = shared.Packages
local Crze = pkgs.Crze
local src = Crze:WaitForChild("src")

local module = {
	CharacterControl = require(src:WaitForChild("CharacterControl"));
	CameraControl = require(src:WaitForChild("CameraControl"));
	TrafficDirector = require(src:WaitForChild("TrafficDirector"));
}

return module