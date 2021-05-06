BrickParticleSystem = Class{}

function BrickParticleSystem:init(brick)
	self.x = brick.x
	self.y = brick.y
	self.scale = 1
	self.width = 20 * self.scale
	self.height = 20 * self.scale
	self.image = 'objects'
	self.quad = 'PS'
	self.vx = 150
	self.vy1 = -200
	self.vy2 = -300
	self.gravity = 1000

	self.x1 = self.x
	self.x2 = self.x
	self.x3 = self.x + brick.width - self.width
	self.x4 = self.x + brick.width - self.width

	self.y1 = self.y
	self.y2 = self.y + brick.height - self.height
	self.y3 = self.y + brick.height - self.height
	self.y4 = self.y

	self.inGame = true
end

function BrickParticleSystem:update(dt)
	self.x1 = self.x1 - self.vx*dt
	self.x2 = self.x2 - self.vx*dt
	self.x3 = self.x3 + self.vx*dt
	self.x4 = self.x4 + self.vx*dt

	self.vy1 = self.vy1 + self.gravity*dt
	self.vy2 = self.vy2 + self.gravity*dt
	self.y1 = self.y1 + self.vy2*dt
	self.y2 = self.y2 + self.vy1*dt
	self.y3 = self.y3 + self.vy1*dt
	self.y4 = self.y4 + self.vy2*dt

	if self.y1 > Height then
		self.inGame = false
	end
end

function BrickParticleSystem:draw()
	love.graphics.draw(images[self.image], frames[self.quad][1], self.x1, self.y1, 0, self.scale, self.scale)
	love.graphics.draw(images[self.image], frames[self.quad][2], self.x2, self.y2, 0, self.scale, self.scale)
	love.graphics.draw(images[self.image], frames[self.quad][3], self.x3, self.y3, 0, self.scale, self.scale)
	love.graphics.draw(images[self.image], frames[self.quad][4], self.x4, self.y4, 0, self.scale, self.scale)
end
