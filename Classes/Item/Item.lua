local DMW = DMW
local Item = DMW.Classes.Item

function Item:New(ItemID)
    self.ItemID = ItemID
    self.ItemName = GetItemInfo(ItemID)
    self.SpellName, self.SpellID = GetItemSpell(ItemID)
    self.Cache = {}
    self.lastCast = nil
end

function Item:Equipped()
    for _, ID in pairs(DMW.Player.Equipment) do
        if ID == self.ItemID then
            return true
        end
    end
    return false
end

function Item:CD()
    if DMW.Pulses == self.Cache.CDUpdate then
        return self.Cache.CD
    end
    self.Cache.CDUpdate = DMW.Pulses
    local Start, Duration, Enable = GetItemCooldown(self.ItemID)
    if Enable == 0 then
        return 99
    end
    local CD = Start + Duration - DMW.Time
    self.Cache.CD = CD > 0 and CD or 0
    return self.Cache.CD
end

function Item:IsReady()
    --healthstone cd
    if self.ItemID == 5512 and self.lastCast ~= nil and DMW.Time - self.lastCast <= 61 then
        return false
    end
    return IsUsableItem(self.ItemID) and self:CD() == 0
end

function Item:Use(Unit)
    Unit = Unit or DMW.Player
    if self.SpellID and self:IsReady() then
        UseItemByName(self.ItemName, Unit.Pointer)
        self.lastCast = DMW.Time
        return true
    end
    return false
end