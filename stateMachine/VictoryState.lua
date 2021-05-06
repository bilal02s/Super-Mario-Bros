VictoryState = Class{__includes = BaseState}

function VictoryState:init()
	music['areaClear']:play()
end

function VictoryState:open(param)
	self.time = param.time
end

function VictoryState:update(dt)
	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
		stateMachine:change('start')
	end
end

function VictoryState:draw()
	love.graphics.setFont(fonts['large'])
	love.graphics.printf('VICTORY', 0, Height/3, Width, 'center')
	love.graphics.printf('SCORE', 0 , Height/2, Width/2, 'center')
	love.graphics.printf('TIME LEFT', Width/2, Height/2, Width/2, 'center')
	love.graphics.printf(tostring(scores), 0 , Height/2 + 50, Width/2, 'center')
	love.graphics.printf(tostring(math.floor(self.time)), Width/2, Height/2 + 50, Width/2, 'center')
end
