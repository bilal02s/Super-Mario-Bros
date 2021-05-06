PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(currentMarioState, animation)
	self.originalMarioState = currentMarioState.originalMarioState
	self.CBMario = currentMarioState
	self.id = currentMarioState.id

	self.gameElements = currentMarioState.gameElements
	self.entities = self.gameElements.entities
	self.objects = self.gameElements.objects

	self.scale = self.CBMario.scale
	self.width = self.CBMario.width
	self.height = self.CBMario.height

	self.image = currentMarioState.image
	self.quad = currentMarioState.quad

	self.animation = AnimationState(animation)

end

function PlayerIdleState:open(param)
	self.x = param.x
	self.y = param.y
	self.vx = param.vx or 0
	self.vy = param.vy or 0
	self.movement = param.movement
	self.animation:change(self.movement)

	if self.vy ~= 0 then
		self.CBMario:change('fall', {
			x = self.x,
			y = self.y,
			vy = self.vy or 0,
			vx = self.vx or 0,
			movement = self.movement
		})
	end
end

function PlayerIdleState:update(dt)
	if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
		self.CBMario:change('walk', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
	elseif love.keyboard.wasPressed('space') or love.keyboard.wasPressed('up') then
		self.CBMario:change('jump', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
	end

	self.collisionV, self.collisionH = checkCollision(self)
	if self.collisionV ~= 'down' then
		self.CBMario:change('fall', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
	elseif self.collisionV == 'down' and love.keyboard.wasPressed('down') and (self.id == 'big' or self.id == 'shooting') then
		self.CBMario:change('crouch', {x = self.x, y = self.y, vx = self.vx, movement = self.movement})
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

	self.animation:update(dt)
end

function PlayerIdleState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end
