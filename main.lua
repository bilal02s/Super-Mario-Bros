Width = 1000
Height = 560

require 'gameElements/Resources'

function love.load()

	love.window.setMode(Width, Height, {fullscreen = false,  resizable = false, vsync = true})
	love.window.setTitle('Super Mario Bros.')
	love.graphics.setDefaultFilter('nearest', 'nearest')

	music['overGround']:setLooping(true)

	stateMachine = StateMachine({
		['start'] = function() return StartState() end,
		['play'] = function() return PlayState() end,
		['victory'] = function() return VictoryState() end,
		['gameOver'] = function() return GameOverState() end,
	})
	stateMachine:change('start')
end

love.keyboard.keysPressed = {}
love.keyboard.keysReleased = {}

function love.keypressed(key)
	love.keyboard.keysPressed[key] = true

	if key == 'escape' then
		love.event.quit()
	end
end

function love.keyreleased(key)
	love.keyboard.keysReleased[key] = true
end

function love.keyboard.wasPressed(key)
	if love.keyboard.keysPressed[key] then
		love.keyboard.keysPressed[key] = false
		return true
	end

	return false
end

function love.keyboard.wasReleased(key)
	if love.keyboard.keysReleased[key] then
		love.keyboard.keysReleased[key] = false
		return true
	end

	return false
end

function love.update(dt)
	stateMachine:update(dt)

	love.keyboard.keysPressed = {}
end

function love.draw()
	love.graphics.draw(images['background'], 0, 0, 0, Width/images['background']:getWidth(), Height/images['background']:getHeight())

	stateMachine:draw()
	--love.graphics.print(collectgarbage("count"), 10, 100)
end

function getFPS(x)
	love.graphics.setFont(fonts['small'])
	love.graphics.print('FPS : '..tostring(love.timer.getFPS()), 10 + x, 80)
	--love.graphics.print('delta time : '..tostring(previousDelta), 10 + x, 30)

	--for i = 1, 2 do
	--love.graphics.draw(images['enemies'], frames['enemyMushroom'][i], 50 + (i * 50), 50, 0, 2, 2)
	--end
	--love.graphics.draw(images['empty'], 50, 50)
end

