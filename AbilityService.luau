local AbilityService = {}
AbilityService.__index = AbilityService

local kids = script.Abilities

function AbilityService:UseAbility(plr: Player, AbilityName: string)
	
	local inst = kids:FindFirstChild(AbilityName)
	if inst == nil or not inst:IsA('ModuleScript') then
		warn("Couldn't find ability named: ".. AbilityName)
		return
	end
	
	local ability = require(inst)
	local char = plr.Character or plr.CharacterAdded:Wait()
	
	local abilityCost = inst:GetAttribute('AbilityCost')
	local charEnergy = char:GetAttribute('Energy')
	
	if char:GetAttribute(AbilityName..'CD') then
		warn(plr.Name.. ' is on cooldown for ability: '.. AbilityName)
		return 
	elseif charEnergy < abilityCost then
		warn(plr.Name.. ' has insufficient energy for ability: '.. AbilityName)
		return
	end	
	
	char:SetAttribute('Energy', charEnergy - abilityCost)
	ability:Activate(plr)
	char:SetAttribute(AbilityName..'CD', true)
	
	task.delay(inst:GetAttribute('AbilityCD'), function() char:SetAttribute(AbilityName.. 'CD', false) end)
end

function AbilityService:CreateSound(name: string, part: BasePart, id: string, vol: number, min: number, max: number)
	if not part or not id or not name then
		return warn("Didn't provide a basepart or soundId or name for the sound.")
	end
	
	local newsound = Instance.new('Sound')
	newsound.Name = name
	newsound.Parent = part
	newsound.SoundId = id
	newsound.Volume = vol or 1
	newsound.RollOffMinDistance = min or 10
	newsound.RollOffMaxDistance = max or 100
	
	return newsound
end

return AbilityService
