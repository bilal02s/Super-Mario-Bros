PlayState = Class{__includes = BaseState}

tileLength = 40
PS = {}
score = {}
coins = 0
scores = 0

function PlayState:init()
	self.camera = 0
	self.mapEnd = 209 * tileLength - Width
	self.cameraSpeed = 300
	self.tileNumber = math.floor(self.camera/tileLength)
	self.shift = (self.camera/tileLength - self.tileNumber) * tileLength

	self.gravity = 1000
end

function PlayState:open(param)
	self.entities = param.entities
	self.objects = param.objects
	self.life = param.life
	self.levelData = param.levelData[1]
	self.music = param.levelData.music
	self.hurry = param.levelData.hurry
	self.time = param.levelData.time
	self.music:play()

	self.gameElements = {
		entities = self.entities,
		objects = self.objects
	}

	self.dim = {
		['small'] = {width = 15, height = 16},
		['big'] = {width = 16, height = 32},
		['shooting'] = {width = 16, height = 32},
	}

	self.marioState = PlayerState({
		['smallMario'] = function() return SmallMario(self, 'small') end,
		['bigMario'] = function() return BigMario(self, 'big') end,
		['shootingMario'] = function() return ShootingMario(self, 'shooting') end,
		['transition'] = function() return MarioTransitionState(self) end,
		['recovery'] = function() return MarioRecoveryState(self, 'recovery') end,
	})

	self.marioState:change('smallMario',{
		x = 40,
		y = 440,
		movement = 'right',
	})

	--self.timer = 0
	self.marioDie = false
	self.k = 1
end

function PlayState:change(state, param)
	self.marioState:change(state, param)
end

function PlayState:update(dt)
	self.time = self.time - self.k*dt

	if self.time < 40 and self.time ~= 0 then
		self.music:stop()
		self.hurry:play()
	end
	if self.time < 0 and not self.marioDie then
		self.marioDie = true
		self.k = 0
		self.time = 0
		self.hurry:stop()
		soundEffects['marioDie']:play()
		self.marioState:change('transition', {
			x = self.marioState.current.x,
			y = self.marioState.current.y,
			vy = -500,
			movement = self.marioState.current.movement,
			target = 'marioDie'
		})
	end

	self.camera = self.marioState.current.x + self.marioState.current.width/2 - Width/2
	self.camera = self.camera <= 0 and 0 or self.camera
	self.camera = self.camera >= self.mapEnd and self.mapEnd or self.camera
	self.tileNumber = math.floor(self.camera/tileLength)

	self.marioState:update(dt)
	--local t1 = love.timer.getTime()
	for k1, v1 in pairs(self.objects)do
		for k2, v2 in pairs(v1) do
			v2:update(dt)--update(v2, dt)--
		end
	end
	--local t2 = love.timer.getTime()
	--t3 = t2 - t1

	for k, v in pairs(self.entities)do
		v:update(dt)
		if not v.inGame then
			self.entities[k] = nil
		end
	end

	for k, v in pairs(score)do
		v:update(dt)
		if not v.inGame then
			score[k] = nil
		end
	end

	for k, v in pairs(PS) do
		v:update(dt)
		if not v.inGame then
			table.remove(PS, k)
		end
	end

	for k1, v1 in pairs(self.levelData) do
		if self.marioState.current.x > k1 then
			for k2, v2 in ipairs(v1) do
				if self.entities[v2] and self.entities[v2].enemy and not self.entities[v2].showedUp then
					self.entities[v2].showedUp = true
					self.entities[v2].inPlay = true
					self.entities[v2]:change('walk')
				end
			end
		end
	end
end

function PlayState:draw()
	love.graphics.translate(-self.camera, 0)

	for k, v in pairs(self.entities)do
		if not v.enemy then
			v:draw()
		end
	end

	for j = 1, 12 do
		for k2, v2 in pairs(self.objects[j]) do
			if k2 < self.tileNumber or k2 > self.tileNumber + 26 then goto continue end
			v2:draw()
			::continue::
		end
	end

	for j = 13, 14 do
		for i = self.tileNumber, self.tileNumber + 26 do
			if self.objects[j][i] then
				self.objects[j][i]:draw()
			end
		end
	end

	for k, v in pairs(PS)do
		v:draw()
	end

	for k, v in pairs(score)do
		v:draw()
	end

	for k, v in pairs(self.entities)do
		if v.enemy then
			v:draw()
		end
	end

	self.marioState:draw()

	getFPS(self.camera)
	love.graphics.setFont(fonts['medium'])
	love.graphics.printf('SCORE COINS WORLD TIME LIFE', self.camera + 30, 10, Width - 60, 'justify')
	love.graphics.printf(tostring(scores), self.camera + 30, 40, Width - 60 , 'left')
	love.graphics.printf(tostring(coins), self.camera + 30, 40, 0.5*(Width - 60), 'center')
	love.graphics.printf('1-1', self.camera + 50, 40, Width - 60, 'center')
	love.graphics.printf(tostring(math.floor(self.time*2.5)), self.camera + 30, 40, 1.5*(Width - 60), 'center')
	love.graphics.printf(tostring(self.life), self.camera + 30, 40, Width - 90, 'right')

	--love.graphics.printf(tostring(t3), self.camera + 30, 100, Width - 90, 'right')
end
