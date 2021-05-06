EntityWalkState = Class{__includes = BaseState}

function EntityWalkState:init(originalEntity)
	self.scale = originalEntity.scale
	self.width = originalEntity.dim['walk'].width * self.scale
	self.height = originalEntity.dim['walk'].height * self.scale

	self.objects = originalEntity.objects
	self.speed = originalEntity.speed
	self.image = originalEntity.images['walk']
	self.quad = originalEntity.quads['walk']

	self.gravity = 1000
	self.vy = 0

	self.animation = AnimationState(originalEntity.animation()['walk'])

	self.originalEntity = originalEntity

end

function EntityWalkState:open(param)
	self.x = param.x
	self.y = param.y
	self.movement = param.movement
	self.animation:change(self.movement)
end

function EntityWalkState:update(dt)
	self.collisionV, self.collisionH = checkCollision(self)

	if self.collisionV == 'down' then
		self.a = -1000
		self.vy = 0
	else
		self.a = 0
	end

	if self.collisionH == 'left' then
		self.movement = 'right'
		self.animation:change(self.movement)
		self.speed = math.abs(self.speed)
	elseif self.collisionH == 'right' then
		self.movement = 'left'
		self.animation:change(self.movement)
		self.speed = -math.abs(self.speed)
	end

	self.vy = self.vy + (self.gravity + self.a) * dt
	self.y = self.y + self.vy * dt
	self.x = self.x + self.speed * dt

	if self.x + self.width < 0 or self.x > 8400 or self.y > Height then
		self.originalEntity.inGame = false
	end

	self.animation:update(dt)
end

function EntityWalkState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end



