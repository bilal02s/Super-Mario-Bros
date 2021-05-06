MarioRecoveryState = Class{__includes = BaseState}

function MarioRecoveryState:init(playState, id)
	self.originalMarioState = playState.marioState
	self.id = id

	self.gameElements = playState.gameElements
	self.objects = self.gameElements.objects
	self.entities = self.gameElements.entities

	self.scale = 2.5
	self.width = 15 * self.scale
	self.height = 16 * self.scale
	self.gravity = 1000
	self.ay = -1000
	self.ax = 0

	self.image = 'mario'
	self.quad = 'smallMario'

	self.animation = AnimationState({
		['right'] = {frames = {9, 10, 11}, interval = 0.15, currentFrame = 1},
		['left'] = {frames = {6, 5, 4}, interval = 0.15, currentFrame = 1},
		['changeR'] = {frames = {12}, interval = 10, currentFrame = 1},
		['changeL'] = {frames = {3}, interval = 10, currentFrame = 1},
		['idleR'] = {frames = {8}, interval = 10, currentFrame = 1},
		['idleL'] = {frames = {7}, interval = 10, currentFrame = 1},
		['jumpR'] = {frames = {13}, interval = 10, currentFrame = 1},
		['jumpL'] = {frames = {2}, interval = 10, currentFrame = 1}
	})

	self.timer = 0
	self.previousTime = 0
	self.count = 0
end

function MarioRecoveryState:open(param)
	self.x = param.x
	self.y = param.y + (16 * self.scale)
	self.vx = param.vx or 0
	self.vy = param.vy or 0
	self.movement = param.movement
	self.animation:change(self.movement)
end

function MarioRecoveryState:update(dt)
	self.timer = self.timer + dt
	if self.timer > 0.8 then
		self.originalMarioState:change('smallMario', {
			x = self.x,
			y = self.y,
			movement = self.movement,
			vy = self.vy or 0,
			vx = self.vx or 0,
		})
	end

	if love.keyboard.isDown('left') or love.keyboard.isDown('right') or self.vx ~= 0 then
		self.collisionV, self.collisionH = checkCollision(self)
		if love.keyboard.isDown('left') and self.collisionH ~= 'left' then
			self.ax = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and -360 or -260
			self.movement = 'left'
			if self.vx > 0 then
				self.animation:change('changeL')
			else
				self.animation:change('left')
			end
		elseif love.keyboard.isDown('right') and self.collisionH ~= 'right' then
			self.ax = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and 360 or 260
			self.movement = 'right'
			if self.vx < 0 then
				self.animation:change('changeR')
			else
				self.animation:change('right')
			end
		else
			self.ax = 0
		end

		self.vx = self.collisionH and 0 or self.vx
		self.vx = self.vx + (self.ax - 1*self.vx) * dt
		self.x = self.x + self.vx * dt

		self.vx = (math.abs(self.vx) < 40  and not( love.keyboard.isDown('left') or love.keyboard.isDown('right'))) and 0 or self.vx
		self.x = self.x <= 0 and 0 or self.x
		self.x = self.x >= 8360 - self.width and 8360 - self.width or self.x

		if self.collisionV == 'down' then
			self.a = -1000
			self.vy = 0
		else
			self.a = 0
			if self.movement == 'right' then
				self.animation:change('jumpR')
			elseif self.movement == 'left' then
				self.animation:change('jumpL')
			end
		end

		self.vy = self.vy + (self.gravity + self.a)*dt
		self.y = self.y + self.vy * dt

		if self.y > Height then
			stateMachine:change('start')
		end

		for k, entity in pairs(self.entities) do
			if entity.inPlay and entityCollision(self, entity) and entity.consumable then
				entity:onCollide(self)
			end
		end


		self.animation:update(dt)
	else
		if self.movement == 'right' then
			self.animation:change('idleR')
		elseif self.movement == 'left' then
			self.animation:change('idleL')
		end
	end
end

function MarioRecoveryState:draw()
	if self.timer - self.previousTime > 0.1 then
		self.previousTime = self.timer
		self.count = self.count + 1
	end
	if self.count % 2 == 0 then
		love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
	end
end
