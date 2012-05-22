require("achievements/config")

AchievementSystem = {}
AchievementSystem.__index = AchievementSystem

function AchievementSystem.New()
	local achsys = {}
	setmetatable(achsys, AchievementSystem)

	achsys.fileLocation = "achievements.txt"
	achsys.isDrawing = false
	achsys.speed = 5
	achsys.xDirection = 1
	achsys.waitTime = 200
	achsys.imageSize = 60
	achsys.descriptionWidth = 150
	achsys.paddingSize = 5
	achsys.topSize = 2
	achsys.topColor = {r=0, g=100, b=200}
	achsys.backgroundColor = {r=22, g=22, b=22}
	achsys.timeWaited = achsys.waitTime
	achsys.displayedName = "placeholder"
	achsys.displayedDescription = "placeholder"
	achsys.displayedImage = "placeholder"
	achsys.titleFont = love.graphics.newFont("achievements/res/Ubuntu-B.ttf", 15)
	achsys.descriptionFont = love.graphics.newFont("achievements/res/Ubuntu-B.ttf", 12)
	achsys.soundEffect = love.audio.newSource("achievements/res/SoundEffect.wav", "static")
	achsys.achievementData = {}
	achsys.popupWidth = (achsys.paddingSize * 3) + achsys.descriptionWidth + achsys.imageSize
	achsys.startXPos = love.graphics.getWidth()
	achsys.waitXPos = love.graphics.getWidth() - achsys.popupWidth - 5
	AchievementSystemConfig(achsys)
	achsys:LoadFromFile()

	return achsys
end

function AchievementSystem:CreateAchievement(uniqueID_i, name_i, description_i, imageName_i)
	table.insert(self.achievementData, {uniqueID=uniqueID_i, name=name_i, description=description_i, image=love.graphics.newImage("achievements/img/"..imageName_i), unlocked=false})
end

function AchievementSystem:UnlockAchievement(uniqueIDi)
	for k, v in pairs(self.achievementData) do
		if v.uniqueID == uniqueIDi then
			if v.unlocked == true then
				return
			else
				v.unlocked = true
				self:SaveToFile()
				self.displayedName = v.name
				self.displayedDescription = v.description
				self.displayedImage = v.image
				love.audio.play(self.soundEffect)
				self.isDrawing = true
				self.xPos = self.startXPos
				self.timeWaited = self.waitTime

			end
		end
	end
end

function AchievementSystem:Update()
	if self.isDrawing then
		if self.timeWaited <= 0 then
			if self.xPos < self.startXPos then
				self.xPos = self.xPos + self.speed
			elseif self.xPos > self.startXPos then
				self.xPos = self.xPos - self.speed
			else
				self.isDrawing = false
			end
		else
			if self.xPos < self.waitXPos then
				self.xPos = self.xPos + self.speed
			elseif self.xPos > self.waitXPos then
				self.xPos = self.xPos - self.speed
			else
				self.timeWaited = self.timeWaited - 1
			end
		end
	end
end

function AchievementSystem:Draw()
	if self.isDrawing then
		r, g, b, a = love.graphics.getColor()
		font = love.graphics.getFont()
		

		love.graphics.setColor(self.topColor.r, self.topColor.g, self.topColor.b, 255)
		love.graphics.rectangle("fill", self.xPos, self.paddingSize, self.popupWidth, self.topSize)

		love.graphics.setColor(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, 255)
		love.graphics.rectangle("fill", self.xPos, self.paddingSize + self.topSize, self.popupWidth, self.imageSize + (self.paddingSize * 2))

		love.graphics.setColor(255, 255, 255, 255)

		love.graphics.setFont(self.titleFont)
		love.graphics.print(self.displayedName, self.xPos + self.imageSize + (self.paddingSize*2), self.paddingSize * 2)

		love.graphics.setFont(self.descriptionFont)
		love.graphics.printf(self.displayedDescription, self.xPos + self.imageSize + (self.paddingSize*2), 30, self.descriptionWidth)

		love.graphics.draw(self.displayedImage, self.xPos + self.paddingSize, self.topSize + (self.paddingSize * 2), 0, self.imageSize / self.displayedImage:getWidth(), self.imageSize / self.displayedImage:getHeight())
		
		if font then
			love.graphics.setFont(font)
		end
		love.graphics.setColor(r, g, b, a)
	end
end


function AchievementSystem:GetData()
	return self.achievementData
end

function AchievementSystem:LoadFromFile()
	if love.filesystem.exists(self.fileLocation) then
		for line in love.filesystem.lines(self.fileLocation) do
	  		for k, v in ipairs(self.achievementData) do
				if v.uniqueID == line then
					v.unlocked = true
				end
			end
		end
	end
end

function AchievementSystem:SaveToFile()
	s = ""
	for k, v in ipairs(self.achievementData) do
		if v.unlocked == true then
			s = s .. v.uniqueID .. "\n"
		end
	end

	file = love.filesystem.newFile(self.fileLocation)
	file:open('w')
	file:write(s)
	file:close()
end