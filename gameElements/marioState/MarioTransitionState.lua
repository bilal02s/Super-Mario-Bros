MarioTransitionState = Class{__includes = BaseState}

function MarioTransitionState:init(playState)
	self.originalMarioState = playState.marioState
	self.playState = playState
	self.timer = 0
	self.previousTime = 0
	self.quad = 'smallMario'
	self.currentFrame = 8
	self.scale = 2.5
	self.scaleX = 1 * self.scale
	self.scaleY = 1 * self.scale
	self.counter = 0
	self.width = 15 * self.scale
end

function MarioTransitionState:open(param)
	self.x = param.x
	self.y = param.y
	self.staticY = self.y
	self.movement = param.movement
	self.vy = param.vy or 0
	self.target = param.target
	self.timer = 0
	self.previousTime = 0
	self.counter = 0

	self.quad = 'smallMario'
	if self.target == 'smallMario' or self.target == 'shootingMario' then self.quad = 'bigMario' end
	if self.target == 'marioDie' then
		self.playState.music:stop()
		self.playState.hurry:stop()
	end
end

function MarioTransitionState:update(dt)
	self.timer = self.timer + dt

	if self.target == 'bigMario' then
		self.currentFrame = self.movement == 'right' and 8 or 7
		if self.timer - self.previousTime > 0.08 then
			self.previousTime = self.timer
			self.counter = self.counter + 1
			self.quad = (self.counter == 2 or self.counter == 4 or self.counter == 7) and 'smallMario' or 'bigMario'
			if self.counter == 0 or self.counter == 2 or self.counter == 4 or self.counter == 6 or self.counter == 7 or self.counter == 9 then
				self.scaleY = 1 * self.scale
			elseif self.counter == 1 then self.scaleY = 4/6 *self.scale
			elseif self.counter == 3 or self.counter == 5 then self.scaleY = 5/6 * self.scale end
			self.y = self.quad == 'bigMario' and self.staticY - (16 * (self.scaleY-(0.5*self.scale))*2) or self.staticY
		end
		if self.timer > 0.8 then
			self.originalMarioState:change('bigMario', {
				x = self.x,
				y = self.y,
				movement = self.movement,
				vy = self.vy
			})
		end
	elseif self.target == 'smallMario' then
		self.currentFrame = self.movement == 'right' and 8 or 7
		if self.timer - self.previousTime > 0.1 then
			self.previousTime = self.timer
			self.counter = self.counter + 1
			if self.counter % 2 == 0 then
				self.quad = 'bigMario'
				self.y = self.y - (16 * self.scale)
			else
				self.quad = 'smallMario'
				self.y = self.y + (16 * self.scale)
			end
		end
		if self.timer > 1 then
			self.y = self.staticY --+ (16 * self.scale)
			self.originalMarioState:change('recovery', {
				x = self.x,
				y = self.y,
				movement = self.movement,
				vy = self.vy
			})
		end
	elseif self.target == 'shootingMario' then
		if self.timer - self.previousTime > 0.1 then
			self.previousTime = self.timer
			self.counter = self.counter + 1
			if self.counter % 2 == 0 then
				self.currentFrame = self.movement == 'right' and 8 or 7
				self.quad = 'bigMario'
			else
				self.currentFrame = self.movement == 'right' and 9 or 8
				self.quad = 'shootingMario'
			end
		end
		if self.timer > 0.8 then
			self.originalMarioState:change('shootingMario', {
				x = self.x,
				y = self.y,
				movement = self.movement,
				vy = self.vy
			})
		end
	elseif self.target == 'marioDie' then
		self.currentFrame = 1
		self.vy = self.vy + 1000*dt
		self.y = self.y + self.vy*dt
		if self.timer > 3.5 then
			self.newLife = self.playState.life - 1
			if self.newLife > 0 then
				self.objects, self.entities, self.levelData = createMap(1)
				stateMachine:change('play',{
					entities = self.entities,
					objects = self.objects,
					levelData = self.levelData,
					life = self.newLife,
				})
			elseif self.newLife == 0 then
				stateMachine:change('gameOver')
			end
		end
	end
end

function MarioTransitionState:draw()
	love.graphics.draw(images['mario'], frames[self.quad][self.currentFrame], self.x, self.y, 0, self.scaleX, self.scaleY)
end
