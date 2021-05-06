SmallMario = Class{__includes = BaseState}

function SmallMario:init(playState, id)
	self.originalMarioState = playState.marioState
	self.playState = playState
	self.id = id

	self.gameElements = playState.gameElements
	self.objects = self.gameElements.objects
	self.entities = self.gameElements.entities

	self.scale = 2.5
	self.width = 15 * self.scale
	self.height = 16 * self.scale

	self.image = 'mario'
	self.quad = 'smallMario'

	self.animation = {
		['right'] = {frames = {9, 10, 11}, interval = 0.15, currentFrame = 1},
		['left'] = {frames = {6, 5, 4}, interval = 0.15, currentFrame = 1},
		['changeR'] = {frames = {12}, interval = 10, currentFrame = 1},
		['changeL'] = {frames = {3}, interval = 10, currentFrame = 1},
		['idleR'] = {frames = {8}, interval = 10, currentFrame = 1},
		['idleL'] = {frames = {7}, interval = 10, currentFrame = 1},
		['jumpR'] = {frames = {13}, interval = 10, currentFrame = 1},
		['jumpL'] = {frames = {2}, interval = 10, currentFrame = 1}
	}

	self.playerState = PlayerState({
		['walk'] = function() return PlayerWalkState(self, {['right'] = self.animation['right'], ['left'] = self.animation['left'], ['changeR'] = self.animation['changeR'], ['changeL'] = self.animation['changeL']}) end,
		['idle'] = function() return PlayerIdleState(self, {['right'] = self.animation['idleR'], ['left'] = self.animation['idleL']}) end,
		['jump'] = function() return PlayerJumpState(self, {['right'] = self.animation['jumpR'], ['left'] = self.animation['jumpL']}) end,
		['fall'] = function() return PlayerFallState(self, {['right'] = self.animation['jumpR'], ['left'] = self.animation['jumpL']}) end
	})
end

function SmallMario:open(param)
	self.x = param.x
	self.y = param.y
	self.vx = param.vx or 0
	self.vy = param.vy or 0
	self.movement = param.movement

	self.playerState:change('idle', {
		x = self.x,
		y = self.y,
		vy = self.vy,
		vx = self.vx,
		movement = self.movement,
	})
end

function SmallMario:change(state, param)
	self.playerState:change(state, param)
end

function SmallMario:update(dt)
	self.playerState:update(dt)
	self.x = self.playerState.current.x
	self.y = self.playerState.current.y
	self.movement = self.playerState.current.movement
end

function SmallMario:draw()
	self.playerState:draw()
	love.graphics.print(tostring(self.x)..' '..tostring(self.y), 1400, 400)
end
