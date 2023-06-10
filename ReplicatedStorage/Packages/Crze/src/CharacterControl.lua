local module = {}
local CharacterControl = {}
CharacterControl.Movement = {}

local run_service = game:GetService("RunService");
local tween_service = game:GetService("TweenService");
local context_action_service = game:GetService("ContextActionService");
local shared = game:GetService("ReplicatedStorage");
local pkgs = shared:WaitForChild("Packages");
local Crze = pkgs:WaitForChild("Crze");
local events = Crze:WaitForChild("Events");
local current_camera = game.Workspace.CurrentCamera

local remotes = Crze:WaitForChild("Events");
local MR = remotes:WaitForChild("Move"); -- Move Remote (MR)
local SBE = remotes:WaitForChild("State") -- State Bindable Event (SBE)

function module.start(object)
	if not object then return warn("Character object is not set. exiting..."); end
	local module_Crze = require(pkgs.Crze); -- Lazy Loading

	local character = setmetatable(object, { __index = CharacterControl });
	module_Crze.CurrentCharacter = character;

	if math.abs((character.CHARACTER.PrimaryPart.Position + (character.CHARACTER.PrimaryPart.CFrame.LookVector * 3)).Y) > math.abs(character.CHARACTER.PrimaryPart.Position.Y) + 1 then warn("Character's Primary Part is not rotated properly. Will cause errors with collision detection") end
	return character
end

function CharacterControl.Movement:enable()
	local module_Crze = require(pkgs.Crze); -- Lazy Loading
	module_Crze.CurrentCharacter:start_input_listener();
	module_Crze.CurrentCharacter:bind(true);
end

function CharacterControl.Movement:disable()
	local module_Crze = require(pkgs.Crze); -- Lazy Loading
	module_Crze.CurrentCharacter.Movement.moving:Disconnect();
	module_Crze.CurrentCharacter.Movement.gravity:Disconnect();
	module_Crze.CurrentCharacter:bind(false);
end

function CharacterControl.Movement.move(Event, InputState)
	if InputState == Enum.UserInputState.Begin then
		module.directions[Event] = true;

	elseif InputState == Enum.UserInputState.End then
		module.directions[Event] = false;
		module.turn['RotateLeft'] = false;
		module.turn['RotateRight'] = false;
	end
end

function CharacterControl.Movement.sprint(ChangeTo: boolean, InputState)
	local module_Crze = require(pkgs.Crze); -- Lazy Loading
	local self = module_Crze.CurrentCharacter;

	if typeof(ChangeTo) == "boolean" then -- If called locally
		if ChangeTo then
			self.SPEED = self.RUN_SPEED/2;
			self.STATE:update('running');

		elseif not ChangeTo then
			self.SPEED = self.WALK_SPEED/2;
			self.STATE:update('walking');
		end

	elseif typeof(ChangeTo) == "string" then -- If called by binded event
		if InputState == Enum.UserInputState.Begin then
			self.SPEED = self.RUN_SPEED/2;
			if string.upper(self.STATE.initial) ~= "JUMP" then
				self.STATE:update('running');
			end

		elseif InputState == Enum.UserInputState.End then
			self.SPEED = self.WALK_SPEED/2;
			if string.upper(self.STATE.initial) ~= "JUMP" then
				self.STATE:update('walking');
			end
		end
	end

	SBE:Fire("Speed", self.STATE.initial)
end

function CharacterControl.Movement.rotate_to_camera(Camera_Rotation, Character_Rotation, Rotate_Velocity)
	if module.turn['RotateLeft'] or module.turn['RotateRight'] then
		module.turn['RotateLeft'] = false;
		module.turn['RotateRight'] = false;
	end

	if Character_Rotation < 0 then
		Character_Rotation = 180 + (180 + Character_Rotation);
	end

	local rotation_offset = Camera_Rotation - Character_Rotation;
	local absolute_offset = math.abs(rotation_offset);
	local R = 0;
	--print("| Camera Rotation: ", camera_rotation, "| Character Rotation:", character_rotation, "| Rotation Offset:", rotation_offset)

	if absolute_offset > Rotate_Velocity * 1.01 then
		if rotation_offset < 0 then -- Turn Right to get normal
			if rotation_offset < -180 then
				module.turn['RotateLeft'] = true;
				module.turn['RotateRight'] = false;
			else
				module.turn['RotateRight'] = true;
				module.turn['RotateLeft'] = false;
			end
		else -- Turn left to get normal
			if rotation_offset > 180 then
				module.turn['RotateRight'] = true;
				module.turn['RotateLeft'] = false;
			else
				module.turn['RotateLeft'] = true;
				module.turn['RotateRight'] = false;
			end
		end
	else
		if absolute_offset > Rotate_Velocity/2 then
			return Rotate_Velocity/3;
		else
			module.turn['RotateLeft'] = false;
			module.turn['RotateRight'] = false;
		end
	end

	if module.turn['RotateRight'] then
		R += -Rotate_Velocity;
	end
	if module.turn['RotateLeft'] then
		R += Rotate_Velocity;
	end

	return R
end

function CharacterControl:start_input_listener()
	if not module.directions then module.directions = {} end
	if not module.turn then module.turn = {} end

	local character = self.CHARACTER;
	self.Movement.sprint(false)

	if not self.TURN_PREFERENCE then
		self.TURN_PREFERENCE = {
			["Forward"] = 180;
			["Left"] = 270;
			["Backward"] = 0;
			["Right"] = 90;
		}
	end

	self.gravity = run_service.Heartbeat:Connect(function() -- NOTE: If it's glitchy, try .RenderStepped
		local character_cframe = character.PrimaryPart.CFrame
		local raycast_params = RaycastParams.new()
		raycast_params.FilterDescendantsInstances = {character}
		raycast_params.FilterType = Enum.RaycastFilterType.Blacklist

		local cast1 = game.Workspace:Raycast(
			character.PrimaryPart.Position,
			Vector3.new(0, -self.HIP_HEIGHT, 0),
			raycast_params
		)

		if string.upper(self.STATE.initial) == "JUMP" then return end

		if cast1 then -- Check if not undergrount
			local cast2 = game.Workspace:Raycast(
				character.PrimaryPart.Position,
				Vector3.new(0, (-self.HIP_HEIGHT + 0.6), 0),
				raycast_params
			)

			if cast2 then
				self.CHARACTER:SetPrimaryPartCFrame(character_cframe * CFrame.new(0, 0.1, 0))
			end
		else -- Fall to the ground
			self.CHARACTER:SetPrimaryPartCFrame(character_cframe * CFrame.new(0, -0.5, 0))
		end
	end)

	self.moving = run_service.Heartbeat:Connect(function() -- NOTE: If it's glitchy, try .RenderStepped
		local speed = self.SPEED;
		local rotate_velocity = speed * 17;
		local Z = 0; -- Position
		local R = 0; -- Rotation

		local cc_lookat = current_camera.CFrame.LookVector
		local camera_rotation = math.floor((math.deg(math.atan2(cc_lookat.X, cc_lookat.Z)) % 360) + 0.5); -- Gets the rotation of the player's camera	
		local character_rotation = character.PrimaryPart.Orientation.Y
		local collide = self:collision_detection()

		for direction, active in pairs(module.directions) do
			if not active then continue end
			if not collide then
				Z = -speed;
			end
			R += self.Movement.rotate_to_camera((camera_rotation + self.TURN_PREFERENCE[direction]) % 360, character_rotation, rotate_velocity);
		end

		if Z ~= 0 or R ~= 0 then -- If player is trying to move...
			local character_cframe = character.PrimaryPart.CFrame
			self.CHARACTER:SetPrimaryPartCFrame(character_cframe * CFrame.new(0, 0, Z) * CFrame.Angles(math.rad(0), math.rad(R), math.rad(0)));
			MR:FireServer('Horizontal', nil); -- Pass CFrame when Server-Sided Checks are added
		end
	end)
end

function CharacterControl:collision_detection()
	local character = self.CHARACTER
	local primary_part = character.PrimaryPart
	local primary_position = primary_part.Position
	local primary_lookvector = primary_part.CFrame.LookVector
	local primary_rightvector = primary_part.CFrame.RightVector
	local primary_size = primary_part.Size
	
	local extra_range = 0.3 -- Extra distance for collision in studs.

	local raycast_params = RaycastParams.new()
	raycast_params.FilterDescendantsInstances = { character, workspace.ignore }
	raycast_params.FilterType = Enum.RaycastFilterType.Blacklist

	local collisions = {
		["forward"] = game.Workspace:Raycast(
			primary_position,
			(primary_lookvector * ((primary_size.X/2) + extra_range)),
			raycast_params
		);
		["right_forward"] = game.Workspace:Raycast(
			primary_position,
			(primary_lookvector * ((primary_size.X/2) + extra_range)) + (primary_rightvector * ((primary_size.Z/2) + extra_range)),
			raycast_params
		);
		["right"] = game.Workspace:Raycast(
			primary_position,
			(primary_rightvector * ((primary_size.Z/2) + extra_range)),
			raycast_params
		);
		["backward_right"] = game.Workspace:Raycast(
			primary_position,
			(primary_rightvector * ((primary_size.Z/2) + extra_range)) + (primary_lookvector * -((primary_size.X/2) + extra_range)),
			raycast_params
		);
		["backward"] = game.Workspace:Raycast(
			primary_position,
			(primary_lookvector * -((primary_size.X/2) + extra_range)),
			raycast_params
		);
		["left_backward"] = game.Workspace:Raycast(
			primary_position,
			(primary_lookvector * -((primary_size.X/2) + extra_range)) + (primary_rightvector * -((primary_size.Z/2) + extra_range)),
			raycast_params
		);
		["left"] = game.Workspace:Raycast(
			primary_position,
			(primary_rightvector * -((primary_size.Z/2) + extra_range)),
			raycast_params
		);
		["forward_left"] = game.Workspace:Raycast(
			primary_position,
			(primary_rightvector * -((primary_size.Z/2) + extra_range)) + (primary_lookvector * ((primary_size.X/2) + extra_range)),
			raycast_params
		);
	}

	for direction, collision in pairs(collisions) do
		if string.find(direction, "backward") then continue end
		return direction
	end
end

function CharacterControl:bind(Bind)
	if Bind then
		context_action_service:BindAction("Forward"    , self.Movement.move  , false, Enum.KeyCode.W, Enum.KeyCode.Up);
		context_action_service:BindAction("Left"       , self.Movement.move  , false, Enum.KeyCode.A);
		context_action_service:BindAction("Backward"   , self.Movement.move  , false, Enum.KeyCode.S, Enum.KeyCode.Down);
		context_action_service:BindAction("Right"      , self.Movement.move  , false, Enum.KeyCode.D);
		context_action_service:BindAction("Sprint"     , self.Movement.sprint, false, Enum.KeyCode.LeftShift);
	else
		context_action_service:UnbindAction("Forward");
		context_action_service:UnbindAction("Left");
		context_action_service:UnbindAction("Backward");
		context_action_service:UnbindAction("Right");
		context_action_service:UnbindAction("Sprint");
	end
end

function CharacterControl:play_animation(ID)
	local animation_controller = self.CHARACTER.AnimationController;
	local animator, animation = animation_controller.Animator, animation_controller.Animation;

	animation.AnimationId = ID or self.ANIMATIONS[self.STATE.initial];

	local animate = animator:LoadAnimation(animation);
	animate:Play();
end

return module

--[[
		for direction, active in pairs(module.directions) do
			if not active then continue end
			local dual = false
			Z = -speed

			for direction2, active2 in pairs(module.directions) do
				if not active2 then continue end
				local rotation_scope = self.TURN_PREFERENCE[direction] - self.TURN_PREFERENCE[direction2]

				if rotation_scope == 90 then
					dual = true
					self.Movement.rotate_to_camera((camera_rotation + self.TURN_PREFERENCE[direction] + rotation_scope/2) % 360, character_rotation, rotate_velocity)
					break
				end
			end

			if not dual then
				self.Movement.rotate_to_camera((camera_rotation + self.TURN_PREFERENCE[direction]) % 360, character_rotation, rotate_velocity)
			end
		end
]]

--[[
	local collisions = {
		["forward"] = game.Workspace:Raycast(
			primary_position,
			(primary_lookvector * ((primary_size.X/2) + extra_range)),
			raycast_params
		);
		["right_forward"] = game.Workspace:Raycast(
			primary_position,
			(primary_lookvector * ((primary_size.X/2) + extra_range)) + (primary_rightvector * ((primary_size.Z/2) + extra_range)),
			raycast_params
		);
		["right"] = game.Workspace:Raycast(
			primary_position,
			(primary_rightvector * ((primary_size.Z/2) + extra_range)),
			raycast_params
		);
		["backward_right"] = game.Workspace:Raycast(
			primary_position,
			(primary_rightvector * ((primary_size.Z/2) + extra_range)) + (primary_lookvector * -((primary_size.X/2) + extra_range)),
			raycast_params
		);
		["backward"] = game.Workspace:Raycast(
			primary_position,
			(primary_lookvector * -((primary_size.X/2) + extra_range)),
			raycast_params
		);
		["left_backward"] = game.Workspace:Raycast(
			primary_position,
			(primary_lookvector * -((primary_size.X/2) + extra_range)) + (primary_rightvector * -((primary_size.Z/2) + extra_range)),
			raycast_params
		);
		["left"] = game.Workspace:Raycast(
			primary_position,
			(primary_rightvector * -((primary_size.Z/2) + extra_range)),
			raycast_params
		);
		["forward_left"] = game.Workspace:Raycast(
			primary_position,
			(primary_rightvector * -((primary_size.Z/2) + extra_range)) + (primary_lookvector * ((primary_size.X/2) + extra_range)),
			raycast_params
		);
	}
]]