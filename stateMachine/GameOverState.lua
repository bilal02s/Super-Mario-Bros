GameOverState = Class{__includes = BaseState}

function GameOverState:init()
	soundEffects['gameOver']:play()
end

function GameOverState:update(dt)
	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
		stateMachine:change('start')
	end
end

function GameOverState:draw()
	love.graphics.setFont(fonts['large'])
	love.graphics.printf('GAME OVER', 0, Height/3, Width, 'center')
	love.graphics.printf('press ENTER to play again', 0, Height/2 + 50, Width, 'center')
end
