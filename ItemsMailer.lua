local addonName, ns = ...

-- CONFIGURATION
local RECIPIENT_NAME = "Lays"
local WANTED_ITEMS = {
    "Mooncloth",
    "Arcanite Bar",
    "Essence of Earth",
    "Essence of Water",
}
-- END CONFIGURATION

-- Item Parsing
local cachedWantedItems = nil
local function GetWantedItems()
    if cachedWantedItems then return cachedWantedItems end
    cachedWantedItems = {}
    for _, v in ipairs(WANTED_ITEMS) do
        if type(v) == "number" then cachedWantedItems[v] = true
        elseif type(v) == "string" then cachedWantedItems[string.lower(v)] = true end
    end
    return cachedWantedItems
end

local function IsWantedItem(link)
    if not link then return false end
    local itemId = tonumber(link:match("item:(%d+)"))
    if not itemId then return false end
    local wantedItems = GetWantedItems()
    if wantedItems[itemId] then return true end
    local name = GetItemInfo(itemId)
    if name and wantedItems[string.lower(name)] then return true end
    return false
end

-- ==========================================
-- AUTOMATED BANK PROCESSING
-- ==========================================
local movedItemsList = {}

local function RunBankLogic()
    local isRecipient = (UnitName("player") == RECIPIENT_NAME)
    local movedThisStep = false

    if isRecipient then
        -- WITHDRAW: Bank > Bags
        for t = 1, GetNumGuildBankTabs() do
            for sl = 1, 98 do
                local link = GetGuildBankItemLink(t, sl)
                if link and IsWantedItem(link) then
                    local _, count = GetGuildBankItemInfo(t, sl)
                    local name = GetItemInfo(link)
                    for b = 0, 4 do
                        for s = 1, GetContainerNumSlots(b) do
                            if not GetContainerItemLink(b, s) then
                                PickupGuildBankItem(t, sl)
                                PickupContainerItem(b, s)
                                table.insert(movedItemsList, (count or 1) .. "x " .. (name or "Item"))
                                movedThisStep = true
                                break
                            end
                        end
                        if movedThisStep then break end
                    end
                end
                if movedThisStep then break end
            end
            if movedThisStep then break end
        end
    else
        -- DEPOSIT: Bags > Bank
        for b = 0, 4 do
            for s = 1, GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b, s)
                if link and IsWantedItem(link) then
                    local _, count = GetContainerItemInfo(b, s)
                    local name = GetItemInfo(link)
                    for t = 1, GetNumGuildBankTabs() do
                        for sl = 1, 98 do
                            if not GetGuildBankItemInfo(t, sl) then
                                PickupContainerItem(b, s)
                                PickupGuildBankItem(t, sl)
                                table.insert(movedItemsList, (count or 1) .. "x " .. (name or "Item"))
                                movedThisStep = true
                                break
                            end
                        end
                        if movedThisStep then break end
                    end
                end
                if movedThisStep then break end
            end
            if movedThisStep then break end
        end
    end

    if movedThisStep then
        C_Timer.After(0.2, RunBankLogic)
    else
        if #movedItemsList > 0 then
            local action = isRecipient and "Withdrew" or "Deposited"
            print("|cff00ff00ItemsMailer:|r " .. action .. " " .. #movedItemsList .. " items:")
            for _, itemStr in ipairs(movedItemsList) do
                print("  - " .. itemStr)
            end
            movedItemsList = {} -- Reset list
        end
    end
    C_Timer.After(0.5, function() 
        Logout()
        -- DEFAULT_CHAT_FRAME.editBox:SetText("/pct prepare") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
    end)    
end

-- ==========================================
-- EVENT HANDLING
-- ==========================================
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("MAIL_SHOW")
eventHandler:RegisterEvent("GUILDBANKFRAME_OPENED")

eventHandler:SetScript("OnEvent", function(self, event)
    if event == "MAIL_SHOW" then
        if UnitName("player") == RECIPIENT_NAME then return end
        
        local hasItems = false
        for b=0,4 do for s=1,GetContainerNumSlots(b) do if IsWantedItem(GetContainerItemLink(b,s)) then hasItems = true break end end end
        
        if hasItems then
            C_Timer.After(0.5, function()
                if MailFrameTab2 then MailFrameTab2:Click() end
                C_Timer.After(0.2, function()
                    local sentItemsList = {}
                    local count = 0
                    for b=0,4 do for s=1,GetContainerNumSlots(b) do
                        if IsWantedItem(GetContainerItemLink(b,s)) and count < 12 then
                            local name = GetItemInfo(GetContainerItemLink(b,s))
                            local _, countStack = GetContainerItemInfo(b,s)
                            UseContainerItem(b,s)
                            count = count + 1
                            table.insert(sentItemsList, (countStack or 1) .. "x " .. (name or "Unknown"))
                        end
                    end end
                    if count > 0 then
                        SendMail(RECIPIENT_NAME, "CDs", "")
                        print("|cff00ff00ItemsMailer:|r Sent " .. count .. " stacks to " .. RECIPIENT_NAME .. ":")
                        for _, itemStr in ipairs(sentItemsList) do print("  - " .. itemStr) end
                        C_Timer.After(1, function() 
                            Logout()
                            DEFAULT_CHAT_FRAME.editBox:SetText("/pct prepare") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
                        end)
                    end
                end)
            end)
        end

    elseif event == "GUILDBANKFRAME_OPENED" then
        movedItemsList = {}
        C_Timer.After(0.5, RunBankLogic)
    end
end)