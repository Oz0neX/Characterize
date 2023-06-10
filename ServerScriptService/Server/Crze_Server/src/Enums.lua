local enums = {}

local Enums = {}

Enums.CharacterLoading = {
	NoSave = 01;
	SingleSave = 02;
	CharacterSave = 03;
}

Enums.CameraView = {
	TwoDimensional = 11;
	FirstPerson = 12;
	ThirdPerson = 13;
	OverTheShoulder = 14;
}

return setmetatable(enums, { __index = Enums })