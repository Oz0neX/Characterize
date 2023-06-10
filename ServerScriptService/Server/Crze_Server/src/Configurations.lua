local module = {}

local shared = game:GetService("ReplicatedStorage");
local pkgs = shared.Packages;
local fsm = require(pkgs:WaitForChild("StateMachine"));
local src = script.Parent;
local Enums = require(src:WaitForChild("Enums"));

local module = {
	-- Default Global Configurations when character is created.
	Startup = true; -- Module is started automatically
	Movement_Enabled = false;
	PathFinding_Enabled = false;
	Customize = false;

	Camera_View = Enums.CameraView.ThirdPerson;
	Character_Loading = Enums.CharacterLoading.NoSave;
	
	Camera_Height_Offset = 4; -- In studs

	Default_Properties = {
		HEALTH = 100;
		WALK_SPEED = 0.6;
		RUN_SPEED = 1.0;
		HIP_HEIGHT = 3;

		ANIMATIONS = {
			-- Animation ID's
			WALK = 1234567890;
			RUN = 0987654321;
			JUMP = 1230984576;
			IDLE = 5425135241;
		};
		STATE = fsm.new({
			initial = "IDLE";
			events = {
				walking = {true, "WALK"};
				running = {"WALK", "RUN"};
				jumping = {true, "JUMP"};
				idle = {true, "IDLE"};
			};
			__call = function()
				return module.Default_Attributes.STATE.initial
			end
		})
	};
}


return module