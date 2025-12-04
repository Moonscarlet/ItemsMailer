local addonName, ns = ...

-- CONFIGURATION
local RECIPIENT_NAME = "Lays" -- Replace with the recipient's name
local WANTED_ITEMS = {
    -- Add item IDs or Names here (one per line, comma separated)
    -- "Runecloth",
    "Mooncloth",
    "Arcanite Bar",
    "Essence of Earth",
    "Essence of Water",
    -- 2589, -- Example ID
}
-- END CONFIGURATION

-- Item Parsing
local function GetWantedItems()
    local items = {}
    for _, v in ipairs(WANTED_ITEMS) do
        if type(v) == "number" then
            items[v] = true
        elseif type(v) == "string" then
            items[string.lower(v)] = true
        end
    end
    return items
end

-- Check if we have any items to send
local function HasItemsToSend()
    local wantedItems = GetWantedItems()
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local itemId = tonumber(link:match("item:(%d+)"))
                local name = GetItemInfo(itemId)
                
                if wantedItems[itemId] then return true end
                if name and wantedItems[string.lower(name)] then return true end
            end
        end
    end
    return false
end

-- Sending Logic
local function ProcessSending()
    if not RECIPIENT_NAME or RECIPIENT_NAME == "" then
        print("|cffff0000ItemsMailer:|r Recipient not configured in Lua file.")
        return
    end

    local wantedItems = GetWantedItems()
    local count = 0
    local sentItemsList = {}
    
    -- Iterate bags
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link and count < 12 then
                local itemId = tonumber(link:match("item:(%d+)"))
                local name = GetItemInfo(itemId)
                local _, _, _, _, _, _, _, _, countStack = GetContainerItemInfo(bag, slot)
                
                local match = false
                if wantedItems[itemId] then match = true end
                if name and wantedItems[string.lower(name)] then match = true end
                
                if match then
                    -- UseContainerItem puts the item into the mail attachment slot if the Send Mail tab is open
                    UseContainerItem(bag, slot)
                    count = count + 1
                    table.insert(sentItemsList, (countStack or 1) .. "x " .. (name or "Unknown"))
                end
            end
        end
    end

    if count > 0 then
        SendMail(RECIPIENT_NAME, "CDs", "")
        print("|cff00ff00ItemsMailer:|r Sent " .. count .. " stacks to " .. RECIPIENT_NAME .. ":")
        for _, itemStr in ipairs(sentItemsList) do
            print("  - " .. itemStr)
        end
        
        -- Close mail window after a short delay to ensure mail is sent
        C_Timer.After(1, function() 
            CloseMail() 
            Logout()
        end)
    else
        print("|cffff0000ItemsMailer:|r No matching items found in bags.")
    end
end

-- Event Handling
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("MAIL_SHOW")

eventHandler:SetScript("OnEvent", function(self, event, arg1)
    if event == "MAIL_SHOW" then
        if UnitName("player") == RECIPIENT_NAME then return end
        if not HasItemsToSend() then return end
        
        -- Delay to let mail frame init and switch tabs
        local timer = CreateFrame("Frame")
        timer:Hide()
        timer.elapsed = 0
        timer:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 0.5 then
                self:Hide()
                
                -- Switch to "Send Mail" tab (Tab 2)
                if MailFrameTab2 then
                    MailFrameTab2:Click()
                end
                
                -- Another delay to process items after tab switch
                local processTimer = CreateFrame("Frame")
                processTimer:Hide()
                processTimer.elapsed = 0
                processTimer:SetScript("OnUpdate", function(subSelf, subElapsed)
                    subSelf.elapsed = subSelf.elapsed + subElapsed
                    if subSelf.elapsed >= 0.2 then
                        subSelf:Hide()
                        ProcessSending()
                    end
                end)
                processTimer:Show()
            end
        end)
        timer:Show()
    end
end)
