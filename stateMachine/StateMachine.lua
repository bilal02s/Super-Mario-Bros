StateMachine = Class{}

function StateMachine:init(states)
	self.empty = {
		open = function() end,
		update = function() end,
		draw = function() end,
		exit = function() end
	}

	self.states = states
	self.current = self.empty
end

function StateMachine:change(state, param)
	assert(self.states[state])
	self.current:exit()
	self.current = self.states[state]()
	self.current:open(param)
end

function StateMachine:update(dt)
	self.current:update(dt)
end

function StateMachine:draw()
	self.current:draw()
end
