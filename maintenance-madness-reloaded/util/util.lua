-- Maintenance Madness - 2019. Created by Arcitos. License: See mod page.

--- HELPFUL FUNCTIONS

local mm_util = {}

local mfloor = math.floor
local mceil = math.ceil

function mm_util.notification(txt, force)
    if force ~= nil then
        if type(force) == "table" then
            force.print(txt)
        elseif type(force) == "number" then
            game.forces[force].print(txt)
        end
    else
        for k, p in pairs (game.players) do
            game.players[k].print(txt)
        end
    end
end

function mm_util.standardizeCycleTime(args)
	local MTBM = args.MTBM -- needs to be in ticks
	local MTTM = args.MTTM -- needs to be in ticks
	local MTTR = args.MTTR -- needs to be in ticks
	--local replacementAge = args.replacementAge -- percentage of life time, 80 by default
	local maxAge = args.maxAge -- index value, 100 by default
	local repairTimeModifier = args.repairTimeModifier
	local repairProbabilityModifier = args.repairProbabilityModifier
	local lifeTime = args.lifeTime -- needs to be in ticks
	
	local avgAge = maxAge / 2
	local avgMalfunctionRatio = math.min((avgAge / maxAge) * repairProbabilityModifier, 1)
	local avgMaintenanceRatio = 1 - avgMalfunctionRatio
	local avgMalfunctionTime = MTTR + (MTTR * repairTimeModifier * (avgAge / maxAge))
	local avgCycleTime = MTBM + MTTM * avgMaintenanceRatio + avgMalfunctionTime * avgMalfunctionRatio
	
	-- one cycle is the time from the start of one maintenance event to the start of the next event, by default about 13 min
	local expectedCyclesPerLifeTime = lifeTime / avgCycleTime
	
	return expectedCyclesPerLifeTime
end

function mm_util.calculateTextColor(colorMin, colorDelta, percentage)
	local textColor = {r = 0, g = 0, b = 0, a = 0}
	textColor.r = colorMin.r + colorDelta.r * percentage
	textColor.g = colorMin.g + colorDelta.g * percentage
	textColor.b = colorMin.b + colorDelta.b * percentage
	textColor.a = colorMin.a + colorDelta.a * percentage
	return textColor
end

function mm_util.round(input, precision)
	function sign(value)
		return (value >= 0 and 1) or -1
	end
	precision = precision or 1
	local s = sign(input)
	if s == 1 then
		return (mfloor(input / precision + sign(input) * 0.5) * precision)
	else
		return (mceil(input / precision + sign(input) * 0.5) * precision)
	end
end

function mm_util.getLength(t)
	local count = 0
	for k,v in pairs(t) do
		count = count + 1
	end
	return count
end

function mm_util.rPrint(s, l, i, tolog) -- recursive Print (structure, limit, indent, print to log)
	l = (l) or 100; i = i or ""	-- default item limit, indent string
	if (l<1) then 
		return l-1 end
	local ts = type(s)
	if (ts ~= "table") then 
		if game ~= nil and tolog then
			game.print(i..ts.." : "..tostring(s))
		else
			log(i..ts.." : "..tostring(s))
		end
		return l-1 
	end
	if game ~= nil and tolog then
		game.print(i..ts)          -- print "table"
	else
		log(i..ts)
	end
	for k,v in pairs(s) do  -- print "[KEY] VALUE"
		l = mm_util.rPrint(v, l, i.."\t["..tostring(k).."] ");
		if (l < 0) then 
			break 
		end
	end
	return l
end	

function mm_util.appendTable(target, source)
	for key, value in pairs(source) do
		if tonumber(key) == nil then -- if key is non numerical
			target[key] = value
		else
			table.insert(target, value) -- if key is numerical
		end
	end
end

function mm_util.getIngredientAmount(ingredientData)
	if ingredientData.amount ~= nil then
		return tonumber(ingredientData.amount)
	else
		for _, element in pairs(ingredientData) do
			if tonumber(element) ~= nil then
				return tonumber(element) --it's a number
			end
		end
	end
end

function mm_util.get_maxIconSize(item, defaultSize) 
	local maxIconSize = defaultSize or item.icon_size or 0
	if item.icons ~= nil then
		for _, layer in pairs(item.icons) do
			if layer.icon_size and layer.icon_size > maxIconSize then
				maxIconSize = layer.icon_size
			end
		end
	else
		maxIconSize = item.icon_size
	end
	return maxIconSize
end

function mm_util.getBoundingBoxDimensions(boundingBox)
	local point1 = boundingBox.left_top or boundingBox[1]
	local point2 = boundingBox.right_bottom or boundingBox[2]
	local width = (point2.x or point2[1]) - (point1.x or point1[1])
	local height = (point2.y or point2[2]) - (point1.y or point1[2])
	return {width = width, height = height}
end

function mm_util.rotateBoundingBox(boundingBox)
	local point1 = boundingBox.left_top or boundingBox[1]
	local point2 = boundingBox.right_bottom or boundingBox[2]
	local rotatedBoundingBox = {{point1.y or point1[2], point1.x or point1[1]}, {point2.y or point2[2], point2.x or point2[1]}}
	return rotatedBoundingBox
end

function mm_util.add_recipe_to_tech(rec, tech)
-- Ergänzt das übergebene Rezept (rec) dynamisch zu der übergebenen Technologie (tech)
-- Dynamically adds the given recipe to the given tech
    if data.raw.technology[tech] then
    local tech_already_changed = false
        for k,e in pairs(data.raw.technology[tech]["effects"]) do
            if e.recipe == rec then
                tech_already_changed = true
            end
        end
        if not tech_already_changed then
            table.insert(data.raw.technology[tech].effects, {type = "unlock-recipe", recipe = rec})
        end
    end
end

return mm_util