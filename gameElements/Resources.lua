Class = require 'stateMachine/class'

require 'gameElements/Util'

fonts = {
	['small'] = love.graphics.newFont('fonts/SuperMarioBros..ttf', 18),
	['medium'] = love.graphics.newFont('fonts/SuperMarioBros..ttf', 30),
	['large'] = love.graphics.newFont('fonts/SuperMarioBros..ttf', 48),
	['score'] = love.graphics.newFont('fonts/font.ttf', 25),
}

music = {
	['overGround'] = love.audio.newSource('songs/music/SuperMarioBros.mp3', 'stream'),
	['hurryOverGround'] = love.audio.newSource('songs/music/HurrySuperMario.mp3', 'stream'),
	['areaClear'] = love.audio.newSource('songs/music/AreaClear.mp3', 'static'),
}

soundEffects = {
	['gameOver'] = love.audio.newSource('songs/soundEffects/GameOver.mp3', 'static'),
	['1up'] = love.audio.newSource('songs/soundEffects/smb_1up.wav', 'static'),
	['bump'] = love.audio.newSource('songs/soundEffects/smb_bump.wav', 'static'),
	['breakBlock'] = love.audio.newSource('songs/soundEffects/smb_breakblock.wav', 'static'),
	['coin'] = love.audio.newSource('songs/soundEffects/smb_coin.wav', 'static'),
	['fireBall'] = love.audio.newSource('songs/soundEffects/smb_fireball.wav', 'static'),
	['fireworks'] = love.audio.newSource('songs/soundEffects/smb_fireworks.wav', 'static'),
	['flagpole'] = love.audio.newSource('songs/soundEffects/smb_flagpole.wav', 'static'),
	['smallJump'] = love.audio.newSource('songs/soundEffects/smb_jumpsmall.wav', 'static'),
	['bigJump'] = love.audio.newSource('songs/soundEffects/smb_jumpsuper.wav', 'static'),
	['kick'] = love.audio.newSource('songs/soundEffects/smb_kick.wav', 'static'),
	['powerDown'] = love.audio.newSource('songs/soundEffects/smb_pipe.wav', 'static'),
	['marioDie'] = love.audio.newSource('songs/soundEffects/smb_mariodie.wav', 'static'),
	['pause'] = love.audio.newSource('songs/soundEffects/smb_pause.wav', 'static'),
	['powerUpConsume'] = love.audio.newSource('songs/soundEffects/smb_powerup.wav', 'static'),
	['powerUpAppear'] = love.audio.newSource('songs/soundEffects/smb_powerup_appears.wav', 'static'),
	['stomp'] = love.audio.newSource('songs/soundEffects/smb_stomp.wav', 'static'),
	['vine'] = love.audio.newSource('songs/soundEffects/smb_vine.wav', 'static'),
	['warpPipe'] = love.audio.newSource('songs/soundEffects/WarpPipe.mp3', 'static'),
}

images = {
	['blocks'] = love.graphics.newImage('graphics/blocks.png'),
	['background'] = love.graphics.newImage('graphics/background.jpg'),
	['mario'] = love.graphics.newImage('graphics/mario.png'),
	['objects'] = love.graphics.newImage('graphics/objectss.png'),
	['enemies'] = love.graphics.newImage('graphics/enemies.png'),
	['pipe'] = love.graphics. newImage('graphics/pipe.png'),
	['empty'] = love.graphics. newImage('graphics/empty.png'),
}

frames = {
	['blocks'] = generateBlocks(images['blocks']),
	['brick'] = generateBlocks(images['blocks']),
	['emptyMB'] = generateBlocks(images['blocks']),
	['smallMario'] = generateSmallMario(images['mario']),
	['bigMario'] = generateBigMario(images['mario']),
	['shootingMario'] = generateShootingMario(images['mario']),
	['mysteryBlock'] = generateObjects(images['objects'], 0, 160, 40, 40, 3, 1, 0, 0),
	['coin'] = generateObjects(images['objects'], 0, 200, 40, 40, 3, 1, 0, 0),
	['coinSpin'] = generateObjects(images['objects'], 0, 240, 40, 40, 4, 1, 0, 0),
	['fireBall'] = generateObjects(images['objects'], 240, 359, 20, 20, 2, 2, 0, 0),
	['PS'] = generateObjects(images['objects'], 160, 0, 20, 20, 2, 2, 0, 0),
	['explosion'] = generateObjects(images['objects'], 280, 360, 40, 40, 1, 3, 0, 0),
	['enemyMushroom'] = generateObjects(images['enemies'], 0, 0, 15.55, 20, 2, 1, 14.5, 0),
	['smashedMushroom'] = generateObjects(images['enemies'], 60, 8, 15.55, 10, 1, 1, 14.5, 0),
	['turtle'] = generateObjects(images['enemies'], 90, 0, 15.5, 24, 8, 1, 14.5, 0),
	['turtleShell'] = generateObjects(images['enemies'], 360, 5, 16, 15, 1, 1, 14.5, 0),
	['pipe'] = generateObjects(images['pipe'], 0, 0, 80, 160, 1, 1, 0, 0),
	['empty'] = generateObjects(images['empty'], 0, 0, 40, 40, 1, 1, 0, 0),
	['powerUpMushroom'] = generateObjects(images['objects'], 0, 0, 40, 40, 3, 1, 0, 0),
	['flower'] = generateObjects(images['objects'], 0, 80, 40, 40, 4, 1, 0, 0),
	['star'] = generateObjects(images['objects'], 0, 120, 40, 40, 4, 1, 0, 0),
}

require 'stateMachine/StateMachine'
require 'stateMachine/PlayerState'
require 'stateMachine/BaseState'
require 'stateMachine/StartState'
require 'stateMachine/PlayState'
require 'stateMachine/VictoryState'
require 'stateMachine/GameOverState'

require 'gameElements/Animation'
require 'gameElements/AnimationState'
require 'gameElements/Timer'
require 'gameElements/LevelMaker'
require 'gameElements/GameObject'
require 'gameElements/Entity'
require 'gameElements/FireBall'
require 'gameElements/BrickParticleSystem'
require 'gameElements/Score'

require 'gameElements/playerState/PlayerWalkState'
require 'gameElements/playerState/PlayerIdleState'
require 'gameElements/playerState/PlayerFallState'
require 'gameElements/playerState/PlayerJumpState'
require 'gameElements/playerState/PlayerCrouchState'

require 'gameElements/marioState/SmallMario'
require 'gameElements/marioState/BigMario'
require 'gameElements/marioState/ShootingMario'
require 'gameElements/marioState/MarioTransitionState'
require 'gameElements/marioState/MarioRecoveryState'

require 'gameElements/entityState/EntityWalkState'
require 'gameElements/entityState/EntitySmashState'
require 'gameElements/entityState/EntityIdleState'
require 'gameElements/entityState/EntityRollState'
require 'gameElements/entityState/EntityDieState'
