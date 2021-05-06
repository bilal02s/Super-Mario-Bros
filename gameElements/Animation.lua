Animation = Class{}

function Animation:init(param)
	self.frames = param.frames
	self.interval = param.interval
	self.currentFrame = param.currentFrame
	self.timer = 0
end

function Animation:update(dt)
	if #self.frames > 1 then
		self.timer = self.timer + dt

		if self.timer > self.interval then
			self.timer = self.timer % self.interval
			self.currentFrame = math.max(1, (self.currentFrame + 1)%(#self.frames + 1))
		end
	end
end

function Animation:getCurrentFrame()
	return self.frames[self.currentFrame]
end
