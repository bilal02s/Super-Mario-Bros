StartState = Class{__includes = BaseState}

function StartState:init()

end

--function StartState:open(param)

--end

function StartState:update(dt)
	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
		self.objects, self.entities, self.levelData = createMap(1)
		stateMachine:change('play', {
			entities = self.entities,
			objects = self.objects,
			levelData = self.levelData,
			life = 3,
		})
	end
end

function StartState:draw()
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.setFont(fonts['large'])
	love.graphics.printf('SUPER MARIO BROS', 0, Height/3, Width, 'center')
	love.graphics.setFont(fonts['medium'])
	love.graphics.printf('Press ENTER to play', 0, Height/2, Width, 'center')
	love.graphics.setColor(1, 1, 1, 1)
end

