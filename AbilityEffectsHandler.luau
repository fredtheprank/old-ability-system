local module = {}
if game:GetService('RunService'):IsServer() then return {} end

-- utils --
local uis = game:GetService('UserInputService')
local rps = game:GetService('ReplicatedStorage')
local twns = game:GetService('TweenService')

local PartCacheModule = require(rps.Shared.PartCache)

local plr = game:GetService('Players').LocalPlayer

local cam = workspace.CurrentCamera
local abilityFX = workspace.AbilityFX

local remotes = rps.Remotes.Abilities

local gui = plr.PlayerGui:WaitForChild('AbilityGui')

type HighlightProperties = {
	Parent: Instance?,
	Enabled: boolean?,
	FillColor: Color3?,
	FIllTransparency: number?,
	OutlineColor: Color3?,
	OutlineTransparency: number?,
}

--- helpers ---
function createHighlight(properties: HighlightProperties): Highlight
	if not properties then properties = {} end
	
	local highlight = Instance.new('Highlight')
	highlight.Parent = properties.Parent or plr.Character or plr.CharacterAdded:Wait()
	highlight.Enabled = properties.Enabled or false
	highlight.FillColor = properties.FillColor or Color3.new(0.4,0.4,0.4)
	highlight.FillTransparency = properties.FillTransparency or 1
	highlight.OutlineColor = properties.OutlineColor or Color3.new(0,0,0)
	highlight.OutlineTransparency = properties.OutlineTransparency or 1
	
	return highlight
end

----------

local initialized = false

function module:Init()
	if initialized then return end
	initialized = true
	
	plr.CharacterAdded:Connect(function(char)
	
	end)

	uis.InputBegan:Connect(function(input, gpe)
		if gpe then return end

		if input.KeyCode == Enum.KeyCode.R then
			remotes.UseAbility:FireServer('Dash')
		elseif input.KeyCode == Enum.KeyCode.T then
			remotes.UseAbility:FireServer('Vanish')
		elseif input.KeyCode == Enum.KeyCode.F then
			remotes.UseAbility:FireServer('Blast')
		end
	end)

	gui.MobileControls.F.TouchTap:Connect(function()
		remotes.UseAbility:FireServer('Blast')
	end)

	gui.MobileControls.R.TouchTap:Connect(function()
		remotes.UseAbility:FireServer('Dash')
	end)

	gui.MobileControls.T.TouchTap:Connect(function()
		remotes.UseAbility:FireServer('Vanish')
	end)

	remotes.GetCamInfo.OnClientInvoke = function()
		return cam.CFrame
	end

	remotes.Effects.OutlineChar.OnClientEvent:Connect(function(tbl, duration)
		local highlight = plr.Character:FindFirstChildWhichIsA('Highlight') or createHighlight()

		if tbl.Enabled then

			highlight.Enabled = true

			local tween = twns:Create(highlight, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
				FillColor = Color3.new(tbl.FillColor.R, tbl.FillColor.G, tbl.FillColor.B),
				FillTransparency = tbl.FillTransparency,
				OutlineColor = Color3.new(tbl.OutlineColor.R, tbl.OutlineColor.G, tbl.OutlineColor.B),
				OutlineTransparency = tbl.OutlineTransparency,
			})

			tween:Play()
		else

			local tween2 = twns:Create(highlight, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
				FillColor = Color3.new(0.4, 0.4, 0.4),
				FillTransparency = 1,
				OutlineColor = Color3.new(0, 0, 0),
				OutlineTransparency = 1,
			})

			tween2:Play()
			tween2.Completed:Wait()

			highlight.Enabled = false
		end
	end)

	remotes.Effects.ShowDashTrail.OnClientEvent:Connect(function(plrName: string, duration: number)
		local trail = abilityFX:FindFirstChild('DashTrail_'..plrName)
		if trail then
			trail.Enabled = true
			task.delay(duration, function()
				trail.Enabled = false
			end)
		else
			warn("Couldn't find dash trail for player: ".. plrName)
		end
	end)

	local Projectile = rps.SharedStorage.Ability.FxStorage.blastPart
	local cachedProjectiles = PartCacheModule.new(Projectile, 10, workspace.Projectiles)

	remotes.Effects.ShowBlast.OnClientEvent:Connect(function(cf, distance, speed)
		local newProjectile = cachedProjectiles:GetPart()
		newProjectile.Parent = workspace.Projectiles
		newProjectile.CFrame = cf
		newProjectile.Trail.Enabled = true

		local tween = twns:Create(newProjectile, TweenInfo.new(distance/speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
			CFrame = newProjectile.CFrame * CFrame.new(0, 0, -distance),
		})
		local tween2 = twns:Create(newProjectile.cosmetic, TweenInfo.new(distance/speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
			Transparency = 1
		})
		tween:Play()
		tween2:Play()

		tween.Completed:Wait()
		newProjectile.Trail.Enabled = false
		newProjectile.cosmetic.Transparency = 0
		cachedProjectiles:ReturnPart(newProjectile)
	end)
end

return module
