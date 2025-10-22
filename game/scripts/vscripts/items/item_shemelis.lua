item_shemelis = class({})

print("[SHEMELIS] ============================================")
print("[SHEMELIS] item_shemelis.lua START LOADING")
print("[SHEMELIS] ============================================")

print("[SHEMELIS] Step 1: About to call LinkLuaModifier...")
LinkLuaModifier("modifier_item_shemelis", "modifiers/items/modifier_item_shemelis", LUA_MODIFIER_MOTION_NONE)
print("[SHEMELIS] Step 2: LinkLuaModifier SUCCESS")

print("[SHEMELIS] ============================================")
print("[SHEMELIS] Defining GetIntrinsicModifierName...")
function item_shemelis:GetIntrinsicModifierName()
	print("[SHEMELIS] GetIntrinsicModifierName() CALLED - returning modifier_item_shemelis")
	return "modifier_item_shemelis"
end
print("[SHEMELIS] GetIntrinsicModifierName DEFINED")

print("[SHEMELIS] ============================================")
print("[SHEMELIS] Defining OnSpellStart...")
function item_shemelis:OnSpellStart()
	print("[SHEMELIS] OnSpellStart() CALLED - IsServer=" .. tostring(IsServer()))
	if IsServer() then
		print("[SHEMELIS] Server side confirmed")
		local caster = self:GetCaster()
		print("[SHEMELIS] Got caster: " .. tostring(caster))
		if caster then
			print("[SHEMELIS] Finding modifier...")
			local modifier = caster:FindModifierByName("modifier_item_shemelis")
			if modifier and modifier.TimeRewind then
				print("[SHEMELIS] Calling TimeRewind...")
				modifier:TimeRewind()
				print("[SHEMELIS] TimeRewind completed")
			else
				print("[SHEMELIS] ERROR: Modifier or TimeRewind not found!")
			end
			
			print("[SHEMELIS] Emitting sound Hero_Weaver.TimeLapse")
			EmitSoundOn("Hero_Weaver.TimeLapse", caster)
			print("[SHEMELIS] Sound emitted successfully")
		else
			print("[SHEMELIS] ERROR: Caster is nil!")
		end
	else
		print("[SHEMELIS] Client side - OnSpellStart not executed")
	end
end
print("[SHEMELIS] OnSpellStart DEFINED")

print("[SHEMELIS] ============================================")
print("[SHEMELIS] item_shemelis.lua LOADING COMPLETE")
print("[SHEMELIS] ============================================")
