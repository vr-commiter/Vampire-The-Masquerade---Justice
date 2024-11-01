local truegear = require "truegear"

local hookIds = {}
local isFirst = true
local resetHook = true
local isPause = false
local isDeath = false
local isDrinkBlood = false
local bloodLineTime = 0
local punchTime = 0
local PlayerHungerValue = 0
local playerHealth = 100

function SendMessage(context)
	if isDeath == true then
		return
	end
	if context then
		print(context .. "\n")
		return
	end
	print("nil\n")
end

function PlayAngle(event,tmpAngle,tmpVertical)

	local rootObject = truegear.find_effect(event);

	local angle = (tmpAngle - 22.5 > 0) and (tmpAngle - 22.5) or (360 - tmpAngle)
	
    local horCount = math.floor(angle / 45) + 1
	local verCount = (tmpVertical > 0.1) and -4 or (tmpVertical < 0 and 8 or 0)


	for kk, track in pairs(rootObject.tracks) do
        if tostring(track.action_type) == "Shake" then
            for i = 1, #track.index do
                if verCount ~= 0 then
                    track.index[i] = track.index[i] + verCount
                end
                if horCount < 8 then
                    if track.index[i] < 50 then
                        local remainder = track.index[i] % 4
                        if horCount <= remainder then
                            track.index[i] = track.index[i] - horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] - remainder + 99 + num1
                        else
                            track.index[i] = track.index[i] + 2
                        end
                    else
                        local remainder = 3 - (track.index[i] % 4)
                        if horCount <= remainder then
                            track.index[i] = track.index[i] + horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] + remainder - 99 - num1
                        else
                            track.index[i] = track.index[i] - 2
                        end
                    end
                end
            end
            if track.index then
                local filteredIndex = {}
                for _, v in pairs(track.index) do
                    if not (v < 0 or (v > 19 and v < 100) or v > 119) then
                        table.insert(filteredIndex, v)
                    end
                end
                track.index = filteredIndex
            end
        elseif tostring(track.action_type) ==  "Electrical" then
            for i = 1, track.index.Length() do
                if horCount <= 4 then
                    track.index[i] = 0
                else
                    track.index[i] = 100
                end
            end
            if horCount == 1 or horCount == 8 or horCount == 4 or horCount == 5 then
                track.index = {0, 100}
            end
        end
    end

	truegear.play_effect_by_content(rootObject)
end


function RegisterHooks()

	if isFirst == true then
		isFirst = false
	end

	for k,v in pairs(hookIds) do
		UnregisterHook(k, v.id1, v.id2)
	end
		
	hookIds = {}

	local funcName = "/Script/Lollipop.LollipopCharacter:IsDead"
	local hook1, hook2 = RegisterHook(funcName, OnDeath)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/_Lollipop/Game/BP_LollipopGameInstance.BP_LollipopGameInstance_C:RespawnPlayer"
	local hook1, hook2 = RegisterHook(funcName, ResetHealth)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/_Snowball/Player/BP_SnowballCharacter.BP_SnowballCharacter_C:OnPunchHit"
	local hook1, hook2 = RegisterHook(funcName, OnPunchHit)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Snowball/Player/BP_SnowballCharacter.BP_SnowballCharacter_C:OnBloodDrinkingActive"
	local hook1, hook2 = RegisterHook(funcName, OnBloodDrinking)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Script/PlayerFoundation.VRCharacter:ClosePauseMenu"
	local hook1, hook2 = RegisterHook(funcName, ClosePauseMenu111)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/PlayerFoundation.VRCharacter:OpenPauseMenu"
	local hook1, hook2 = RegisterHook(funcName, OpenPauseMenu111)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/_Snowball/Player/BP_SnowballCharacter.BP_SnowballCharacter_C:StartOpenPauseMenu"
	local hook1, hook2 = RegisterHook(funcName, StartPause)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Snowball/Player/BP_SnowballCharacter.BP_SnowballCharacter_C:StartClosePauseMenu"
	local hook1, hook2 = RegisterHook(funcName, CancelPause)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Lollipop/UI/Menu/BP_PauseMenu.BP_PauseMenu_C:OnQuitToMainMenuPressed"
	local hook1, hook2 = RegisterHook(funcName, IsMainMenuOpen)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Lollipop/UI/Menu/BP_PauseMenu.BP_PauseMenu_C:OnRestartCheckpointPressed"
	local hook1, hook2 = RegisterHook(funcName, RestartCheckpoint)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Lollipop/Core/Effects/BP_DashEffectsHandlerComponent.BP_DashEffectsHandlerComponent_C:OnArrivedHaptics"
	local hook1, hook2 = RegisterHook(funcName, OnArrivedHaptics)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
		
	local funcName = "/Game/_Lollipop/Core/Effects/BP_CloakOfShadowsEffectsHandler.BP_CloakOfShadowsEffectsHandler_C:OnCloakOfShadowsActivate"
	local hook1, hook2 = RegisterHook(funcName, OnCloakOfShadowsActivate)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Lollipop/Core/Effects/BP_CloakOfShadowsEffectsHandler.BP_CloakOfShadowsEffectsHandler_C:OnCloakOfShadowsDeactivate"
	local hook1, hook2 = RegisterHook(funcName, OnCloakOfShadowsDeactivate)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Lollipop/Core/Effects/BP_PlayerHungerEffectsHandler.BP_PlayerHungerEffectsHandler_C:HasHungerChanged"
	local hook1, hook2 = RegisterHook(funcName, HasHungerChanged)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Snowball/Player/BP_SnowballCharacter.BP_SnowballCharacter_C:BP_OnHandBeginInteraction"
	local hook1, hook2 = RegisterHook(funcName, BP_OnHandBeginInteraction)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/_Lollipop/Core/Inventory/New/BP_PlayerInventoryItemRecieverComponent.BP_PlayerInventoryItemRecieverComponent_C:OnAttachTimelineFinished"
	local hook1, hook2 = RegisterHook(funcName, OnAttachTimelineFinished)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Lollipop.InventoryItemGiver:OnItemInteractionStart"
	local hook1, hook2 = RegisterHook(funcName, InventoryItemGiverOnItemInteractionStart)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
		
	local funcName = "/Game/_Lollipop/Core/Effects/BP_ShadowWardEffectHandler.BP_ShadowWardEffectHandler_C:PlaceShadowWard"
	local hook1, hook2 = RegisterHook(funcName, PlaceShadowWard)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/_Lollipop/Core/Effects/BP_CauldronOfBloodEffectsHandler.BP_CauldronOfBloodEffectsHandler_C:BP_OnAimUpdated"
	local hook1, hook2 = RegisterHook(funcName, BP_OnAimUpdated)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/_Lollipop/Core/Character/Player/Gear/Crossbow/BP_CrossbowBolt.BP_CrossbowBolt_C:BP_OnBoltShot"
	local hook1, hook2 = RegisterHook(funcName, BP_OnBoltShot)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Lollipop/Core/Effects/BP_CrossbowEffectsHandlerComponent.BP_CrossbowEffectsHandlerComponent_C:OnCrossbowReloaded"
	local hook1, hook2 = RegisterHook(funcName, OnCrossbowReloaded)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/_Lollipop/Core/Effects/BP_CrossbowEffectsHandlerComponent.BP_CrossbowEffectsHandlerComponent_C:OnCrossbowStartReload"
	local hook1, hook2 = RegisterHook(funcName, OnCrossbowStartReload)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Snowball/Player/BP_SnowballCharacter.BP_SnowballCharacter_C:OnForceGrabBeginBPImpl"
	local hook1, hook2 = RegisterHook(funcName, OnForceGrabBeginBPImpl)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Lollipop/Core/Effects/BP_CrossbowEffectsHandlerComponent.BP_CrossbowEffectsHandlerComponent_C:OnPlayerStartGrabbingBoltSelection"
	local hook1, hook2 = RegisterHook(funcName, OnPlayerStartGrabbingBoltSelection)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/_Lollipop/Core/Effects/BP_CrossbowEffectsHandlerComponent.BP_CrossbowEffectsHandlerComponent_C:EquippedBoltLerpUpdate"
	local hook1, hook2 = RegisterHook(funcName, EquippedBoltLerpUpdate)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	-- local funcName = "/Game/_Lollipop/Core/Effects/BP_CrossbowEffectsHandlerComponent.BP_CrossbowEffectsHandlerComponent_C:EquippedBoltLerpFinished"
	-- local hook1, hook2 = RegisterHook(funcName, EquippedBoltLerpFinished)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	-- local funcName = "/Game/_Lollipop/Core/Effects/BP_DisciplineSelectionEffectsHandler.BP_DisciplineSelectionEffectsHandler_C:OnSelectionChange"
	-- local hook1, hook2 = RegisterHook(funcName, OnSelectionChange)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }




	
end

-- *******************************************************************

function EquippedBoltLerpUpdate(self,Value)
	if Value:get() == 0 then
		SendMessage("--------------------------------")
		SendMessage("RightHandEquipArrow")
		truegear.play_effect_by_uuid("RightHandEquipArrow")
		SendMessage(tostring(Value:get()))
	end

end

function OnSelectionChange(self)
	SendMessage("--------------------------------")
	SendMessage("OnSelectionChange")
	truegear.play_effect_by_uuid("LeftHandPickupItem")
end



function EquippedBoltLerpFinished(self)
	SendMessage("--------------------------------")
	SendMessage("RightHandEquipArrow")
	truegear.play_effect_by_uuid("RightHandEquipArrow")
end

function OnPlayerStartGrabbingBoltSelection(self)
	SendMessage("--------------------------------")
	SendMessage("LeftHandPickupItem")
	truegear.play_effect_by_uuid("LeftHandPickupItem")
end

function OnCrossbowReloaded(self)
	SendMessage("--------------------------------")
	SendMessage("RightHandCrossbowReloaded")
	truegear.play_effect_by_uuid("RightHandCrossbowReloaded")
end

function OnCrossbowStartReload(self)
	SendMessage("--------------------------------")
	SendMessage("LeftHandPickupItem")
	truegear.play_effect_by_uuid("LeftHandPickupItem")
end

function OnDeath(self)
	local isPlayerDeath = self:get():GetPropertyValue("bPlayerDead")
	if isDeath then
		return
	end
	if isPlayerDeath then
		SendMessage("--------------------------------")
		SendMessage("PlayerDeath")
		truegear.play_effect_by_uuid("PlayerDeath")
		PlayerHungerValue = 0
		isDeath = true
	elseif playerHealth > self:get():GetCurrentHealth() then
		SendMessage("--------------------------------")
		SendMessage("PoisonDamage")
		truegear.play_effect_by_uuid("PoisonDamage")
	end
	playerHealth = self:get():GetCurrentHealth()
	-- SendMessage(self:get():GetFullName())
	-- SendMessage(tostring(self:get():GetPropertyValue("bPlayerDead")))
	-- SendMessage(tostring(self:get():GetCurrentHealth()))
	-- SendMessage(tostring(self:get():GetCurrentHealthNormalized()))
end

function ResetHealth(self)
	isDeath = false
	playerHealth = self:get():GetPropertyValue("PendingPlayerHealth")
	SendMessage("--------------------------------")
	SendMessage("LevelStarted")
	truegear.play_effect_by_uuid("LevelStarted")
	SendMessage(tostring(self:get():GetPropertyValue("PendingPlayerHealth")))
	
end


function OnPunchHit(self,hand)
	if os.clock() - punchTime < 0.110 then
		return
	end
	punchTime = os.clock()
	if hand:get() == 0 then
		SendMessage("--------------------------------")
		SendMessage("LeftHandPunchHit")
		truegear.play_effect_by_uuid("LeftHandPunchHit")
	else
		SendMessage("--------------------------------")
		SendMessage("RightHandPunchHit")
		truegear.play_effect_by_uuid("RightHandPunchHit")
	end

	SendMessage(self:get():GetFullName())
	SendMessage(tostring(hand:get()))
end



function OnBloodDrinking(self,Active)
	-- SendMessage("--------------------------------")
	-- SendMessage("OnBloodDrinking")
	-- SendMessage(self:get():GetFullName())
	-- SendMessage(tostring(Active:get()))
	isDrinkBlood = Active:get()
end

function ClosePauseMenu111(self)
	SendMessage("--------------------------------")
	SendMessage("ClosePauseMenu111")
	isPause = false
end

function OpenPauseMenu111(self)
	SendMessage("--------------------------------")
	SendMessage("OpenPauseMenu111")
	isPause = true
end

function CancelPause(self)
	isPause = false
	SendMessage("--------------------------------")
	SendMessage("CancelPause")
	-- SendMessage(self:get():GetFullName())
end

function StartPause(self)
	isPause = true
	SendMessage("--------------------------------")
	SendMessage("StartPause")
	-- SendMessage(self:get():GetFullName())
end

function IsMainMenuOpen(self)
	SendMessage("--------------------------------")
	SendMessage("IsMainMenuOpen")
	isPause = false
	PlayerHungerValue = 0
end

function RestartCheckpoint(self)
	SendMessage("--------------------------------")
	SendMessage("RestartCheckpoint")
	-- SendMessage(self:get():GetFullName())
	isPause = false
	PlayerHungerValue = 0
end

function OnArrivedHaptics(self,BlinkAttack)
	if BlinkAttack:get() then
		SendMessage("--------------------------------")
		SendMessage("BlinkAttack")
		truegear.play_effect_by_uuid("BlinkAttack")
		return
	end
	SendMessage("--------------------------------")
	SendMessage("Flash")
	truegear.play_effect_by_uuid("Flash")
	-- SendMessage(tostring(BlinkAttack:get()))
end


function OnCloakOfShadowsDeactivate(self)
	SendMessage("--------------------------------")
	SendMessage("CloakOfShadowsStop")
	truegear.play_effect_by_uuid("CloakOfShadowsStop")
end

function OnCloakOfShadowsActivate(self)
	SendMessage("--------------------------------")
	SendMessage("CloakOfShadowsStart")
	truegear.play_effect_by_uuid("CloakOfShadowsStart")
end

function HasHungerChanged(self,NewHunger,HasChanged)
	SendMessage("--------------------------------")
	SendMessage("HasHungerChanged")
	SendMessage(tostring(NewHunger:get()))
	-- SendMessage(tostring(HasChanged:get()))
	PlayerHungerValue = NewHunger:get()
end

function BP_OnHandBeginInteraction(self,hand)
	if hand:get() == 0 then
		SendMessage("--------------------------------")
		SendMessage("LeftHandPickupItem")
		truegear.play_effect_by_uuid("LeftHandPickupItem")
	else
		SendMessage("--------------------------------")
		SendMessage("RightHandPickupItem")
		truegear.play_effect_by_uuid("RightHandPickupItem")
	end
	SendMessage(tostring(hand:get()))
end

function OnAttachTimelineFinished(self)
	SendMessage("--------------------------------")
	SendMessage("InventoryAddItem")
	truegear.play_effect_by_uuid("InventoryAddItem")
end

function InventoryItemGiverOnItemInteractionStart(self)
	SendMessage("--------------------------------")
	SendMessage("InventoryRemoveItem")
	truegear.play_effect_by_uuid("InventoryRemoveItem")
	SendMessage(self:get():GetFullName())
end

function PlaceShadowWard(self)
	SendMessage("--------------------------------")
	SendMessage("RightHandPlaceShadowWard")
	truegear.play_effect_by_uuid("RightHandPlaceShadowWard")
	SendMessage(self:get():GetFullName())
end

function BP_OnAimUpdated(self,AimFrom,AimTo,CauldronOfBloodState)
	if os.clock() - bloodLineTime < 0.250 then
		return
	end
	bloodLineTime = os.clock()
	SendMessage("--------------------------------")
	SendMessage("RightHandCauldronOfBlood")
	truegear.play_effect_by_uuid("RightHandCauldronOfBlood")
	SendMessage(self:get():GetFullName())
	SendMessage(tostring(CauldronOfBloodState:get()))
end

function BP_OnBoltShot(self)
	SendMessage("--------------------------------")
	SendMessage("RightHandCrossBowShoot")
	truegear.play_effect_by_uuid("RightHandCrossBowShoot")
	SendMessage(self:get():GetFullName())
end


function OnForceGrabBeginBPImpl(self,HandType)
	if HandType:get() == 0 then
		SendMessage("--------------------------------")
		SendMessage("LeftHandPullItem")
		truegear.play_effect_by_uuid("LeftHandPullItem")
	else
		SendMessage("--------------------------------")
		SendMessage("RightHandPullItem")
		truegear.play_effect_by_uuid("RightHandPullItem")
	end

	SendMessage(self:get():GetFullName())
	SendMessage(tostring(HandType:get()))
end


truegear.init("2431700", "Vampire:The Masquerade-Justice")
function CheckPlayerSpawned()
	RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
		if resetHook then
			local ran, errorMsg = pcall(RegisterHooks)
			if ran then
				SendMessage("--------------------------------")
				SendMessage("HeartBeat")
				truegear.play_effect_by_uuid("HeartBeat")
				resetHook = false
			else
				print(errorMsg)
			end
		end		
	end)
end

-- function CheckPlayerSpawned()
-- 	RegisterHooks()
-- end

SendMessage("TrueGear Mod is Loaded");
CheckPlayerSpawned()


function HeartBeat()
	if isPause then
		return
	end
	if PlayerHungerValue > 90 then
		SendMessage("--------------------------------")
		SendMessage("HeartBeat")
		truegear.play_effect_by_uuid("HeartBeat")
	end
end

function BloodDrink()
	if isPause then
		return
	end
	if isDrinkBlood then
		SendMessage("--------------------------------")
		SendMessage("BloodDrink")
		truegear.play_effect_by_uuid("BloodDrink")
	end
	
end

LoopAsync(500, BloodDrink)
LoopAsync(1000, HeartBeat)