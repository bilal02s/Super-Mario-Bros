Entity = Class{}

function Entity:init(position, def, objects)
	self.scale = def.scale
	self.x = (position[1] - 1) * 40
	self.y = (position[2] - 1) * 40
	self.movement = def.movement
	self.dim = def.dim
	self.id = def.id

	self.objects = objects
	self.consumable = def.consumable
	self.enemy = def.enemy
	self.speed = def.speed
	self.images = def.images
	self.quads = def.quads
	self.animation = def.animation
	self.stateMachine = PlayerState(def.stateMachine(self))
	self.onCollide = def.onCollide
	self.finishTimerFunction = def.finishTimerFunction

	self.showedUp = false
	self.inPlay = false
	self.inGame = true
end

function Entity:change(state, param)
	self.stateMachine:change(state, {
		x = self.x,
		y = self.y,
		movement = self.movement,
		param = param,
	})
end

function Entity:update(dt)
	self.stateMachine:update(dt)
	self.x = self.stateMachine.current.x or self.x
	self.y = self.stateMachine.current.y or self.y
	self.movement = self.stateMachine.current.movement or self.movement
end

function Entity:draw()
	self.stateMachine:draw()
end


