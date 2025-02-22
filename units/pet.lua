local A, ns = ...

local lum, core, auras, oUF = ns.lum, ns.core, ns.auras, ns.oUF
local cfg, m, filters = ns.cfg, ns.m, ns.filters

local font = m.fonts.font
local font_big = m.fonts.font_big

local frame = "pet"

-- ------------------------------------------------------------------------
-- > PET UNIT SPECIFIC FUNCTiONS
-- ------------------------------------------------------------------------

-- Post Health Update
local PostUpdateHealth = function(health, unit, min, max)
  local self = health.__owner
  
  if cfg.units[frame].health.gradientColored then
    local r, g, b = oUF.ColorGradient(min, max, 1,0,0, 1,1,0, 0/255,204/255,180/255) -- Red, Yellow, Full Health Color
    health:SetStatusBarColor(r, g, b)
  end

  -- Class colored text
  if cfg.units[frame].health.classColoredText then
    self.Name:SetTextColor(unpack(core:raidColor(unit)))
  end
end

-- Post Update Aura Icon
local PostUpdateIcon =  function(icons, unit, icon, index, offset, filter, isDebuff)
  local name, _, count, dtype, duration, expirationTime = UnitAura(unit, index, icon.filter)

	if duration and duration > 0 then
		icon.timeLeft = expirationTime - GetTime()

	else
		icon.timeLeft = math.huge
	end

	icon:SetScript('OnUpdate', function(self, elapsed)
		auras:AuraTimer_OnUpdate(self, elapsed)
	end)
end

-- Filter Buffs
local PetBuffsFilter = function(icons, unit, icon, name)
  if(filters.list.PET[name]) then
    return true
  end
end

-- -----------------------------------
-- > TARGET STYLE
-- -----------------------------------

local createStyle = function(self)
  self.mystyle = frame
  self.cfg = cfg.units[frame]

  lum:globalStyle(self, "secondary")

  -- Texts
  core:createNameString(self, font_big, cfg.fontsize, "THINOUTLINE", 2, 0, "LEFT", self.cfg.width - 8)
  self:Tag(self.Name, '[lumen:name]')
  -- core:createHPString(self, font, cfg.fontsize - 4, "THINOUTLINE", -4, 0, "RIGHT")
  -- self:Tag(self.Health.value, '[lumen:hpperc]')

  -- Health & Power Updates
  self.Health.PostUpdate = PostUpdateHealth

  -- Buffs
  local buffs = auras:CreateAura(self, 4, 1, cfg.frames.secondary.height + 4, 2)
  buffs:SetPoint("BOTTOMRIGHT", "oUF_LumenPlayer", "TOPLEFT", -6, 6)
  buffs.initialAnchor = "BOTTOMRIGHT"
  buffs["growth-x"] = "LEFT"
  buffs.PostUpdateIcon = PostUpdateIcon
  if(self.cfg.buffs.filter) then buffs.CustomFilter = PetBuffsFilter end
  self.Buffs = buffs

  -- Heal Prediction
  CreateHealPrediction(self)

end

-- -----------------------------------
-- > SPAWN UNIT
-- -----------------------------------
if cfg.units[frame].show then
  oUF:RegisterStyle(A..frame:gsub("^%l", string.upper), createStyle)
  oUF:SetActiveStyle(A..frame:gsub("^%l", string.upper))
  oUF:Spawn(frame, A..frame:gsub("^%l", string.upper))
end
