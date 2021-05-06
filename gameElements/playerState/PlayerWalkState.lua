PlayerWalkState = Class{__includes = BaseState}

function PlayerWalkState:init(currentMarioState, animation)
	self.originalMarioState = currentMarioState.originalMarioState
	self.CBMario = currentMarioState
	self.id = currentMarioState.id

	self.ax = 0
	self.speed = 300

	self.scale = self.CBMario.scale
	self.width = self.CBMario.width
	self.height = self.CBMario.height

	self.image = currentMarioState.image
	self.quad = currentMarioState.quad

	self.gameElements = currentMarioState.gameElements
	self.entities = self.gameElements.entities
	self.objects = self.gameElements.objects

	self.animation = AnimationState(animation)
end

function PlayerWalkState:open(param)
	self.x = param.x
	self.y = param.y
	self.vx = param.vx or 0
	self.vy = param.vy or 0
	self.movement = param.movement
	self.animation:change(self.movement)
end

function PlayerWalkState:update(dt)
	if love.keyboard.isDown('left') or love.keyboard.isDown('right') or self.vx ~= 0 then
		self.collisionV, self.collisionH = checkCollision(self)
		if love.keyboard.isDown('left') and self.collisionH ~= 'left' then
			self.a = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and -360 or -260
			self.movement = 'left'
			if self.vx > 0 then
				self.animation:change('changeL')
			else
				self.animation:change('left')
			end
		elseif love.keyboard.isDown('right') and self.collisionH ~= 'right' then
			self.a = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and 360 or 260
			self.movement = 'right'
			if self.vx < 0 then
				self.animation:change('changeR')
			else
				self.animation:change('right')
			end
		else
			self.a = 0
		end

		self.vx = self.collisionH and 0 or self.vx
		self.vx = self.vx + (self.a - 1*self.vx) * dt
		self.x = self.x + self.vx * dt

		self.vx = (math.abs(self.vx) < 40  and not( love.keyboard.isDown('left') or love.keyboard.isDown('right'))) and 0 or self.vx
		self.x = self.x <= 0 and 0 or self.x
		self.x = self.x >= 8360 - self.width and 8360 - self.width or self.x


		if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('up') then
			self.CBMario:change('jump', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
		end

		if self.collisionV == 'down' and love.keyboard.wasPressed('down') and (self.id == 'big' or self.id == 'shooting') then
			self.CBMario:change('crouch', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
		end

		if self.collisionV ~= 'down' then
			self.CBMario:change('fall', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
		end

		for k, entity in pairs(self.entities) do
			if entity.inPlay and entityCollision(self, entity) then
				if entity.enemy then
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
		self.CBMario:change('idle', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
	end
end

function entityCollision(self, entity)
	if self.x + self.width < entity.stateMachine.current.x or self.x > entity.stateMachine.current.x + entity.stateMachine.current.width
		or self.y + self.height < entity.stateMachine.current.y or self.y > entity.stateMachine.current.y + entity.stateMachine.current.height then
		return false
	end

	return true
end

function checkCollision(self)
	local x1 = math.floor(self.x/tileLength) + 1
	local y1 = math.floor(self.y/tileLength) + 1
	local x2 = math.floor((self.x + self.width)/tileLength) + 1
	local y2 = math.floor((self.y + self.height)/tileLength) + 1
	local y3 = 1

	local id = self.id

	if id == 'big' or id == 'shooting' then
		y3 = math.floor((self.y + self.height/2)/tileLength) + 1
	end

	y1 = y1 < 1 and 1 or y1
	y2 = y2 < 1 and 1 or y2
	y3 = y3 < 1 and 1 or y3
	local coordinate = {}

	if self.objects[y1][x1] then
		coordinate[#coordinate + 1] = {x1, y1}
	end
	if self.objects[y2][x1] then
		coordinate[#coordinate + 1] = {x1, y2}
	end
	if self.objects[y2][x2] then
		coordinate[#coordinate + 1] = {x2, y2}
	end
	if self.objects[y1][x2] then
		coordinate[#coordinate + 1] = {x2, y1}
	end

	if id == 'big' or id == 'shooting' then
		if self.objects[y3][x1] then
			coordinate[#coordinate + 1] = {x1, y3}
		end
		if self.objects[y3][x2] then
			coordinate[#coordinate + 1] = {x2, y3}
		end
	end

	if #coordinate == 0 then
		return false, false
	else
		local collisionV = false
		local collisionH = false
		for k, v in ipairs(coordinate) do
			local result = Collision(self, self.objects[v[2]][v[1]])
			if result == 'left' or result == 'right' then
				collisionH = result
			elseif result == 'up' or result == 'down' then
				collisionV = result
			end
		end

		return collisionV, collisionH
	end
end

function Collision(self, object)
	local collisionBlock = object

	local w = 0.5 * (self.width + collisionBlock.width)
	local h = 0.5 * (self.height + collisionBlock.height)

	local deltaY = (collisionBlock.y + collisionBlock.height/2) - (self.y + self.height/2)
	local deltaX = (collisionBlock.x + collisionBlock.width/2) - (self.x + self.width/2)

	local pixelY = h - math.abs(deltaY)
	local pixelX = w - math.abs(deltaX)

	if pixelY > pixelX then
		if deltaX > 0 then
			self.x = collisionBlock.x - self.width
			return 'right'
		else
			self.x = collisionBlock.x + collisionBlock.width
			return 'left'
		end
	else
		if deltaY > 0 then
			self.y = collisionBlock.y - self.height
			return 'down'
		else
			self.y = collisionBlock.y + collisionBlock.height
			return 'up'
		end
	end
end

function PlayerWalkState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end
