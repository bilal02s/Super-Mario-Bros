EntitySmashState = Class{__includes = BaseState}

function EntitySmashState:init(originalEntity)
	self.scale = originalEntity.scale
	self.width = originalEntity.dim['smash'].width * self.scale
	self.height = originalEntity.dim['smash'].height *self.scale

	self.objects = originalEntity.objects
	self.speed = originalEntity.speed
	self.image = originalEntity.images['smash']
	self.quad = originalEntity.quads['smash']

	self.animation = AnimationState(originalEntity.animation()['smash'])
	self.animation:change('idle')

	self.timer = 0

	self.originalEntity = originalEntity
end

function EntitySmashState:open(param)
	self.x = param.x
	self.y = param.y + 45 - self.height
end

function EntitySmashState:update(dt)
	self.timer = self.timer + dt
	if self.timer > 1 then
		self.originalEntity.inGame = false
	end
end

function EntitySmashState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end
