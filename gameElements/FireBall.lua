FireBall = Class{}

local sin = math.sin
local cos = math.cos
local rad = math.rad
local deg = math.deg

function FireBall:init(mario, k)
	self.scale = 1
	self.width = 20 * self.scale
	self.height = 20 * self.scale
	self.x = mario.x + (mario.width/2)*(1 + k) - (self.width/2)*(1 - k) -8*k
	self.y = mario.y + mario.height/2
	self.speed = 500
	self.angleSpeed = 300 * k
	self.k = k
	self.angle = k == 1 and -40 or 180 + 40
	self.objects = mario.objects
	self.entities = mario.entities
	self.image = 'objects'
	self.quad = 'fireBall'
	self.animation = AnimationState({
		['active'] = {frames = {1, 2, 3, 4}, interval = 0.1, currentFrame = 1},
		['explode'] = {frames = {1, 2, 3}, interval = 0.15, currentFrame = 1},
	})
	self.inPlay = true
	self.animation:change('active')
	self.timer = 0
	self.initialX = self.x
end

function FireBall:update(dt)
	self.x = self.x + self.speed*cos(rad(self.angle))*dt
	self.y = self.y - self.speed*sin(rad(self.angle))*dt
	self.angle = self.angle < -100 and self.angle + 360 or self.angle
	self.angle = self.angle - self.angleSpeed*dt
	self.angle = (self.k == 1 and self.angle <= -40) and -40 or self.angle
	self.angle = (self.k == -1 and self.angle >= 220) and 220 or self.angle

	self.collisionV, self.collisionH = self:checkCollision()
	if (self.collisionH or self.collisionV == 'up') and not self.collided then
		self.animation:change('explode')
		self.animation.timer = 0
		soundEffects['kick']:stop()
		soundEffects['kick']:play()
		self.quad = 'explosion'
		self.speed = 0
		self.collided = true
	end

	for k, entity in pairs(self.entities) do
		if (not self.collided) and self:entityCollision(entity) then
			if entity.enemy and entity.inPlay then
				entity:change('die', {k = self.k})
				self.x = entity.x
				self.y = entity.y
				self.speed = 0
				self.collided = true
				self.animation:change('explode')
				self.animation.timer = 0
				self.quad = 'explosion'
				soundEffects['kick']:stop()
				soundEffects['kick']:play()
				table.insert(score, Score(entity.x, entity.y - 20, 100))
				scores = scores + 100
			end
		end
	end

	if self.collided then
		self.timer = self.timer + dt
		if self.timer >= 0.45 then
			self.inPlay = false
		end
	end

	if self.x + self.width < 0 or self.x > 8360 or self.y > Height or (self.x - self.initialX)*self.k > Width then
		self.inPlay = false
	end

	self.animation:update(dt)
end

function FireBall:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end

function FireBall:entityCollision(entity)
	if (not entity.showedUp) or self.x + self.width < entity.stateMachine.current.x or self.x > entity.stateMachine.current.x + entity.stateMachine.current.width
		or self.y + self.height < entity.stateMachine.current.y or self.y > entity.stateMachine.current.y + entity.stateMachine.current.height then
		return false
	end

	return true
end

function FireBall:checkCollision()
	local x1 = math.floor(self.x/tileLength) + 1
	local y1 = math.floor(self.y/tileLength) + 1
	local x2 = math.floor((self.x + self.width)/tileLength) + 1
	local y2 = math.floor((self.y + self.height)/tileLength) + 1
	y1 = y1 < 1 and 1 or y1
	y2 = y2 < 1 and 1 or y2
	local coordinates = {}
	local coordinate = {}

	if self.objects[y1][x1] then
		coordinates[#coordinates + 1] = {x1 = x1, y1 = y1}
		coordinate[#coordinate + 1] = {x1, y1}
	end
	if self.objects[y2][x1] then
		coordinates[#coordinates + 1] = {x1 = x1, y2 = y2}
		coordinate[#coordinate + 1] = {x1, y2}
	end
	if self.objects[y2][x2] then
		coordinates[#coordinates + 1] = {x2 = x2, y2 = y2}
		coordinate[#coordinate + 1] = {x2, y2}
	end
	if self.objects[y1][x2] then
		coordinates[#coordinates + 1] = {x2 = x2, y1 = y1}
		coordinate[#coordinate + 1] = {x2, y1}
	end

	if #coordinates == 0 then
		return false
	elseif #coordinates == 1 then
		return self:Collision(coordinate[1])
	elseif #coordinates == 2 then
		if coordinates[1].x1 and coordinates[2].x1 then
			return false, 'left'
		elseif coordinates[1].x2 and coordinates[2].x2 then
			return false, 'right'
		elseif coordinates[1].y1 and coordinates[2].y1 then
			return 'up', false
		elseif coordinates[1].y2 and coordinates[2].y2 then
			self.angle = - self.angle
			return 'down', false
		--else
			--return Collision2(coordinate[1], self), Collision2(coordinate[2], self)
		end
	else
		self.x = (coordinate[2][1] - 1)*40
		self.y = (coordinate[2][2] - 1)*40
		return self:checkVertical(coordinates, y1, y2), self:checkHorizontal(coordinates, x1, x2)
	end
end

function FireBall:checkVertical(coordinates, y1, y2, self)
	if (coordinates[1].y2 and coordinates[2].y2) or (coordinates[1].y2 and coordinates[3].y2) or (coordinates[2].y2 and coordinates[3].y2) then
		return 'down'
	end
	if (coordinates[1].y1 and coordinates[2].y1) or (coordinates[1].y1 and coordinates[3].y1) or (coordinates[2].y1 and coordinates[3].y1) then
		return 'up'
	end
end

function FireBall:checkHorizontal(coordinates, x1, x2, self)
	if (coordinates[1].x1 and coordinates[2].x1) or (coordinates[1].x1 and coordinates[3].x1) or (coordinates[2].x1 and coordinates[3].x1) then
		return 'left'
	end
	if (coordinates[1].x2 and coordinates[2].x2) or (coordinates[1].x2 and coordinates[3].x2) or (coordinates[2].x2 and coordinates[3].x2) then
		return 'right'
	end
end

function FireBall:Collision(coordinate)
	local collisionBlock = self.objects[coordinate[2]][coordinate[1]]

	local w = 0.5 * (self.width + collisionBlock.width)
	local h = 0.5 * (self.height + collisionBlock.height)

	local deltaY = (collisionBlock.y + collisionBlock.height/2) - (self.y + self.height/2)
	local deltaX = (collisionBlock.x + collisionBlock.width/2) - (self.x + self.width/2)

	local pixelY = h - math.abs(deltaY)
	local pixelX = w - math.abs(deltaX)

	if pixelY > pixelX then
		if deltaX > 0 then
			return false, 'right'
		else
			return false, 'left'
		end
	else
		if deltaY > 0 then
			self.angle = -self.angle
			return 'down', false
		else
			return 'up', false
		end
	end
end



