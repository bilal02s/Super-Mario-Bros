EntityRollState = Class{__includes = BaseState}

function EntityRollState:init(originalEntity)
	self.scale = originalEntity.scale
	self.width = originalEntity.dim['roll'].width * self.scale
	self.height = originalEntity.dim['roll'].height * self.scale

	self.objects = originalEntity.objects
	self.image = originalEntity.images['roll']
	self.quad = originalEntity.quads['roll']

	self.gravity = 1000
	self.a = 0
	self.vy = 0
	self.vx = 0

	self.animation = AnimationState(originalEntity.animation()['roll'])
	self.animation:change('idle')
	self.lastKillTime = 0
	self.lastScore = 0
	self.originalEntity = originalEntity
	self.rolled = true
end

function EntityRollState:open(param)
	self.x = param.x
	self.y = param.y
	self.entities = param.param.entities
end

function EntityRollState:update(dt)
	self.rolling = not (self.vx == 0)
	self.collisionV, self.collisionH = checkCollision(self)

	if self.collisionV == 'down' then
		self.a = -1000
		self.vy = 0
	else
		self.a = 0
	end

	if self.collisionH == 'left' then
		self.movement = 'right'
		self.vx = math.abs(self.vx)
	elseif self.collisionH == 'right' then
		self.movement = 'left'
		self.vx = -math.abs(self.vx)
	end

	self.vy = self.vy + (self.gravity + self.a) * dt
	self.y = self.y + self.vy * dt
	self.x = self.x + self.vx * dt

	for k, entity in pairs(self.entities) do
		if entity.inPlay and self.originalEntity ~= entity and entityCollision(self, entity) then
			soundEffects['kick']:stop()
			soundEffects['kick']:play()
			local k = self.movement == 'right' and 1 or -1
			entity:change('die', {k = k})
			if love.timer.getTime() - self.lastKillTime < 0.5 then
				table.insert(score, Score(entity.x, entity.y - 20, self.lastScore + 100))
				scores = scores + self.lastScore + 100
				self.lastScore = self.lastScore + 100
			else
				table.insert(score, Score(entity.x, entity.y - 20, 100))
				scores = scores + 100
				self.lastScore = 100
			end
			self.lastKillTime = love.timer.getTime()
		end
	end

	if self.x + self.width < 0 or self.x > 8400 or self.y > Height then
		self.originalEntity.inGame = false
	end

	self.animation:update(dt)
end

function EntityRollState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end
