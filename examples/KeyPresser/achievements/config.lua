function AchievementSystemConfig(achievementSystem)

	achievementSystem:CreateAchievement("kp1", "Key Hero", "Press Space", "example1.jpg")
	achievementSystem:CreateAchievement("kp2", "P Presser", "Press P", "example2.jpg")
	achievementSystem:CreateAchievement("kp3", "WASD Beginner", "Press W", "example2.jpg")

	achievementSystem:DisableIntro()
	--achievementSystem:SetBackgroundColor(0, 0, 0)
	--achievementSystem:SetUnlockedColor(255, 255, 0)
	--achievementSystem:SetLockedColor(0, 0, 0)

end