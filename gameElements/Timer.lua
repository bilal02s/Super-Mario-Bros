Timer = Class{}

function Timer:init(originalEntity)
	self.timer = 0
	self.execute = false
	self.finishTasks = false
	self.originalEntity = originalEntity
end

function Timer:emit(variable, initial, target, duration, finish)
	self.variable = variable
	self.initial = initial
	self.target = target
	self.duration = duration
	self.finish = finish

	self.execute = true
	self.finishTasks = false
end

function Timer:update(dt, object)
	if self.execute then
		self.timer = self.timer + dt

		if self.timer >= self.duration then
			self.timer = self.duration
		end

		if object[self.variable] ~= self.target then
			object[self.variable] = self.initial + (self.timer/self.duration)*(self.target - self.initial)
		else
			self.timer = 0
			self.execute = false
			self:finish()
		end
	end

	if self.finishTasks then
		object.finishTimer = true
	end
end
