local module = {}
local FSM = {}

module.Machines = {}

function module.new(machine: table, machine_name)
	if not machine["initial"] or not machine["events"] then return warn("Machine has missing 'initial' or 'events' parameters. exiting...") end
	
	if machine_name then
		module.Machines[machine_name] = machine
	end

	return setmetatable(machine, { __index = FSM })
end

function FSM:update(event_name)
	local event = self.events[event_name]
	if not event then return warn("Event name: " ..event_name.. " is not a valid event. exiting...") end

	if self.initial == event[1] or event[1] == true then
		self.initial = event[2]
	end
end

function module.get(machine_name)
	local machine = module.Machines[machine_name]
	if not machine then return warn("Machine name: " ..machine_name.. " not found. exiting...") end
	
	return setmetatable(machine, module)
end

return setmetatable(module, FSM)