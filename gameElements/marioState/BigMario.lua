BigMario = Class{__includes = BaseState}

function BigMario:init(playState, id)
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
	self.quad = 'bigMario'

	self.animation = {
		['right'] = {frames = {11, 10, 9}, interval = 0.15, currentFrame = 1},
		['left'] = {frames = {4, 5, 6}, interval = 0.15, currentFrame = 1},
		['changeR'] = {frames = {3}, interval = 10, currentFrame = 1},
		['changeL'] = {frames = {12}, interval = 10, currentFrame = 1},
		['idleR'] = {frames = {8}, interval = 10, currentFrame = 1},
		['idleL'] = {frames = {7}, interval = 10, currentFrame = 1},
		['jumpR'] = {frames = {13}, interval = 10, currentFrame = 1},
		['jumpL'] = {frames = {2}, interval = 10, currentFrame = 1},
		['crouchR'] = {frames = {14}, interval = 10, currentFrame = 1},
		['crouchL'] = {frames = {1}, interval = 10, currentFrame = 1},
	}

	self.playerState = PlayerState({
		['walk'] = function() return PlayerWalkState(self, {['right'] = self.animation['right'], ['left'] = self.animation['left'], ['changeR'] = self.animation['changeR'], ['changeL'] = self.animation['changeL']}) end,
		['idle'] = function() return PlayerIdleState(self, {['right'] = self.animation['idleR'], ['left'] = self.animation['idleL']}) end,
		['jump'] = function() return PlayerJumpState(self, {['right'] = self.animation['jumpR'], ['left'] = self.animation['jumpL']}) end,
		['fall'] = function() return PlayerFallState(self, {['right'] = self.animation['jumpR'], ['left'] = self.animation['jumpL']}) end,
		['crouch'] = function() return PlayerCrouchState(self, {['right'] = self.animation['crouchR'], ['left'] = self.animation['crouchL']}) end
	})
end

function BigMario:open(param)
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

function BigMario:change(state, param)
	self.playerState:change(state, param)
end

function BigMario:update(dt)
	self.playerState:update(dt)
	self.x = self.playerState.current.x
	self.y = self.playerState.current.y
	self.movement = self.playerState.current.movement
end

function BigMario:draw()
	self.playerState:draw()
end
