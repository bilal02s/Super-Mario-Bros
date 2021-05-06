PlayerCrouchState = Class{__includes = BasesState}

function PlayerCrouchState:init(currentMarioState, animation)
	self.originalMarioState = currentMarioState.originalMarioState
	self.CBMario = currentMarioState
	self.id = currentMarioState.id

	self.gameElements = currentMarioState.gameElements
	self.entities = self.gameElements.entities
	self.objects = self.gameElements.objects

	self.scale = self.CBMario.scale
	self.width = self.CBMario.width
	self.height = self.CBMario.height * 23/32

	self.image = currentMarioState.image
	self.quad = currentMarioState.quad

	self.animation = AnimationState(animation)

end

function PlayerCrouchState:open(param)
	self.x = param.x
	self.y = param.y + 9 * self.scale
	self.vx = param.vx or 0
	self.movement = param.movement
	self.animation:change(self.movement)
end

function PlayerCrouchState:update(dt)
	if not love.keyboard.isDown('down') then
		self.CBMario:change('walk', {x = self.x, y = self.y - 9*self.scale,vx = self.vx, movement = self.movement})
	end

	self.vx = self.vx + (- 2*self.vx) * dt
	self.x = self.x + self.vx * dt

	self.collisionV, self.collisionH = checkCollision(self)
	if self.collisionV ~= 'down' then
		self.CBMario:change('fall', {x = self.x, y = self.y,vx = self.vx, movement = self.movement})
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
				elseif self.id == 'big' then
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
		end
	end

	self.animation:update(dt)
end

function PlayerCrouchState:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0, self.scale, self.scale)
end

