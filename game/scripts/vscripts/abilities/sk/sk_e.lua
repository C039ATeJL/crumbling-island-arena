sk_e = class({})

function sk_e:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.SK.CastE")

    return true
end

function sk_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 700)

    local hero = self:GetCaster().hero
    local casterPos = hero:GetPos()
    local target = self:GetCursorPosition()
    local direction = self:GetDirection()
    local len = (target - casterPos):Length2D()

    local currentLen = 0
    local previousPoint = casterPos

    while (currentLen < len) do
        local point = casterPos + direction * currentLen

        if not Spells.TestPoint(point) then
            target = previousPoint
            break
        end

        previousPoint = point
        currentLen = currentLen + 32
    end

    hero:FindClearSpace(target, true)
    hero:AreaEffect({
        filter = Filters.Line(casterPos, target, 64),
        filterProjectiles = true,
        damage = true
    })

    local effect = ImmediateEffect("particles/units/heroes/hero_sandking/sandking_burrowstrike.vpcf", PATTACH_POINT, hero)
    ParticleManager:SetParticleControl(effect, 0, casterPos)
    ParticleManager:SetParticleControl(effect, 1, target)

    StartAnimation(self:GetCaster(), { duration = 1.5, activity = ACT_DOTA_SAND_KING_BURROW_OUT, translate = "sandking_rubyspire_burrowstrike"})
end

function sk_e:GetCastAnimation()
    return ACT_DOTA_SAND_KING_BURROW_IN
end