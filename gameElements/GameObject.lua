GameObject = Class{}

function GameObject:init(position, def)
	self.scale = def.scale
	self.width = def.width * self.scale
	self.height = def.height * self.scale
	self.onCollide = def.onCollide
	self.animation = Animation(def.animation)
	self.timer = returnTimer()
	self.finishTimer = false
	self.image = def.image
	self.quad = def.quad
	self.entity = def.entity
	--self[1] = GameObject.update

	self.x = (position[1] - 1) * self.width
	self.y = (position[2] - 1) * self.height
end

function GameObject:update(dt)
	self.animation:update(dt)
	self.timer:update(dt, self)
end

function GameObject:draw()
	love.graphics.draw(images[self.image], frames[self.quad][self.animation:getCurrentFrame()], self.x, self.y, 0 , self.scale, self.scale)
end

function update(self, dt)
	--self.animation:update(dt)
	--self.timer:update(dt, self)
end


