Score = Class{}

function Score:init(x, y, value)
	self.x = x
	self.y = y
	self.originalY = self.y
	self.value = value
	self.timer = returnTimer(self)
	self.timer:emit('y', self.y, self.y - 40, 1, function(this) this.finishTasks = true end)
	self.finishTimer = false
	self.inGame = true
end

function Score:update(dt)
	self.timer:update(dt, self)

	if self.finishTimer then
		self.inGame = false
	end
end

function Score:draw()
	love.graphics.setFont(fonts['score'])
	love.graphics.setColor(1, 1, 1, (self.y - (self.originalY - 40))/40)
	love.graphics.print(tostring(self.value), self.x, self.y)
	love.graphics.setColor(1, 1, 1, 1)
end

function returnTimer(this)
	return Timer(this)
end
