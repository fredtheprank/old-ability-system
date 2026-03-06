local rps = game:GetService('ReplicatedStorage')
local svrs = game:GetService('ServerStorage')
local plrs = game:GetService('Players')
local AbilityService = require(rps.Shared.AbilityService)

local dashTrail = script.DashTrail
local fxFolder = workspace.AbilityFX

local starter = {

	abilities = {
		'Blast',
		'Dash',
		'Vanish',
	},

	regenTime = 2,
	maxEnergy = 10,
}

rps.Remotes.Abilities.UseAbility.OnServerEvent:Connect(function(plr, abilityName)
	if not table.find(starter.abilities, abilityName) then
		warn(plr.Name.. ' attempted to request a forbidden or non-existent ability. Requested: "'..abilityName..'"')
		return
	end
	AbilityService:UseAbility(plr, abilityName)
end)

plrs.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		char.Parent = workspace.Characters

		rps.Remotes.Abilities.SendAllowedAbilities:FireClient(plr, starter.abilities)

		char:SetAttribute('Energy', 0)
		char:SetAttribute('MaxEnergy', starter.maxEnergy)
		char:SetAttribute('RegenTime', starter.regenTime)

		local hrp = char:FindFirstChild('HumanoidRootPart')
		local torso = char:FindFirstChild('Torso')

		AbilityService:CreateSound('swoosh', hrp, 'rbxassetid://118222822102089', 1.5, 5, 200)
		AbilityService:CreateSound('poof', hrp, 'rbxassetid://9125640008', 2, 5, 200)
		AbilityService:CreateSound('blast', hrp, 'rbxassetid://110249090036043', 2, 5, 200)

		local newdash = dashTrail:Clone()
		newdash.Name = newdash.Name..'_'..plr.Name
		newdash.Attachment0 = torso.NeckAttachment
		newdash.Attachment1 = torso.WaistCenterAttachment
		newdash.Parent = fxFolder

		task.spawn(function()
			while task.wait(0.5) and char do
				local currentEnergy = char:GetAttribute('Energy')
				local maxEnergy = char:GetAttribute('MaxEnergy')
				if currentEnergy >= maxEnergy then 
					char:SetAttribute('Energy', maxEnergy)
					continue 
				end
				char:SetAttribute('Energy', char:GetAttribute('Energy') + .5/char:GetAttribute('RegenTime'))
			end
		end)
	end)
	plr.CharacterRemoving:Connect(function(char)
		local trail = fxFolder:FindFirstChild('DashTrail_'..plr.Name)
		trail:Destroy()
	end)
end)
