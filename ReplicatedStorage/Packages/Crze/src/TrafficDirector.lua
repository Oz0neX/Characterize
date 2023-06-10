local module = {}

local shared = game:GetService("ReplicatedStorage")
local pkgs = shared.Packages
local Crze = pkgs.Crze
local events = Crze:WaitForChild("Events");
local CR = events:WaitForChild("Character");
local SBE = events:WaitForChild("State");

local Inheritence = require(pkgs:WaitForChild("Inheritence"))
local FSM = require(pkgs:WaitForChild("StateMachine"))

local DEFAULT_TRAFFIC_ENABLED = true

function module.handle(Event, ...)
	local module_Crze = require(pkgs.Crze); -- Lazy Loading
	print("event: " ..Event); -- NOTE: Remove Later, keep for testing.

	if Event == "SetObject" then
		if typeof(...) ~= 'table' then return warn("Object is not an table. exiting..."); end
		local args = table.pack(...);
		local object = Inheritence.merge(args[1], args[2]);

		if object.STATE then
			object.STATE = FSM.new(object.STATE);
		end

		module_Crze.CurrentCharacter = object;
		module_Crze.CharacterControl.start(object);
		module_Crze.CameraControl.start(object);

	elseif Event == "Animate" then
		module_Crze.CurrentCharacter:play_animation(...);

	elseif Event == "Enable" then
		module_Crze.CurrentCharacter.Movement:enable();

	elseif Event == "Disable" then
		module_Crze.CurrentCharacter.Movement:disable();

	elseif Event == "MoveTo" then
		
	end
end

function module.handle_binded(Event, ...)
	local module_Crze = require(pkgs.Crze); -- Lazy Loading
	
	if Event == "Speed" then
		module_Crze.CameraControl.update_state(...)
	else
		warn("Event: " ..Event.. " is not a valid event. exiting...")
	end
end

if DEFAULT_TRAFFIC_ENABLED then
	CR.OnClientEvent:Connect(module.handle)
	SBE.Event:Connect(module.handle_binded)
end

return module