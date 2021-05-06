EntityIdleState = Class{__includes = BaseState}

function EntityIdleState:init(originalEntity)
	self.scale = originalEntity.scale
	self.width = originalEntity.dim['idle'].width * self.scale
	self.height = originalEntity.dim['idle'].height * self.scale

	self.image = originalEntity.images['idle']
	self.quad = originalEntity.quads['idle']

	self.animation = AnimationState(originalEntity.animation()['idle'])
	self.originalEntity = originalEntity

	self.timer = returnTimer(originalEntity)
	self.finishTimer = false

end

function EntityIdleState:open(param)
	self.x = param.x
	self.y = param.y
	self.movement = param.movement
	self.animation:change(self.movement)
end

function EntityIdleState:update(dt)
	self.timer:update(dt, self)
	self.animation:update(dt)

	if self.finishTimer then
		self.originalEntity:finishTimerFunction()
	end
end

function EntityIdleState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end
