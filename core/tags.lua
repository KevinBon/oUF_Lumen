local _, ns = ...

local core, cfg, oUF = ns.core, ns.cfg, ns.oUF

-- ------------------------------------------------------------------------
-- > Custom Tags
-- ------------------------------------------------------------------------

local tags = oUF.Tags.Methods or oUF.Tags
local events = oUF.TagEvents or oUF.Tags.Events

local floor = floor

-- Name
tags['lumen:name'] = function(unit, rolf)
  return UnitName(rolf or unit)
end
events['lumen:name'] = 'UNIT_NAME_UPDATE UNIT_CONNECTION UNIT_ENTERING_VEHICLE UNIT_EXITING_VEHICLE'

-- Unit smart level
tags['lumen:level'] = function(unit)
  local l = UnitLevel(unit)
	if l <= 0 then l = "??" end
  return '|cffb9b9b9'..l..'|r'
end
events['lumen:level'] = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED'

-- Unit smart level with color
tags['lumen:levelplus'] = function(unit)
	local c = UnitClassification(unit)
	local l = UnitLevel(unit)
	local d = GetQuestDifficultyColor(l)

	if l <= 0 then l = "??" end
  return string.format("|cff%02x%02x%02x%s|r",d.r*255, d.g*255, d.b*255, l)
end
events['lumen:levelplus'] = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED'

-- Unit classification
tags['lumen:classification'] = function(unit)
	local c = UnitClassification(unit)
	if(c == 'rare') then
		return '|cff008ff7RARE|r'
	elseif(c == 'rareelite') then
		return '|cff008ff7RARE|r |cffffe453ELITE|r'
	elseif(c == 'elite') then
		return '|cffffe453ELITE|r'
	elseif(c == 'worldboss') then
		return '|cfff03a4cBOSS|r'
	elseif(c == 'minus') then
		return ''
	end
end
events['lumen:classification'] = 'UNIT_CLASSIFICATION_CHANGED'

-- Health Value
tags['lumen:hpvalue'] = function(unit)
	local min = UnitHealth(unit)
	if min == 0 or not UnitIsConnected(unit) or UnitIsGhost(unit) or UnitIsDead(unit) then
		return ''
	end
	return core:shortNumber(min)
end
events['lumen:hpvalue'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION UNIT_NAME_UPDATE'

-- Health Percent
tags['lumen:hpperc'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local percent = floor((min / max) * 100+0.5)

	if percent < 100 and percent > 0 then
		return percent .. '%'
	else
		return ''
	end
end
events['lumen:hpperc'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE'

-- Power value
tags['lumen:powervalue'] = function(unit)
	-- Hide it if DC, Ghost or Dead!
	local min, max = UnitPower(unit, UnitPowerType(unit)), UnitPowerMax(unit,  UnitPowerType(unit))
	if min == 0 or not UnitIsConnected(unit) or UnitIsGhost(unit) or UnitIsDead(unit) then
		return ''
	end

  if min == max and cfg.frames.main.power.text.hideMax then
    return ''
  end

  local _, ptype = UnitPowerType(unit)
  if ptype == 'MANA' then
		 return floor(min / max * 100)..'%'
  elseif ptype == 'RAGE' or ptype == 'RUNIC_POWER' or ptype == 'LUNAR_POWER' then
    return floor(min / 10 + 0.5)
  elseif ptype == 'INSANITY' then
		return min / 100
  else
    return min
  end
end
events['lumen:powervalue'] = 'UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_CONNECTION PLAYER_DEAD PLAYER_ALIVE'

-- Alternate Power Percent
tags['lumen:altpower'] = function(unit)
  local min, max = UnitPower(unit, 0), UnitPowerMax(unit, 0)

  if (UnitPowerType(unit) ~= 0) and min ~= max then -- If Power Type is not Mana(it's Energy or Rage) and Mana is not at Maximum
    return floor(min / max * 100)..'%'
  end
end
events['lumen:altpower'] = "UNIT_MAXPOWER UNIT_POWER_UPDATE"

-- Class Power (Combo Points, Insanity, )
tags['lumen:classpower'] = function(unit)
  local PlayerClass = core.playerClass
  local num, max, color

  if(PlayerClass == 'MONK') then
    if(GetSpecialization() == SPEC_MONK_WINDWALKER) then
			num = UnitPower('player', Enum.PowerType.Chi)
      max = UnitPowerMax('player', Enum.PowerType.Chi)
      color = '00CC99'
      if(num == max) then color = '008FF7' end
		end
    -- num = _TAGS['chi']()
  elseif(PlayerClass == 'WARLOCK') then
    num = UnitPower('player', Enum.PowerType.SoulShards)
    max = UnitPowerMax('player', Enum.PowerType.SoulShards)
    color = 'A15CFF'
    if(num == max) then color = 'FF1A30' end
  elseif(PlayerClass == 'PALADIN') then
    if(GetSpecialization() == SPEC_PALADIN_RETRIBUTION) then
			num = UnitPower('player', Enum.PowerType.HolyPower)
      max = UnitPowerMax('player', Enum.PowerType.HolyPower)
      color = 'FFFF7D'
      if(num == max) then color = 'FF1A30' end
		end
  elseif(PlayerClass == 'MAGE') then
    if(GetSpecialization() == SPEC_MAGE_ARCANE) then
			num = UnitPower('player', Enum.PowerType.ArcaneCharges)
      max = UnitPowerMax('player', Enum.PowerType.ArcaneCharges)
      color = 'A950CA'
      if(num == max) then color = 'EE3053' end
    end
  else -- Combo Points
		if(UnitHasVehicleUI('player')) then
			num = GetComboPoints('vehicle', 'target')
		else
			num = GetComboPoints('player', 'target')
      max = UnitPowerMax('player', Enum.PowerType.ComboPoints)
      color = 'FFFF66'
      if(num == max) then color = 'FF1A30' end
		end
  end

  if(num and num > 0) then
    return string.format('|cff%s%d|r', color, num)
  end
end
events['lumen:classpower'] = "UNIT_POWER_UPDATE SPELLS_CHANGED UNIT_POWER_FREQUENT PLAYER_TARGET_CHANGED"
