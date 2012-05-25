--This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
--
--Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
--
--1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
--
--2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--
--3. This notice may not be removed or altered from any source distribution.
--
--https://github.com/LiquidHelium/LoveAchievements


require("achievements/config")

AchievementSystem = {}
AchievementSystem.__index = AchievementSystem

function AchievementSystem.New()
	local achsys = {}
	setmetatable(achsys, AchievementSystem)

	achsys.achievementData = {}



	achsys.fileLocation = "achievements.txt"

	achsys.topUnlockedColor = {r=0, g=100, b=200}
	achsys.topLockedColor = {r=255, g=0, b=0}
	achsys.backgroundColor = {r=22, g=22, b=22}

	achsys.GUIbutton = "="

	achsys.speed = 5
	achsys.waitTime = 200

	achsys.imageSize = 60
	achsys.descriptionWidth = 150
	achsys.paddingSize = 5
	achsys.topSize = 2

	achsys.popupWidth = (achsys.paddingSize * 3) + achsys.descriptionWidth + achsys.imageSize
	achsys.popupHeight = (achsys.paddingSize * 2) + achsys.topSize + achsys.imageSize
	
	achsys.startXPos = love.graphics.getWidth()
	achsys.waitXPos = love.graphics.getWidth() - achsys.popupWidth - 5

	achsys.titleFont = love.graphics.newFont("achievements/res/Ubuntu-B.ttf", 15)
	achsys.descriptionFont = love.graphics.newFont("achievements/res/Ubuntu-B.ttf", 12)
	achsys.soundEffect = love.audio.newSource("achievements/res/SoundEffect.wav", "static")

	achsys.lockImage = love.graphics.newImage("achievements/res/lock.png")

	AchievementSystemConfig(achsys)
	achsys:LoadFromFile()

	achsys.displayIntro = true
	achsys.introDelayTime = 50
	achsys.introLogo = love.graphics.newImage("achievements/res/logo.png")
	achsys.introTitle = "Love Achievements"
	achsys.introDesc = "This Game Has Achievements. Press And Hold " .. achsys.GUIbutton .." To View"

	achsys.maxPopupsHorizontal = math.floor(love.graphics.getWidth() / (achsys.popupWidth + 2))
	achsys.totalPopupsVerticalSpace = math.floor((#achsys.achievementData)/achsys.maxPopupsHorizontal) * (achsys.popupHeight + 2) + 2
	if achsys.totalPopupsVerticalSpace > love.graphics.getHeight() then
		achsys.scrollUI = true
		achsys.maxScrollOffset = achsys.totalPopupsVerticalSpace - love.graphics.getHeight()
		achsys.scrollDirection = 1
		achsys.maxScrollWaitTime = 150
		achsys.scrollWaitTime = 0
	else
		achsys.scrollUI = false
	end
	achsys.scrollOffset = 0
	achsys.UIOffset = (love.graphics.getWidth() - ((achsys.maxPopupsHorizontal * (achsys.popupWidth + 2))+2))/2

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

	if love.keyboard.isDown(self.GUIbutton) then
		if self.scrollUI then
			self.scrollOffset = self.scrollOffset + self.scrollDirection
			if self.scrollOffset == 0 then
				if self.scrollWaitTime == self.maxScrollWaitTime then
					self.scrollDirection = 1
					self.scrollWaitTime = 0
				else
					self.scrollDirection = 0
					self.scrollWaitTime = self.scrollWaitTime + 1
				end
			elseif self.scrollOffset == self.maxScrollOffset then
				if self.scrollWaitTime == self.maxScrollWaitTime then
					self.scrollDirection = -1
					self.scrollWaitTime = 0
				else
					self.scrollDirection = 0
					self.scrollWaitTime = self.scrollWaitTime + 1
				end
			end
		end
	end

	if self.displayIntro then
		self.introDelayTime = self.introDelayTime - 1
		if self.introDelayTime == 0 then
			self.displayedName = self.introTitle
			self.displayedDescription = self.introDesc
			self.displayedImage = self.introLogo
			self.isDrawing = true
			self.xPos = self.startXPos
			self.timeWaited = self.waitTime
			self.displayIntro = false
		end
	end
end

function AchievementSystem:DrawPopup(x, y, name, description, image, topColor, drawLocks)
	drawLocks = drawLocks or false

	love.graphics.setColor(topColor.r, topColor.g, topColor.b, 255)
	love.graphics.rectangle("fill", x, y, self.popupWidth, self.topSize)

	love.graphics.setColor(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, 255)
	love.graphics.rectangle("fill", x, y + self.topSize, self.popupWidth, self.imageSize + (self.paddingSize * 2))

	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setFont(self.titleFont)
	love.graphics.print(name, x + self.imageSize + (self.paddingSize*2), self.paddingSize + y)

	love.graphics.setFont(self.descriptionFont)
	love.graphics.printf(description, x + self.imageSize + (self.paddingSize*2), y + (self.paddingSize*2) + 15, self.descriptionWidth)

	love.graphics.draw(image, x + self.paddingSize, y + self.topSize + self.paddingSize, 0, self.imageSize / image:getWidth(), self.imageSize / image:getHeight())
	if drawLocks then
		love.graphics.draw(self.lockImage, x + self.paddingSize, y + self.topSize + self.paddingSize, 0, self.imageSize / self.lockImage:getWidth(), self.imageSize / self.lockImage:getHeight())
	end
		
end

function AchievementSystem:Draw()
	if self.isDrawing then
		r, g, b, a = love.graphics.getColor()
		font = love.graphics.getFont()
		
		self:DrawPopup(self.xPos, 5, self.displayedName, self.displayedDescription, self.displayedImage, self.topUnlockedColor)

		if font then
			love.graphics.setFont(font)
		end
		love.graphics.setColor(r, g, b, a)
	end

	if love.keyboard.isDown(self.GUIbutton) then
		i = 0
		for k, v in ipairs(self.achievementData) do
			x = ((i) % self.maxPopupsHorizontal) * (self.popupWidth + 2) + 2
			y = math.floor(i/self.maxPopupsHorizontal) * (self.popupHeight + 2) + 2

			if v.unlocked then
				color = self.topUnlockedColor
			else
				color = self.topLockedColor
			end

			self:DrawPopup(x + self.UIOffset, y - self.scrollOffset, v.name, v.description, v.image, color, not v.unlocked)

			i = i + 1
		end
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

function AchievementSystem:DisableIntro()
	self.displayIntro = false
end

function AchievementSystem:SetBackgroundColor(red, green, blue)
	self.backgroundColor = {r=red, g=green, b=blue}
end

function AchievementSystem:SetUnlockedColor(red, green, blue)
	self.topUnlockedColor = {r=red, g=green, b=blue}
end

function AchievementSystem:SetLockedColor(red, green, blue)
	self.topLockedColor = {r=red, g=green, b=blue}
end

function AchievementSystem:SetButton(button)
	self.GUIbutton = button
end