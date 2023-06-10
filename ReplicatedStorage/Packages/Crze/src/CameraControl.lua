local module = {}

local player = game.Players.LocalPlayer;
local mouse = player:GetMouse();
local run_service = game:GetService("RunService");
local tween_service = game:GetService("TweenService");
local shared = game:GetService("ReplicatedStorage");
local pkgs = shared:WaitForChild("Packages");
local Crze = pkgs:WaitForChild("Crze");
local events = Crze:WaitForChild("Events");
local current_camera = game.Workspace.CurrentCamera;

local normal_fov = current_camera.FieldOfView

function module.start(char_obj)
	local module_Crze = require(pkgs.Crze); -- Lazy Loading

	local character = char_obj.CHARACTER;
	local camera_view = char_obj.CAMERA_VIEW;
--[[	local camera_spring = require(pkgs.Spring).new(current_camera.CFrame.p, Vector3.new(), character.PrimaryPart.CFrame);
	camera_spring.k = 0.06;]]
	local camera_part = nil;
	local camera_active_zoom = nil;
	local old_active_zoom = 0;

	if camera_view == 13 then -- Third Person
		camera_part = Instance.new("Part");
		camera_part.Parent = character;
		camera_part.Anchored = true;
		camera_part.Transparency = 1;
		camera_part.Size = Vector3.new(1, 1, 1);
		camera_part.Position = character.PrimaryPart.Position;

		module.camera_part_spring = require(pkgs.Spring).new(camera_part.CFrame.p, Vector3.new(), character.PrimaryPart.CFrame.p);
		module.camera_part_spring.k = 0.06;

		current_camera.CameraType = Enum.CameraType.Custom;
		current_camera.CameraSubject = camera_part;
	else
		current_camera.CameraType = Enum.CameraType.Scriptable;
	end

	run_service:BindToRenderStep("Camera", 3, function()
		local character_cframe = character.PrimaryPart.CFrame;

		if camera_view == 11 then -- TwoDimensional
			

		elseif camera_view == 12 then -- First Person
			

		elseif camera_view == 13 then -- Third Person
			module.camera_part_spring.target = character_cframe.p + Vector3.new(0, char_obj.CAMERA_HEIGHT_OFFSET, 0);
			module.camera_part_spring:update();

			camera_part.CFrame = CFrame.new(
				module.camera_part_spring.position,
				character_cframe.p + character_cframe.LookVector * 0.1
			)

		elseif camera_view == 14 then -- Over the Shoulder
			current_camera.CFrame = CFrame.new(
				(character_cframe.p + (character_cframe.LookVector * -10) + (character_cframe.UpVector * 5.25) + (character_cframe.RightVector * 1.5)),
				(character_cframe.p + (character_cframe.LookVector * 10))
			)
		end
	end)

	mouse.Button2Down:Connect(function()
		module.right_click = true;
	end)

	mouse.Button2Up:Connect(function()
		module.right_click = false;
	end)
end

function module.update_state(State)
	local state_type = typeof(State)
	if state_type ~= 'string' then warn("Wrong data type sent over event. Data: " ..state_type) end

	if string.upper(State) == 'RUN' then
		module.camera_part_spring.k = 0.08
		tween_service:Create(current_camera, TweenInfo.new(0.5), { FieldOfView = normal_fov + 20 }):Play()

	elseif string.upper(State) == 'WALK' then
		module.camera_part_spring.k = 0.06
		tween_service:Create(current_camera, TweenInfo.new(0.5), { FieldOfView = normal_fov }):Play()
	end
end

function module.stop()
	run_service:UnbindFromRenderStep("Camera");
end

return module

--[[
- Make fakepart
- 
- If player isn't right-click, left arrow, or right arrow, adjusting the camera...
- then camera cframe = fakepart cframe, fakepart rotates back to normal
- else fakepart cframe = camera cframe
-
-
-
-
-
-
-
-
-
]]

--[[			camera_active_zoom = camera_active_zoom or current_camera.CFrame.p.Z - camera_part.Position.Z
			if math.abs(camera_active_zoom - math.abs(current_camera.CFrame.p.Z - camera_part.Position.Z)) > 5 then
				print("update")
				camera_active_zoom = current_camera.CFrame.p.Z - camera_part.Position.Z
			end

			if not module_Crze.CharacterControl.directions["Right"] and not module_Crze.CharacterControl.directions["Left"] and not module_Crze.CharacterControl.directions["Backward"] and not module.right_click then
				current_camera.CameraType = Enum.CameraType.Scriptable
				local camera_offset = camera_part.CFrame:ToObjectSpace(current_camera.CFrame)
				current_camera.CFrame = camera_part.CFrame:ToWorldSpace(CFrame.new(0, camera_offset.p.Y, camera_active_zoom))
			else
				current_camera.CameraType = Enum.CameraType.Custom
			end
]]