PlayerJumpState = Class{__includes = BaseState}

function PlayerJumpState:init(currentMarioState, animation)
	self.originalMarioState = currentMarioState.originalMarioState
	self.CBMario = currentMarioState
	self.id = currentMarioState.id

	self.vy = -400
	self.ax = 0
	self.ay = 0
	self.gravity = 2000

	self.scale = self.CBMario.scale
	self.width = self.CBMario.width
	self.height = self.CBMario.height

	self.image = currentMarioState.image
	self.quad = currentMarioState.quad

	self.gameElements = currentMarioState.gameElements
	self.entities = self.gameElements.entities
	self.objects = self.gameElements.objects

	self.animation = AnimationState(animation)

	soundEffects['smallJump']:stop()
	soundEffects['smallJump']:play()
	self.jumping = true
end

function PlayerJumpState:open(param)
	self.x = param.x
	self.y = param.y
	self.vx = param.vx or 0
	self.movement = param.movement
	self.animation:change(self.movement)

	self.initialY = self.y
end

function PlayerJumpState:update(dt)
	self.vy = self.vy + (self.gravity + self.ay) * dt
	self.y = self.y + self.vy * dt

	if self.initialY - self.y > 15 and self.jumping and love.keyboard.isDown('up') then
		self.jumping = false
		self.vy = -539
		self.gravity = 2905.2
		self.ay = -1967.6
	end
	if not love.keyboard.isDown('up') then
		self.ay = 0
	end

	self.collisionV, self.collisionH, self.sides = self:checkCollision()
	if love.keyboard.isDown('left') and self.collisionH ~= 'left' then
		self.ax = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and -360 or -260
		self.movement = 'left'
		self.animation:change('left')
	end

	if love.keyboard.isDown('right') and self.collisionH ~= 'right' then
		self.ax = (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and 360 or 260
		self.movement = 'right'
		self.animation:change('right')
	end

	self.vx = (self.collisionH == 'right' or self.collisionH == 'left') and 0 or self.vx
	self.vx = self.vx + (self.ax - 1*self.vx) * dt
	self.x = self.x + self.vx * dt

	self.vx = (math.abs(self.vx) < 40  and not( love.keyboard.isDown('left') or love.keyboard.isDown('right'))) and 0 or self.vx
	self.x = self.x <= 0 and 0 or self.x
	self.x = self.x >= 8360 - self.width and 8360 - self.width or self.x

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

	if self.vy > 0 or self.collisionV == 'up' then
		self.CBMario:change('fall', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
	end
	if type(self.sides) == 'table' then
		self.objects[self.sides[2]][self.sides[1]]:onCollide(self)
	end

	if self.x > 8000 then
		self.CBMario.playState.music:stop()
		self.CBMario.playState.hurry:stop()
		stateMachine:change('victory',{time = self.CBMario.playState.time})
	end

	self.animation:update(dt)
end

function PlayerJumpState:removeObject(brick)
	local i
	local j
	i, j= toIndex(brick.x, brick.y)
	self.objects[j][i] = nil
end

function PlayerJumpState:checkCollision()
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
	y3 = y3 < 1 and 3 or y3
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
		return false, false, false
	else
		local collisionV = false
		local collisionH = false
		local sides = {}
		local side
		local hitBlock = false
		for k, v in ipairs(coordinate) do
			local result, side = self:Collision(self.objects[v[2]][v[1]])
			if result == 'left' or result == 'right' then
				collisionH = result
				table.insert(sides, false)
			elseif result == 'up' or result == 'down' then
				collisionV = result
				table.insert(sides, side)
			end
		end

		for k, v in ipairs(sides) do
			if type(v) == 'table' then
				hitBlock = true
				side = v
			end
		end

		if hitBlock == false then
			for k, v in ipairs(sides) do
				if v == 'left' then
					local collisionBlock = self.objects[coordinate[k][2]][coordinate[k][1]]
					self.x = collisionBlock.x - self.width - 1
					collisionV = collisionV ~= 'up' and collisionV or false
				elseif v == 'right' then
					local collisionBlock = self.objects[coordinate[k][2]][coordinate[k][1]]
					self.x = collisionBlock.x + collisionBlock.width + 1
					collisionV = collisionV ~= 'up' and collisionV or false
				end
			end
		end

		return collisionV, collisionH, side
	end
end

function PlayerJumpState:Collision(object)
	local w = 0.5 * (self.width + 40)
	local h = 0.5 * (self.height + 40)

	local collisionBlock = object

	local deltaY =	(collisionBlock.y + collisionBlock.height/2) - (self.y + self.height/2)
	local deltaX = (collisionBlock.x + collisionBlock.width/2) - (self.x + self.width/2)

	local pixelY = h - math.abs(deltaY)
	local pixelX = w - math.abs(deltaX)

	if pixelY > pixelX then
		if deltaX > 0 then
			self.x = collisionBlock.x - self.width - 1
			return 'right'
		else
			self.x = collisionBlock.x + collisionBlock.width + 1
			return 'left'
		end
	else
		if deltaY > 0 then
			self.y = collisionBlock.y - self.height
			return 'down'
		else
			self.y = collisionBlock.y + collisionBlock.height

			local side
			if deltaX > 0 then
				if self.x + self.width/2 > collisionBlock.x then
					side = {math.floor(collisionBlock.x/tileLength) + 1, math.floor(collisionBlock.y/tileLength) + 1}
				else
					side = 'left'
				end
			else
				if self.x + self.width/2 < collisionBlock.x + collisionBlock.width then
					side = {math.floor(collisionBlock.x/tileLength) + 1, math.floor(collisionBlock.y/tileLength) + 1}
				else
					side = 'right'
				end
			end

			return 'up', side
		end
	end
end

function PlayerJumpState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end

