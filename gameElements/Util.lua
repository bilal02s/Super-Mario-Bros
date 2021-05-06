function generateBlocks(atlas)
	x = 2.5
	y = 2.5
	local blocks = {}

	for i = 0, 4 do
		blocks[#blocks + 1] = love.graphics.newQuad(x, y, 40, 40, atlas:getDimensions())
		x = x + 40
	end

	return blocks
end

function generateSmallMario(atlas)
	x = 0
	y = 0
	local smallMario = {}

	table.insert(smallMario, love.graphics.newQuad(x, y + 16, 15, 16, atlas:getDimensions()))
	x = x + 29

	table.insert(smallMario, love.graphics.newQuad(x, y, 16.5, 16, atlas:getDimensions()))
	x = x + 30.3

	for i = 0, 9 do
		table.insert(smallMario, love.graphics.newQuad(x, y, 15, 16, atlas:getDimensions()))
		x = x + 30.25
	end

	table.insert(smallMario, love.graphics.newQuad(x - 1.8, y, 16.5, 16, atlas:getDimensions()))
	x = x + 26.1

	table.insert(smallMario, love.graphics.newQuad(x, y + 16, 16, 16, atlas:getDimensions()))

	return smallMario
end

function generateBigMario(atlas)
	local bigMario = {}
	x = 0
	y = 52

	table.insert(bigMario, love.graphics.newQuad(0, y + 4, 16, 23, atlas:getDimensions()))
	x = x + 29.9

	for i = 0, 11 do
		table.insert(bigMario, love.graphics.newQuad(x, y, 16, 32, atlas:getDimensions()))
		x = x + 29.9
	end

	table.insert(bigMario, love.graphics.newQuad(x, y + 4, 16, 23, atlas:getDimensions()))

	return bigMario
end

function generateShootingMario(atlas)
	local shootingMario = {}
	x = 0
	y = 122

	table.insert(shootingMario, love.graphics.newQuad(0, y + 4, 16, 23, atlas:getDimensions()))
	x = x + 26

	for i = 0, 13 do
		if i == 11 then x = x - 2 end
		if i == 6 then x = x - 2 end
		if i == 5 then x = x - 4 end
		if i == 8 then x = x + 2 end
		if i == 3 or i == 4 then x = x - 1.25 end
		table.insert(shootingMario, love.graphics.newQuad(x, y, 16, 32, atlas:getDimensions()))
		if i == 3 or i == 4 then x = x + 1.25 end
		if i == 8 then x = x - 3 end
		if i == 5 then x = x + 4 end
		if i == 6 then x = x + 3 end
		x = x + 26
	end

	table.insert(shootingMario, love.graphics.newQuad(x + 1, y + 4, 16, 23, atlas:getDimensions()))

	return shootingMario
end

function generateObjects(atlas, x, y, brickWidth, brickHeight, xIteration, yIteration, xSpace, ySpace)
	local blocks2 = {}

	for j = 0, yIteration - 1 do
		for i = 0, xIteration - 1 do
			blocks2[#blocks2 + 1] = love.graphics.newQuad(x + i*(brickWidth + xSpace), y + j*(brickHeight + ySpace), brickWidth, brickHeight, atlas:getDimensions())
		end
	end

	return blocks2
end
