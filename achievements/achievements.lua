require("achievements/config")

AchievementSystem = {}
AchievementSystem.__index = AchievementSystem

function AchievementSystem.New()
	local achsys = {}
	setmetatable(achsys, AchievementSystem)

	achsys.fileLocation = "achievements.txt"
	achsys.isDrawing = false
	achsys.minXPos = -200
	achsys.xPos = achsys.minXPos
	achsys.waitTime = 200
	achsys.timeWaited = achsys.waitTime
	achsys.displayedName = "name"
	achsys.displayedDescription = "desctiption"
	achsys.displayedImage = 0
	achsys.waitTime = 200
	achsys.titleFont = love.graphics.newFont("achievements/res/Ubuntu-B.ttf", 15)
	achsys.descriptionFont = love.graphics.newFont("achievements/res/Ubuntu-B.ttf", 12)
	achsys.soundEffect = love.audio.newSource("achievements/res/SoundEffect.wav", "static")
	achsys.achievementData = {}
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
				self.xPos = self.minXPos
				self.timeWaited = self.waitTime

			end
		end
	end
end

function AchievementSystem:Update()
	if self.isDrawing then
		if self.timeWaited > 0 then
			if self.xPos < 5 then
				self.xPos = self.xPos + 10
			else
				self.timeWaited = self.timeWaited - 1
			end
		else
			if self.xPos > self.minXPos then
				self.xPos = self.xPos - 10
			else
				self.isDrawing = false
			end
		end
	end
end

function AchievementSystem:Draw()
	if self.isDrawing then
		r, g, b, a = love.graphics.getColor()
		font = love.graphics.getFont( )

		love.graphics.setColor(0, 100, 255, 255)
		love.graphics.rectangle("fill", self.xPos, 5, 200, 2)

		love.graphics.setColor(20, 20, 20, 255)
		love.graphics.rectangle("fill", self.xPos, 7, 200, 100)

		love.graphics.setColor(255, 255, 255, 255)

		love.graphics.setFont(self.titleFont)
		love.graphics.print(self.displayedName, self.xPos + 60, 10)

		love.graphics.setFont(self.descriptionFont)
		love.graphics.printf(self.displayedDescription, self.xPos + 60, 30, 140)

		love.graphics.draw(self.displayedImage, self.xPos + 5, 10)

		love.graphics.setFont( font )
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

asys = AchievementSystem.New(1000)