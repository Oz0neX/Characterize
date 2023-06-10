local spring = {};

function spring.new(position, velocity, target)
	local self = setmetatable({}, {__index = spring});

	self.position = position;
	self.velocity = velocity;
	self.target = target;
	self.k = 1;
	self.d = 1; -- dampening

	return self;
end;

function spring:update()
	local d = (self.target - self.position);
	local f = d * self.k;
	self.velocity = (self.velocity * (1 - self.d)) + f;
	self.position = self.position + self.velocity;
end;

return spring;