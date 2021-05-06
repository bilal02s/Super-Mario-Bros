PlayerFallState = Class{__includes = BaseState}

function PlayerFallState:init(currentMarioState, animation)
	self.originalMarioState = currentMarioState.originalMarioState
	self.CBMario = currentMarioState
	self.id = currentMarioState.id

	self.vy = 0
	self.gravity = 1000
	self.a = 0

	self.scale = self.CBMario.scale
	self.width = self.CBMario.width
	self.height = self.CBMario.height

	self.image = currentMarioState.image
	self.quad = currentMarioState.quad

	self.gameElements = currentMarioState.gameElements
	self.entities = self.gameElements.entities
	self.objects = self.gameElements.objects

	self.animation = AnimationState(animation)

	self.lastKillTime = 0
	self.lastScore = 0
end

function PlayerFallState:open(param)
	self.x = param.x
	self.y = param.y
	self.vx = param.vx or 0
	self.vy = param.vy or 0
	self.movement = param.movement
	self.animation:change(self.movement)
end

function PlayerFallState:update(dt)
	self.collisionV, self.collisionH = checkCollision(self)
	if self.collisionV ~= 'down' then

		if love.keyboard.isDown('left') and self.collisionH ~= 'left' then
			self.a = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and -360 or -260
			self.movement = 'left'
			self.animation:change('left')
		end

		if love.keyboard.isDown('right') and self.collisionH ~= 'right' then
			self.a = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and 360 or 260
			self.movement = 'right'
			self.animation:change('right')
		end

		self.vy = self.vy + self.gravity * dt
		self.y = self.y + self.vy * dt

		self.vx = self.collisionH and 0 or self.vx
		self.vx = self.vx + (self.a - 1.2*self.vx) * dt
		self.x = self.x + self.vx * dt

		self.vx = (math.abs(self.vx) < 40  and not( love.keyboard.isDown('left') or love.keyboard.isDown('right'))) and 0 or self.vx
		self.x = self.x <= 0 and 0 or self.x
		self.x = self.x >= 8360 - self.width and 8360 - self.width or self.x

		if self.y > Height then
			stateMachine:change('start')
		end

		for k, entity in pairs(self.entities) do
			if entity.inPlay and entityCollision(self, entity) then
				if entity.enemy then
					self.entityCollision = Collision2(self, entity)
					if self.entityCollision == 'down' then
						entity:onCollide(self)
						soundEffects['kick']:play()
						self.vy = -150
						self.y = self.y - 4
						if love.timer.getTime() - self.lastKillTime < 1.5 then
							table.insert(score, Score(entity.x, entity.y - 20, self.lastScore + 100))
							scores = scores + self.lastScore + 100
							self.lastScore = self.lastScore + 100
						else
							table.insert(score, Score(entity.x, entity.y - 20, 100))
							scores = scores + 100
							self.lastScore = 100
						end
						self.lastKillTime = love.timer.getTime()
					else
						if self.id == 'small' then
							soundEffects['marioDie']:play()
							self.originalMarioState:change('transition', {
								x = self.x,
								y = self.y,
								vy = -500,
								movement = self.movement,
								target = 'marioDie'
							})
						elseif self.id == 'big' or self.id == 'shooting' then
							soundEffects['powerDown']:play()
							self.originalMarioState:change('transition', {
								x = self.x,
								y = self.y,
								vy = self.vy or 0,
								movement = self.movement,
								target = 'smallMario'
							})
						end
					end
				elseif entity.consumable then
					entity:onCollide(self)
				end
			end
		end

		if self.x > 8000 then
			self.CBMario.playState.music:stop()
			self.CBMario.playState.hurry:stop()
			stateMachine:change('victory',{time = self.CBMario.playState.time})
		end

		self.animation:update(dt)
	else
		self.CBMario:change('walk', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
	end
end

function Collision2(self, object)
	local collisionBlock = object.stateMachine.current

	local w = 0.5 * (self.width + collisionBlock.width)
	local h = 0.5 * (self.height + collisionBlock.height)

	local deltaY = (collisionBlock.y + collisionBlock.height/2) - (self.y + self.height/2)
	local deltaX = (collisionBlock.x + collisionBlock.width/2) - (self.x + self.width/2)

	local pixelY = h - math.abs(deltaY)
	local pixelX = w - math.abs(deltaX)

	if pixelY < 20*pixelX then
		if deltaY > 0 then
			return 'down'
		else
			return 'up'
		end
	else
		if deltaX > 0 then
			return 'right'
		else
			return 'left'
		end
	end
end

function PlayerFallState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end

