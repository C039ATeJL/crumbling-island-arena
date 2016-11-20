sven_w = class({})

LinkLuaModifier("modifier_sven_w_slow", "abilities/sven/modifier_sven_w_slow", LUA_MODIFIER_MOTION_NONE)

function sven_w:GetBehavior()
    local enraged = self:GetCaster():HasModifier("modifier_sven_r") -- Can't use IsEnraged on the client

    if enraged then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end

    return DOTA_ABILITY_BEHAVIOR_POINT
end

function sven_w:Shout(direction)
    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local target = hero:GetPos() + direction * 500

    local effect = ImmediateEffect("particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf", PATTACH_CUSTOMORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos())
    ParticleManager:SetParticleControl(effect, 1, target)
    ParticleManager:SetParticleControlForward(effect, 0, direction)

    hero:AreaEffect({
        filter = Filters.Cone(pos, 500, direction, math.pi / 2),
        modifier = { name = "modifier_sven_w_slow", duration = 2, ability = self },
        action = function(victim)
            SoftKnockback(victim, hero, victim:GetPos() - pos, 40, { decrease = 4 })
        end
    })
end

function sven_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 500)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = self:GetDirection()
    local ability = self

    if not SvenUtil.IsEnraged(hero) then
        self:Shout(direction:Normalized())
    else
        for i = 0, 8 do
            local an = math.pi / 4 * i
            self:Shout(Vector(math.cos(an), math.sin(an)))
        end
    end

    ScreenShake(hero:GetPos(), 5, 150, 0.45, 2000, 0, true)

    hero:EmitSound("Arena.Sven.CastW")
end

function sven_w:GetCastAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_2
end