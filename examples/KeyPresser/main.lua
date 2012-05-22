require("achievements/achievements")

function love.load()
	achievementSystem = AchievementSystem.New()
end

function love.update()
	achievementSystem:Update()
end

function love.draw()
	achievementSystem:Draw()
end

function love.keypressed(key)
	if key == " " then
		achievementSystem:UnlockAchievement("kp1")
	elseif key == "p" then
		achievementSystem:UnlockAchievement("kp2")
	elseif key == "w" then
		achievementSystem:UnlockAchievement("kp3")
   	end
end

