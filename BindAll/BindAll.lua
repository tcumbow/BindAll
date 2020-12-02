BA = BA or {}
BA.name = "BindAll"
BA.version = "1.3"

BA.disabledBags = {
	[3] = true, -- BAG_GUILDBANK
	[4] = true, -- BAG_BUYBACK
	[17] = true, -- BAG_DELETE
}

function BA.BindAllUnknown(bag)
	
	if bag == nil then bag = GetBankingBag() end
	
	-- filter bags
	if BA.disabledBags[bag] ~= nil then bag = BAG_BACKPACK end
	
	-- also iterate the eso plus bank
	if bag == BAG_BANK and IsESOPlusSubscriber() == true then BA.BindAllUnknown(BAG_SUBSCRIBER_BANK) end
	
	local items = {}
	
	-- scan bag
	for slot = 0, GetBagSize(bag) - 1 do
		local itemLink = GetItemLink(bag, slot, LINK_STYLE_BRACKETS)
		if IsItemLinkSetCollectionPiece(itemLink) == true and IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) == false then
			local itemName = GetItemLinkName(itemLink)
			if items[itemName] == nil then
				items[itemName] = {}
				items[itemName].link = itemLink
				items[itemName].slot = slot
			end
		end
	end
	
	-- bind items
	for item, info in pairs(items) do
		BindItem(bag, info.slot)
		if BA.savedVariables.printToChat == true then
			d("Item bound: " .. info.link)
		end
	end
end

function BA.BindUnknown(bag, slot)
	local itemLink = GetItemLink(bag, slot, LINK_STYLE_BRACKETS)
	if IsItemLinkSetCollectionPiece(itemLink) == true and IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) == false then
		BindItem(bag, slot)
		if BA.savedVariables.printToChat == true then
			d("Item bound: " .. itemLink)
		end
	end
end

function BA.OnInventoryUpdate(_, bag, slot, isNew, _, updateReason, _)
	if BA.savedVariables.autoBind == true then
		BA.BindUnknown(bag, slot)
	end
end

function BA.OnAddOnLoaded(_, addonName)
	if addonName ~= BA.name then return end
	
	BA.initMenu()
	
	ZO_CreateStringId("SI_BINDING_NAME_BINDALL", "Bind all not collected items")
	SLASH_COMMANDS["/bindall"] = function() BA.BindAllUnknown() end
	
	EVENT_MANAGER:RegisterForEvent(BA.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, BA.OnInventoryUpdate)
	EVENT_MANAGER:AddFilterForEvent(BA.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
	EVENT_MANAGER:AddFilterForEvent(BA.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
end

EVENT_MANAGER:RegisterForEvent(BA.name, EVENT_ADD_ON_LOADED, BA.OnAddOnLoaded)