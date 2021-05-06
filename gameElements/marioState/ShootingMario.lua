ShootingMario = Class{__includes = BaseState}

local fireBalls = {}

function ShootingMario:init(playState, id)
	self.originalMarioState = playState.marioState
	self.playState = playState
	self.id = id

	self.gameElements = playState.gameElements
	self.objects = self.gameElements.objects
	self.entities = self.gameElements.entities

	self.scale = 2.5
	self.width = 15 * self.scale
	self.height = 32 * self.scale

	self.image = 'mario'
	self.quad = 'shootingMario'

	self.animation = {
		['right'] = {frames = {12, 11, 10}, interval = 0.15, currentFrame = 1},
		['left'] = {frames = {5, 6, 7}, interval = 0.15, currentFrame = 1},
		['changeR'] = {frames = {3}, interval = 10, currentFrame = 1},
		['changeL'] = {frames = {14}, interval = 10, currentFrame = 1},
		['idleR'] = {frames = {9}, interval = 10, currentFrame = 1},
		['idleL'] = {frames = {8}, interval = 10, currentFrame = 1},
		['jumpR'] = {frames = {15}, interval = 10, currentFrame = 1},
		['jumpL'] = {frames = {2}, interval = 10, currentFrame = 1},
		['shootR'] = {frames = {13}, interval = 10, currentFrame = 1},
		['shootL'] = {frames = {4}, interval = 10, currentFrame = 1},
		['crouchR'] = {frames = {16}, interval = 10, currentFrame = 1},
		['crouchL'] = {frames = {1}, interval = 10, currentFrame = 1},
	}

	self.playerState = PlayerState({
		['walk'] = function() return PlayerWalkState(self, {['right'] = self.animation['right'], ['left'] = self.animation['left'] , ['shootL'] = self.animation['shootL'], ['shootR'] = self.animation['shootR'], ['changeR'] = self.animation['changeR'], ['changeL'] = self.animation['changeL']}) end,
		['idle'] = function() return PlayerIdleState(self, {['right'] = self.animation['idleR'], ['left'] = self.animation['idleL'], ['shootL'] = self.animation['shootL'], ['shootR'] = self.animation['shootR']}) end,
		['jump'] = function() return PlayerJumpState(self, {['right'] = self.animation['jumpR'], ['left'] = self.animation['jumpL'], ['shootL'] = self.animation['shootL'], ['shootR'] = self.animation['shootR']}) end,
		['fall'] = function() return PlayerFallState(self, {['right'] = self.animation['jumpR'], ['left'] = self.animation['jumpL'], ['shootL'] = self.animation['shootL'], ['shootR'] = self.animation['shootR']}) end,
		['crouch'] = function() return PlayerCrouchState(self, {['right'] = self.animation['crouchR'], ['left'] = self.animation['crouchL']}) end
	})

	self.shootTimer = 0
	self.shootInterval = 0.5
	self.shootAnimationTimer = 0
	self.fired = false
	self.readyToShoot = true
end

function ShootingMario:open(param)
	self.x = param.x
	self.y = param.y
	self.vx = param.vx or 0
	self.vy = param.vy or 0
	self.movement = param.movement

	self.playerState:change('idle', {
		x = self.x,
		y = self.y,
		vy = self.vy,
		movement = self.movement,
	})
end

function ShootingMario:change(state, param)
	self.playerState:change(state, param)
end

function ShootingMario:update(dt)
	self.playerState:update(dt)
	self.x = self.playerState.current.x
	self.y = self.playerState.current.y
	self.movement = self.playerState.current.movement

	self.shootTimer = self.shootTimer + dt
	if self.shootTimer > self.shootInterval then
		self.shootTimer = self.shootTimer % self.shootInterval
		self.readyToShoot = true
	end
	if self.fired then
		self.shootAnimationTimer = self.shootAnimationTimer + dt
		if self.shootAnimationTimer < 0.15 then
			local direction = self.movement == 'right' and 'shootR' or 'shootL'
			self.playerState.current.animation:change(direction)
		else
			self.fired = false
			self.shootAnimationTimer = 0
			self.playerState.current.animation:change(self.movement)
		end
	end

	if (love.keyboard.wasPressed('lshift') or love.keyboard.wasPressed('rshift')) and self.readyToShoot and (not love.keyboard.isDown('down')) then
		soundEffects['fireBall']:play()
		self.readyToShoot = false
		self.fired = true
		local k = self.movement == 'right' and 1 or -1
		table.insert(fireBalls, FireBall(self, k))
	end

	for k, fireBall in pairs(fireBalls) do
		fireBall:update(dt)

		if not fireBall.inPlay then
			table.remove(fireBalls, k)
		end
	end
end

function ShootingMario:draw()
	self.playerState:draw()

	for k, fireBall in pairs(fireBalls) do
		fireBall:draw()
	end
end
