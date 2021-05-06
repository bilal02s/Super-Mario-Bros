local entities = {
	[1] = {scale = 1, consumable = true, speed = 0, enemy = false, movement = 'right', -- POWERUP FLOWER
		dim = {
			['idle'] = {width = 40, height = 40},
		},
		images = {
			['idle'] = 'objects',
		},
		quads = {
			['idle'] = 'flower',
		},
		stateMachine = function(this)
			return {
				['walk'] = function() return EntityIdleState(this) end,
				['idle'] = function() return EntityIdleState(this) end,
			}
			end,
		animation = function()
			return{
			['idle'] = {
				['right'] = {frames = {1, 2, 3, 4}, interval = 0.1, currentFrame = 1},
				['left'] = {frames = {1, 2, 3, 4}, interval = 0.1, currentFrame = 1},
			},
		}end,
		finishTimerFunction = function(this)
			this:change('walk')
		end,
		onCollide = function(this, currentPlayerState)
			soundEffects['powerUpConsume']:play()
			table.insert(score, Score(this.x, this.y - 20, 1000))
			scores = scores + 1000
			local id = currentPlayerState.id
			if id == 'small' or id == 'recovery' then
				currentPlayerState.originalMarioState:change('transition', {
					x = currentPlayerState.x,
					y = currentPlayerState.y,
					vy = currentPlayerState.vy or 0,
					movement = currentPlayerState.movement,
					target = 'bigMario'
				})
			elseif id == 'big' then
				currentPlayerState.originalMarioState:change('transition', {
					x = currentPlayerState.x,
					y = currentPlayerState.y,
					vy = currentPlayerState.vy or 0,
					movement = currentPlayerState.movement,
					target = 'shootingMario'
				})
			end
			this.inGame = false
		end,
	},
	[2] = {scale = 1,  consumable = true, speed = 100, enemy = false, movement = 'right', -- POWERUP MUSHROOM
		dim = {
			['walk'] = {width = 40, height = 40},
			['idle'] = {width = 40, height = 40},
		},
		images = {
			['walk'] = 'objects',
			['idle'] = 'objects',
		},
		quads = {
			['walk'] = 'powerUpMushroom',
			['idle'] = 'powerUpMushroom',
		},
		stateMachine = function(this)
			return{
				['walk'] = function() return EntityWalkState(this) end,
				['idle'] = function() return EntityIdleState(this) end,
			}
			end,
		animation = function()
			return{
			['walk'] = {
				['right'] = {frames = {1}, interval = 100, currentFrame = 1},
				['left'] = {frames = {1}, interval = 100, currentFrame = 1},
			},
			['idle'] = {
				['right'] = {frames = {1}, interval = 100, currentFrame = 1},
				['left'] = {frames = {1}, interval = 100, currentFrame = 1},
			},
		}end,
		finishTimerFunction = function(this)
			this:change('walk')
		end,
		onCollide = function(this, currentPlayerState)
			soundEffects['powerUpConsume']:play()
			table.insert(score, Score(this.x, this.y - 20, 1000))
			scores = scores + 1000
			local id = currentPlayerState.id
			if id == 'small' or id == 'recovery' then
				currentPlayerState.originalMarioState:change('transition', {
					x = currentPlayerState.x,
					y = currentPlayerState.y,
					vy = currentPlayerState.vy or 0,
					movement = currentPlayerState.movement,
					target = 'bigMario'
				})
			end
			this.inGame = false
		end,
	},
	[3] = {scale = 2.25, consumable = false, speed = -60, enemy = true, movement = 'left', -- ENEMY MUSHROOM
		dim = {
			['walk'] = {width = 15.55, height = 20},
			['die'] = {width = 15.55, height = 20},
			['smash'] = {width = 15.55, height = 9},
		},
		images = {
			['walk'] = 'enemies',
			['die'] = 'enemies',
			['smash'] = 'enemies',
		},
		quads = {
			['walk'] = 'enemyMushroom',
			['die'] = 'enemyMushroom',
			['smash'] = 'smashedMushroom',
		},
		stateMachine = function(this)
			return{
				['walk'] = function() return EntityWalkState(this) end,
				['die'] = function() return EntityDieState(this) end,
				['smash'] = function() return EntitySmashState(this) end,
			}
			end,
		animation = function()
			return{
			['walk'] = {
				['right'] = {frames = {1, 2}, interval = 0.2, currentFrame = 1},
				['left'] = {frames = {1, 2}, interval = 0.2, currentFrame = 1},
			},
			['smash'] = {
				['idle'] = {frames = {1}, interval = 10, currentFrame = 1},
			},
			['die'] = {
				['left'] = {frames = {1, 2}, interval = 0.2, currentFrame = 1},
				['right'] = {frames = {1, 2}, interval = 0.2, currentFrame = 1},
			},
		}end,
		onCollide = function(this)
			this.inPlay = false
			this:change('smash')
		end,
	},
	[4] = {scale = 2.3, consumable = false, speed = -60, enemy = true, movement = 'left', -- ENEMY TURTLE
		dim = {
			['walk'] = {width = 15.55, height = 23},
			['die'] = {width = 15.55, height = 23},
			['roll'] = {width = 16, height = 15},
		},
		images = {
			['walk'] = 'enemies',
			['die'] = 'enemies',
			['roll'] = 'enemies',
		},
		quads = {
			['walk'] = 'turtle',
			['die'] = 'turtle',
			['roll'] = 'turtleShell',
		},
		stateMachine = function(this)
			return{
				['walk'] = function() return EntityWalkState(this) end,
				['die'] = function() return EntityDieState(this) end,
				['roll'] = function() return EntityRollState(this) end,
			}
			end,
		animation = function()
			return{
			['walk'] = {
				['right'] = {frames = {5, 6}, interval = 0.2, currentFrame = 1},
				['left'] = {frames = {3, 4}, interval = 0.2, currentFrame = 1},
			},
			['die'] = {
				['left'] = {frames = {3, 4}, interval = 0.2, currentFrame = 1},
				['right'] = {frames = {5, 6}, interval = 0.2, currentFrame = 1},
			},
			['roll'] = {
				['idle'] = {frames = {1}, interval = 10, currentFrame = 1},
			},
		}end,
		onCollide = function(this, currentPlayerState)
			soundEffects['kick']:play()
			if not this.stateMachine.current.rolled or this.stateMachine.current.rolling then
				this:change('roll', {entities = currentPlayerState.entities})
			elseif this.stateMachine.current.rolled then
				if currentPlayerState.x + currentPlayerState.width/2 < this.x + this.stateMachine.current.width/2 then
					this.stateMachine.current.vx = 500
					this.stateMachine.current.movement = 'right'
				else
					this.stateMachine.current.vx = -500
					this.stateMachine.current.movement = 'left'
				end
			end
		end,
	},
	[5] = {scale = 1, consumable = true, speed = 0, enemy = false, movement = 'right', -- COIN
		dim = {['idle'] = {width = 40, height = 40},},
		images = {['idle'] = 'objects',},
		quads = {['idle'] = 'coinSpin',},
		stateMachine = function(this)
			return {
				['walk'] = function() return EntityIdleState(this) end,
				['idle'] = function() return EntityIdleState(this) end,
			}
			end,
		animation = function()
			return {
			['idle'] = {
				['right'] = {frames = {1, 2, 3, 4}, interval = 0.1, currentFrame = 1},
				['left'] = {frames = {1, 2, 3, 4}, interval = 0.1, currentFrame = 1},
			},
		}end,
		finishTimerFunction = function(this)
			this.inGame = false
		end,
		onCollide = function(this, currentPlayerState) end,
	},
}

local property = {
	[1] = {scale = 1, width = 40, height = 40, entity = entities, -- MYSTERY BLOCK POWERUP
		image = 'objects', quad = 'mysteryBlock',
		animation = {frames = {1, 2, 3, 2, 1}, interval = 0.2, currentFrame = 1},
		onCollide = function(this, currentPlayerState)
			if this.quad ~= 'emptyMB' then
				soundEffects['powerUpAppear']:play()
				this.image = 'blocks'
				this.quad = 'emptyMB'
				this.animation = Animation({frames = {1}, interval = 1000, currentFrame = 1})
				this.timer:emit('y', this.y, this.y - 10, 0.1, function(this2) this2:emit('y', this.y, this.y + 10, 0.1, function(this2) this2.finishTasks = true end) end)
				local entities = currentPlayerState.entities
				local id = currentPlayerState.id
				local index = (id == 'small') and 2 or 1
				local indexT = countTable(entities)
				entities[indexT] = Entity({toIndex(this.x, this.y)}, this.entity[index], currentPlayerState.objects)
				entities[indexT]:change('idle')
				entities[indexT].inPlay = true
				entities[indexT].stateMachine.current.timer:emit('y', this.y, this.y - tileLength, 1, function(this2) this2.finishTasks = true end)
			else
				soundEffects['bump']:play()
			end
		end,},
	[2] = {scale = 1, width = 40, height = 40, entity = entities,-- MYSTERY BLOCK COIN
		image = 'objects', quad = 'mysteryBlock',
		animation = {frames = {1, 2, 3, 2, 1}, interval = 0.2, currentFrame = 1},
		onCollide = function(this, currentPlayerState)
			if this.quad ~= 'blocks' then
				soundEffects['coin']:stop()
				soundEffects['coin']:play()
				scores = scores + 200
				coins = coins + 1
				this.image = 'blocks'
				this.quad = 'blocks'
				this.animation = Animation({frames = {1}, interval = 1000, currentFrame = 1})
				this.timer:emit('y', this.y, this.y - 10, 0.1, function(this2) this2:emit('y', this.y, this.y + 10, 0.1, function() end) end)
				local entities = currentPlayerState.entities
				local index = countTable(entities)
				entities[index] = Entity({toIndex(this.x, this.y)}, this.entity[5], currentPlayerState.objects)
				entities[index]:change('idle')
				entities[index].stateMachine.current.timer:emit('y', this.y, this.y - 3*tileLength, 0.5, function(this2) this2:emit('y', this.y - 3*tileLength, this.y, 0.33, function(this3) this3.finishTasks = true end) end)
			else
				soundEffects['bump']:play()
			end
		end,
	},
	[3] = {scale = 1, width = 40, height = 40, -- BRICK
		image = 'blocks', quad = 'blocks',
		animation = {frames = {4}, interval = 1000, currentFrame = 1},
		onCollide = function(this, currentPlayerState)
			local id = currentPlayerState.id
			if id == 'small' then
				soundEffects['bump']:play()
				this.timer:emit('y', this.y, this.y - 10, 0.1, function(this2) this2:emit('y', this.y, this.y + 10, 0.1, function() end) end)
			else
				soundEffects['breakBlock']:stop()
				soundEffects['breakBlock']:play()
				table.insert(PS, BrickParticleSystem(this))
				currentPlayerState:removeObject(this)
			end
		end,
	},
	[4] = {scale = 1, width = 40, height = 40, -- PIPE
		image = 'pipe', quad = 'pipe',
		animation = {frames = {1}, interval = 1000, currentFrame = 1},
		onCollide = function() end,
	},
	[5] = {scale = 1, width = 40, height = 40, -- EMPTY BLOCK
		image = 'empty', quad = 'empty',
		animation = {frames = {1}, interval = 1000, currentFrame = 1},
		onCollide = function() end,
	},
	[6] = {scale = 1, width = 40, height = 40, -- COIN
		image = 'objects', quad = 'coin',
		animation = {frames = {1, 2, 3, 2, 1}, interval = 0.2, currentFrame = 1},
		onCollide = function(this)
			if not this.consumed then
				soundEffects['coin']:stop()
				soundEffects['coin']:play()
				this.consumed = true
			end
		end,
	},
	[7] = {scale = 1, width = 40, height = 40, -- GROUND BLOCK
		image = 'blocks', quad = 'blocks',
		animation = {frames = {2}, interval = 1000, currentFrame = 1},
		onCollide = function() end,
	},
	[8] = {scale = 1, width = 40, height = 40, -- STAIR BLOCK
		image = 'blocks', quad = 'blocks',
		animation = {frames = {5}, interval = 1000, currentFrame = 1},
		onCollide = function() end,
	},
}

function countTable(table)
	local count = 0
	for k, v in pairs(table) do
		if k > count then count = k end
	end
	return count + 1
end

local levelData = {
	[1] = {
		[1] = {
			[0] = {1, 2, 3, 4},
			[2200] = {5, 6},
			[3160] = {7, 8, 17},
			[3800] = {9, 10},
			[3980] = {11, 12, 13, 14},
			[6200] = {15, 16}
		},
		music = music['overGround'],
		hurry = music['hurryOverGround'],
		time = 160,
	}
}

function toIndex(x, y)
	return math.floor(x/tileLength) + 1, math.floor(y/tileLength) + 1
end

function createMap(k)
	local levels = {
		[1] = {
			row = 18, col = 210, skip = {70, 71, 87, 88, 89, 155, 156},
			objects = {
				[1] = {{22, 9}, {79, 9}, {110, 5}},
				[2] = {{17, 9}, {23, 5}, {24, 9}, {95, 5}, {107, 9}, {110, 9}, {113, 9}, {131, 5}, {132, 5}, {171, 9}},
				[3] = {{21, 9}, {23, 9}, {25, 9}, {78, 9}, {80, 9}, {{81, 5}, {88, 5}}, {{92, 5}, {94, 5}}, {95, 9}, {101, 9}, {102, 9}, {119, 9}, {{122, 5}, {125, 5}}, {130, 5}, {131, 9}, {132, 9}, {133, 5}, {169, 9}, {170, 9}, {172, 9}},
				[4] = {{29, 11}, {39, 10}, {47, 9}, {58, 9}, {164, 11}, {179, 11}},
				--[5] = {{9, 8}, {10, 8}, {11, 8}, {12, 8}, {13, 8}},
				[8] = {{{136, 12}, {139, 9}}, {{142, 9},{145, 12}}, {{150, 12}, {153, 9}}, {{154, 9}, {154, 12}}, {{157, 9}, {160, 12}}, {{181, 12}, {188, 5}}, {{189, 5}, {189, 12}}},
			},
			entities = {
				[1] = {},
				[2] = {},
				[3] = {{22, 12}, {42, 12}, {50, 12}, {51.3, 12}, {82, 4}, {83.4, 4}, {97, 12}, {101, 12}, {113, 12}, {114.5, 12}, {122, 12}, {123.3, 12}, {125.3, 12}, {126.6, 12}, {171, 12}, {172.3, 12}},
				[4] = {{109, 12}}
			},
		},
	}

	return createLevel(levels[k], k)
end

function createLevel(param, k)
	local gameObjects = {}
	local gameEntities = {}
	local tileLength = 40
	local counter = 1

	for j = 0, param.row - 1 do
		table.insert(gameObjects, {})
	end

	for j = 13, 14 do
		counter = 1
		for i = 1, param.col do
			if not table.contains(param.skip, i) then
				gameObjects[j][counter] = GameObject({i, j}, property[7])
			end
			counter = counter + 1
		end
	end

	for k1, v1 in pairs(param.objects) do
		if k1 ~= 4 then
			for k2, v2 in pairs(v1) do
				if type(v2[1]) == 'number' then
					gameObjects[v2[2]][v2[1]] = GameObject(v2, property[k1])
				else
					local incrementX = v2[1][1] <= v2[2][1] and 1 or -1
					local incrementY = v2[1][2] <= v2[2][2] and 1 or -1
					local counterX = 0
					local counterY = 0
					for j = v2[1][2], v2[2][2], incrementY do
						counterY = counterY + 1
						counterX = 0
						for i = v2[1][1], v2[2][1], incrementX do
							counterX = counterX + 1
							if (incrementY < 0 and counterX >= counterY) or (incrementY > 0 and counterX <= counterY) or v2[1][2] == v2[2][2] or v2[1][1] == v2[2][1] then
								gameObjects[j][i] = GameObject({i, j}, property[k1])
							end
						end
					end
				end
			end
		else
			for k2, v2 in pairs(v1) do
				gameObjects[v2[2]][v2[1]] = GameObject(v2, property[k1])
				gameObjects[v2[2]][v2[1]+1] = GameObject({v2[1]+1, v2[2]}, property[5])

				for i = v2[2] + 1, 12 do
					gameObjects[i][v2[1]] = GameObject({v2[1], i}, property[5])
					gameObjects[i][v2[1]+1] = GameObject({v2[1] + 1, i}, property[5])
				end
			end
		end
	end

	local counter = 1
	for k1, v1 in ipairs(param.entities) do
		for k2, v2 in ipairs(v1) do
			gameEntities[counter] = Entity(v2, entities[k1], gameObjects)
			counter = counter + 1
		end
	end

	return gameObjects, gameEntities, levelData[k]
end

function table.contains(table, value)
	for k, v in pairs(table) do
		if value == v then return true end
	end
	return false
end
