EntityDieState = Class{}

function EntityDieState:init(originalEntity)
	self.scale = originalEntity.scale
	self.width = originalEntity.dim['die'].width * self.scale
	self.height = originalEntity.dim['die'].height * self.scale

	self.image = originalEntity.images['die']
	self.quad = originalEntity.quads['die']

	self.animation = AnimationState(originalEntity.animation()['die'])
	self.originalEntity = originalEntity
	originalEntity.inPlay = false

	self.gravity = 1000
	self.vy = -300
	self.vx = 100
end

function EntityDieState:open(param)
	self.x = param.x
	self.y = param.y
	self.vx = param.param.k * self.vx
	self.movement = param.movement
	self.animation:change(self.movement)
end

function EntityDieState:update(dt)
	self.x = self.x + self.vx*dt
	self.vy = self.vy + self.gravity*dt
	self.y = self.y + self.vy*dt

	if self.x + self.width < 0 or self.x > 8360 or self.y > Height then
		self.originalEntity.inGame = false
	end

	self.animation:update(dt)
end

function EntityDieState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y + self.height, 0, self.scale, -self.scale)
end

