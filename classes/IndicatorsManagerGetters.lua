-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

-- FUNCTIONS USED TO GET INDICATORS
function IndicatorsManager:GetIndicator(name)
	-- Process action queue if it wasn't processed already, 
	-- required if function is used less in the same frame that indicator is created
	self:ProcessActionsQueue()

	if not name then
		outputDebugString( "Tried to get indicator, but name wasn't given", 2 )
		return false
	end

	name = tostring(name)
	if self.indicatorsByName[name] then
		return self.indicatorsByName[name]
	end
	return false
end

-- ALL
function IndicatorsManager:GetAllIndicators()
	-- Process action queue if it wasn't processed already, 
	-- required if function is used less in the same frame that indicator is created
	self:ProcessActionsQueue()

	local retTable = {}
	for dim,dimTable in pairs(self.indicators) do
		for ind,indicator in ipairs(dimTable) do
			table.insert(retTable, indicator)
		end
	end
	return retTable
end

function IndicatorsManager:GetIndicatorsInDimension(dimension)
	-- Process action queue if it wasn't processed already, 
	-- required if function is used less in the same frame that indicator is created
	self:ProcessActionsQueue()
	
	if not dimension then
		outputDebugString( "Tried to get indicators in dimension, but no argument was given", 2 )
		return false
	end

	local retTable = {}
	if self.indicators[dimension] then
		for ind,indicator in ipairs(self.indicators[dimension]) do
			table.insert(retTable, indicator)
		end
	end
	return retTable
end

-- STATIC
function IndicatorsManager:GetAllStaticIndicators()
	-- Process action queue if it wasn't processed already, 
	-- required if function is used less in the same frame that indicator is created
	self:ProcessActionsQueue()

	local retTable = {}
	for dim,dimTable in pairs(self.indicatorsStatic) do
		for ind,indicator in ipairs(dimTable) do
			table.insert(retTable, indicator)
		end
	end
	return retTable
end

function IndicatorsManager:GetStaticIndicatorsInDimension(dimension)
	-- Process action queue if it wasn't processed already, 
	-- required if function is used less in the same frame that indicator is created
	self:ProcessActionsQueue()

	if not dimension then
		outputDebugString( "Tried to get static indicators in dimension, but no argument was given", 2 )
		return false
	end

	local retTable = {}
	if self.indicatorsStatic[dimension] then
		for ind,indicator in ipairs(self.indicatorsStatic[dimension]) do
			table.insert(retTable, indicator)
		end
	end
	return retTable
end

-- DYNAMIC
function IndicatorsManager:GetAllDynamicIndicators()
	-- Process action queue if it wasn't processed already, 
	-- required if function is used less in the same frame that indicator is created
	self:ProcessActionsQueue()

	local retTable = {}
	for dim,dimTable in pairs(self.indicatorsDynamic) do
		for ind,indicator in ipairs(dimTable) do
			table.insert(retTable, indicator)
		end
	end
	return retTable
end

function IndicatorsManager:GetDynamicIndicatorsInDimension(dimension)
	-- Process action queue if it wasn't processed already, 
	-- required if function is used less in the same frame that indicator is created
	self:ProcessActionsQueue()

	if not dimension then
		outputDebugString( "Tried to get static indicators in dimension, but no argument was given", 2 )
		return false
	end

	local retTable = {}
	if self.indicatorsDynamic[dimension] then
		for ind,indicator in ipairs(self.indicatorsDynamic[dimension]) do
			table.insert(retTable, indicator)
		end
	end
	return retTable
end

-- GROUP
function IndicatorsManager:GetIndicatorsInGroup(group)
	-- Process action queue if it wasn't processed already, 
	-- required if function is used less in the same frame that indicator is created
	self:ProcessActionsQueue()

	if not group then
		outputDebugString( "Tried to get indicators in group, but group wasn't given", 2 )
		return false
	end

	group = tostring(group)
	local retTable = {}
	if self.indicatorsByGroup[group] then
		for ind,indicators in ipairs(self.indicatorsByGroup[group]) do
			table.insert(retTable, indicator)
		end
	end
	return retTable
end

-- MANAGER SETTINGS SETTERS
function IndicatorsManager:GetActive()
	return self.active
end

function IndicatorsManager:GetDistanceUpdateCountLimit(updateType)
	if updateType == "all" then
		return self.distanceUpdateCountLimit
	elseif updateType == "dimension" then
		return self.distanceUpdateCurDimCountLimit
	end

	return false
end

function IndicatorsManager:GetPositionUpdateCountLimit(updateType)
	if updateType == "all" then
		return self.positionUpdateCountLimit
	elseif updateType == "dimension" then
		return self.positionUpdateCurDimCountLimit
	end

	return false
end

-- DEFAULT INDICATOR SETTINGS
function IndicatorsManager:GetDefaultType()
	return self.defaultIndicatorType
end

function IndicatorsManager:GetDefaultDimension()
	return self.defaultIndicatorDimension
end

function IndicatorsManager:GetDefaultGroup()
	return self.defaultIndicatorGroup
end

function IndicatorsManager:GetDefaultPosition()
	return self.defaultIndicatorX,self.defaultIndicatorY,self.defaultIndicatorZ
end

function IndicatorsManager:GetDefaultOnTargetLostBehaviour()
	return self.defaultIndicatorOnTargetLost
end

-- INDICATOR IMAGE FUNCTIONS
function IndicatorsManager:GetDefaultImage()
	return self.defaultImage,self.defaultImageSizeX,self.defaultImageSizeY
end

function IndicatorsManager:GetDefaultImageScale()
	return self.defaultImageScale
end

function IndicatorsManager:GetDefaultImageColor()
	return self.defaultIndicatorColor
end

function IndicatorsManager:GetDefaultImageVisible()
	return self.defaultImageShowing
end

-- DISTANCE SETTINGS
function IndicatorsManager:GetDefaultMinDistance()
	return self.defaultIndicatorMinDistance
end

function IndicatorsManager:GetDefaultMaxDistance()
	return self.defaultIndicatorMaxDistance
end

-- TEXT SETTINGS
function IndicatorsManager:GetDefaultTextPlacement()
	return self.defaultTextPlacement
end

function IndicatorsManager:GetDefaultTextAlignmentX()
	return self.defaultTextAlignmentX
end

function IndicatorsManager:GetDefaultTextAlignmentY()
	return self.defaultTextAlignmentY
end

function IndicatorsManager:GetDefaultTextMargin()
	return self.defaultTextMargin
end

function IndicatorsManager:GetDefaultTextVisible()
	return self.defaultTextShowing
end

function IndicatorsManager:GetDefaultTextBackgroundVisible()
	return self.defaultTextBackgroundVisible
end

function IndicatorsManager:GetDefaultTextBackgroundColor()
	return self.defaultTextBackgroundColor
end

-- DISTANCE TEXT SETTINGS
function IndicatorsManager:GetDefaultDistancePlacement()
	return self.defaultDistancePlacement
end

function IndicatorsManager:GetDefaultDistanceAlignmentX()
	return self.defaultDistanceAlignmentX
end

function IndicatorsManager:GetDefaultDistanceAlignmentY()
	return self.defaultDistanceAlignmentY
end

function IndicatorsManager:GetDefaultDistanceMargin()
	return self.defaultDistanceMargin
end

function IndicatorsManager:GetDefaultDistanceVisible()
	return self.defaultDistanceShowing
end

function IndicatorsManager:GetDefaultDistanceBackgroundVisible()
	return self.defaultDistanceBackgroundVisible
end

function IndicatorsManager:GetDefaultDistanceBackgroundColor()
	return self.defaultDistanceBackgroundColor
end

-- FONT SETTINGS
function IndicatorsManager:GetDefaultFont()
	return self.defaultFont
end

function IndicatorsManager:GetDefaultFontScale()
	return self.defaultFontScale
end

function IndicatorsManager:GetDefaultText()
	return self.defaultIndicatorText
end

function IndicatorsManager:GetDefaultTextColor()
	return self.defaultFontColor
end