-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

IndicatorsManager = {}
IndicatorsManager.metatable = {
    __index = IndicatorsManager,
}
setmetatable( IndicatorsManager, { __call = function(self,...) return self:Get(...) end } )

function IndicatorsManager:Get()
    if not self.instance then
        self.instance = self:New()
    end
    return self.instance
end

function IndicatorsManager:New()
	local instance = setmetatable( {}, IndicatorsManager.metatable )

	-- Font settings
	instance.defaultFont = "default"
	instance.defaultFontScale = 1
	instance.defaultFontColor = tocolor(255, 255, 255)

	-- Text placement settings
	instance.defaultTextPlacement = "top"
	instance.defaultTextAlignmentX = "center"
	instance.defaultTextAlignmentY = "center"
	instance.defaultTextMargin = 3
	instance.defaultTextShowing = true

	instance.defaultTextBackgroundVisible = false
	instance.defaultTextBackgroundColor = tocolor(255, 255, 255, 100)

	instance.defaultDistanceBackgroundVisible = false
	instance.defaultDistanceBackgroundColor = tocolor(255, 255, 255, 100)

	-- Distance placement settings
	instance.defaultDistancePlacement = "bottom"
	instance.defaultDistanceAlignmentX = "center"
	instance.defaultDistanceAlignmentY = "center"
	instance.defaultDistanceMargin = 3
	instance.defaultDistanceShowing = true

	-- Indicator look settings
	instance.defaultImage = dxCreateTexture( "files/indicatorIcon.png", "dxt5", true, "clamp")
	if isElement(instance.defaultImage) then
		instance.defaultImageSizeX, instance.defaultImageSizeY = dxGetMaterialSize( instance.defaultImage )
	else
		isntance.encounteredIssue = true
		instance.issue = "Couldn't create default indicator image"
	end
	instance.defaultImageScale = 1
	instance.defaultImageShowing = true

	-- Default indicator settings
	instance.defaultIndicatorText = ""
	instance.defaultIndicatorX = 0
	instance.defaultIndicatorY = 0
	instance.defaultIndicatorZ = 0
	instance.defaultIndicatorMinDistance = 2
	instance.defaultIndicatorMaxDistance = 6000
	instance.defaultIndicatorColor = tocolor(159, 255, 194)
	instance.defaultIndicatorType = "static"
	instance.defaultIndicatorOnTargetLost = "destroy"
	instance.defaultIndicatorDimension = "all"
	instance.defaultIndicatorGroup = "default"

	-- Indicator storage tables
	instance.indicators = {["all"] = {}}
	instance.indicatorsStatic = {["all"] = {}}
	instance.indicatorsDynamic = {["all"] = {}}
	instance.indicatorsByName = {}
	instance.indicatorsByGroup = {}
	instance.actionsQueue = {}

	-- Indicator manager settings
	instance.distanceUpdateCountLimit = 75
	instance.distanceUpdateLastIndex = 1
	instance.distanceUpdateCurrentIndex = 1
	instance.distanceUpdateCounter = 0
	instance.distanceUpdateAllCoroutine = coroutine.create( bind(IndicatorsManager.UpdateDistancesAll, instance) )

	instance.positionUpdateCountLimit = 5
	instance.positionUpdateLastIndex = 1
	instance.positionUpdateCurrentIndex = 1
	instance.positionUpdateCounter = 0
	instance.positionUpdateAllCoroutine = coroutine.create( bind(IndicatorsManager.UpdatePositionsAll, instance) )

	-- Indicator manager settings for current dimension
	instance.distanceUpdateCurDimCountLimit = 75
	instance.distanceUpdateCurDimLastIndex = 1
	instance.distanceUpdateCurDimCurrentIndex = 1
	instance.distanceUpdateCurDimCounter = 0
	instance.distanceUpdateCurDimCoroutine = coroutine.create( bind(IndicatorsManager.UpdateDistancesCurDim, instance) )

	instance.positionUpdateCurDimCountLimit = 5
	instance.positionUpdateCurDimLastIndex = 1
	instance.positionUpdateCurDimCurrentIndex = 1
	instance.positionUpdateCurDimCounter = 0
	instance.positionUpdateCurDimCoroutine = coroutine.create( bind(IndicatorsManager.UpdatePositionsCurDim, instance) )

	instance.currentDimension = 0
	instance.indicatorsCountAll = 0
	instance.indicatorsCountCurDim = 0
	instance.indicatorsDynamicCountAll = 0
	instance.indicatorsDynamicCountCurDim = 0

	if instance.encounteredIssue then
		outputDebugString( "Encountered issue during IndicatorsManager initialization: "..tostring(instance.issue), 1 )
		return false
	end

	instance.onRenderBoundFunction = bind(IndicatorsManager.HandleRender, instance)
	instance.active = true
	addEventHandler( "onClientRender", root, instance.onRenderBoundFunction )

	return instance
end

function IndicatorsManager:CreateIndicator(name, text, x, y, z, dimension)
	-- Process action queue if it wasn't processed already, 
	-- required if function is used less in the same frame that indicator is created
	self:ProcessActionsQueue()
	
	-- Check if any name has been given or type of name isn't string
	if not (name and (type(name) == "string")) then
		outputDebugString( "Failed to create indicator, no name given or name isn't a string", 1 )
		return false
	end

	-- Check if any name has been given
	if #name < 1 then
		outputDebugString( "Failed to create indicator, no name given", 1 )
		return false
	end

	-- Check if given name isn't already in use
	if self.indicatorsByName[name] then
		outputDebugString( "Failed to create indicator, name already in use: "..name, 1 )
		return false
	end

	-- Give default values if they aren't given
	text = text or self.defaultIndicatorText
	x = tonumber(x) or self.defaultIndicatorX
	y = tonumber(y) or self.defaultIndicatorY
	z = tonumber(z) or self.defaultIndicatorZ
	dimension = dimension or self.defaultIndicatorDimension

	-- Create indicator and give it all default values
	local indicator = Indicator(name)
	indicator:SetDimension(dimension)
	indicator:SetGroup(self.defaultIndicatorGroup)
	indicator:SetType(self.defaultIndicatorType)
	indicator:SetImage(self.defaultImage, self.defaultImageSizeX, self.defaultImageSizeY)
	indicator:SetImageScale(self.defaultImageScale)
	indicator:SetImageColor(self.defaultIndicatorColor)
	indicator:SetImageVisible(self.defaultImageShowing)
	indicator:SetFont(self.defaultFont)
	indicator:SetFontScale(self.defaultFontScale)
	indicator:SetMinDistance(self.defaultIndicatorMinDistance)
	indicator:SetMaxDistance(self.defaultIndicatorMaxDistance)
	indicator:SetTextPlacement(self.defaultTextPlacement)
	indicator:SetDistancePlacement(self.defaultDistancePlacement)
	indicator:SetTextAlignementX(self.defaultTextAlignmentX)
	indicator:SetTextAlignementY(self.defaultTextAlignmentY)
	indicator:SetTextMargin(self.defaultTextMargin)
	indicator:SetDistanceAlignmentX(self.defaultDistanceAlignmentX)
	indicator:SetDistanceAlignmentY(self.defaultDistanceAlignmentY)
	indicator:SetDistanceMargin(self.defaultDistanceMargin)
	indicator:SetTextVisible(self.defaultTextShowing)
	indicator:SetDistanceVisible(self.defaultDistanceShowing)
	indicator:SetText(text)
	indicator:SetTextColor(self.defaultFontColor)
	indicator:SetTextBackgroundVisible(self.defaultTextBackgroundVisible)
	indicator:SetTextBackgroundColor(self.defaultTextBackgroundColor)
	indicator:SetDistanceBackgroundVisible(self.defaultDistanceBackgroundVisible)
	indicator:SetDistanceBackgroundColor(self.defaultDistanceBackgroundColor)
	indicator:SetPosition(x,y,z)
	indicator:SetOnTargetLostBehaviour(self.defaultIndicatorOnTargetLost)

	self:AddAction( {"register", indicator} )
	return indicator
end

function IndicatorsManager:DestroyIndicatorByName(name)
	local indicator = self:GetIndicator(name)
	if not indicator then
		outputDebugString( "Tried to destroy indicator, but indicator with given name doesn't exist", 2 )
		return false
	end
	indicator:Destroy()
end

function IndicatorsManager:OnIndicatorTypeChange(indicator, oldType)
	self:AddAction( {"typechange", indicator, oldType} )
end

function IndicatorsManager:OnIndicatorDimensionChange(indicator, oldDim)
	self:AddAction( {"dimensionchange", indicator, oldDim} )
end

function IndicatorsManager:OnIndicatorGroupChange(indicator, oldGroup)
	self:AddAction( {"groupchange", indicator, oldGroup} )
end

function IndicatorsManager:OnIndicatorDestroy(indicator)
	self:AddAction( {"destroy", indicator} )
end

function IndicatorsManager:AddAction(action)
	if type(action) ~= "table" then return end
	table.insert( self.actionsQueue, action )
end

function IndicatorsManager:ProcessAction(action)
	local actionName = action[1]
	if not actionName then return end
	if actionName == "typechange" then
		self:RefreshIndicatorTypeCaches(action[2],action[3])
	elseif actionName == "dimensionchange" then
		self:RefreshIndicatorDimensionCaches(action[2],action[3])
	elseif actionName == "groupchange" then
		self:RefreshIndicatorGroupCaches(action[2],action[3])
	elseif actionName == "destroy" then
		self:RemoveIndicatorFromCaches(action[2])
	elseif actionName == "register" then
		self:RegisterIndicator(action[2])
	end
end

function IndicatorsManager:RefreshIndicatorTypeCaches(indicator, oldType)
	if indicator.destroyed then return end
	local indDim = indicator.dimension
	-- Remove indicator from it's current cache table
	if oldType == "static" then
		if self.indicatorsStatic[indDim] then
			table.removeValue(self.indicatorsStatic[indDim],indicator)
		end
	elseif oldType == "dynamic" then
		if self.indicatorsDynamic[indDim] then
			table.removeValue(self.indicatorsDynamic[indDim],indicator)
		end
	end	
	-- Add indicator to proper cache table
	if indicator.type == "static" then
		-- Create dimension table for that indicator type if it doesn't exist
		if not self.indicatorsStatic[indDim] then self.indicatorsStatic[indDim] = {} end
		table.insert(self.indicatorsStatic[indDim], indicator)
	elseif indicator.type == "dynamic" then
		-- Create dimension table for that indicator type if it doesn't exist
		if not self.indicatorsDynamic[indDim] then self.indicatorsDynamic[indDim] = {} end
		table.insert(self.indicatorsDynamic[indDim], indicator)
	end
end

function IndicatorsManager:RefreshIndicatorDimensionCaches(indicator, oldDim)
	if indicator.destroyed then return end
	local indDim = indicator.dimension
	-- Remove indicator from it's current cache table
	if indicator.type == "static" then
		if self.indicatorsStatic[oldDim] then
			table.removeValue(self.indicatorsStatic[oldDim], indicator)
		end
		-- Create indicator dimension table if it doesn't exist
		if not self.indicatorsStatic[indDim] then 
			self.indicatorsStatic[indDim] = {} 
		end
		-- Insert indicator to that table
		table.insert(self.indicatorsStatic[indDim], indicator)

	elseif indicator.type == "dynamic" then
		if self.indicatorsDynamic[oldDim] then
			table.removeValue(self.indicatorsDynamic[oldDim], indicator)
		end
		-- Create indicator dimension table if it doesn't exist
		if not self.indicatorsDynamic[indDim] then 
			self.indicatorsDynamic[indDim] = {} 
		end
		-- Insert indicator to that table
		table.insert(self.indicatorsDynamic[indDim], indicator)
	end	

	if self.indicators[oldDim] then
		table.removeValue(self.indicators[oldDim], indicator)
	end
	if not self.indicators[indDim] then
		self.indicators[indDim] = {}
	end
	table.insert(self.indicators[indDim], indicator)
end

function IndicatorsManager:RefreshIndicatorGroupCaches(indicator, oldGroup)
	if indicator.destroyed then return end
	local indGroup = indicator.group
	-- Remove indicator from current group
	if self.indicatorsByGroup[oldGroup] then
		table.removeValue(self.indicatorsByGroup[oldGroup], indicator)
	end

	-- Check if new group table exists, create it if not
	if not self.indicatorsByGroup[indGroup] then
		self.indicatorsByGroup[indGroup] = {}
	end
	-- Insert indicator to group table
	table.insert(self.indicatorsByGroup[indGroup], indicator)
end

function IndicatorsManager:RemoveIndicatorFromCaches(indicator)
	if not indicator.destroyed then return end
	local indDim = indicator.dimension
	-- Remove from type caches
	if indicator.type == "static" then
		if self.indicatorsStatic[indDim] then
			table.removeValue(self.indicatorsStatic[indDim], indicator)
		end
	elseif indicator.type == "dynamic" then
		if self.indicatorsDynamic[indDim] then
			table.removeValue(self.indicatorsDynamic[indDim], indicator)
		end
	end
	-- Remove from table cholding all indicators
	table.removeValue(self.indicators[indDim], indicator)
	-- Remove indicator from group table
	table.removeValue(self.indicatorsByGroup[indicator.group], indicator)
	if self.indicatorsByName[indicator.name] then
		self.indicatorsByName[indicator.name] = nil
	end
end

function IndicatorsManager:RegisterIndicator(indicator)
	local indDim = indicator.dimension
	local indType = indicator.type
	local indGroup = indicator.group
	if indDim and (not self.indicators[indDim]) then
		self.indicators[indDim] = {}
	end
	table.insert(self.indicators[indDim], indicator)
	
	-- Add indicator to proper cache table
	if indType == "static" then
		-- Create dimension table for that indicator type if it doesn't exist
		if not self.indicatorsStatic[indDim] then self.indicatorsStatic[indDim] = {} end
		table.insert(self.indicatorsStatic[indDim], indicator)
	elseif indType == "dynamic" then
		-- Create dimension table for that indicator type if it doesn't exist
		if not self.indicatorsDynamic[indDim] then self.indicatorsDynamic[indDim] = {} end
		table.insert(self.indicatorsDynamic[indDim], indicator)
	end

	-- Add indicator to group table
	if not self.indicatorsByGroup[indGroup] then
		self.indicatorsByGroup[indGroup] = {}
	end
	-- Insert indicator to group table
	table.insert(self.indicatorsByGroup[indGroup], indicator)

	indicator.registered = true
	self.indicatorsByName[indicator.name] = indicator
end


-- This function updates current distance from camera of indicators
-- It works this way:
-- It loops over indicators table, until it hit's starting index again, or until it reaches limit of updated indicators (distanceUpdateCountLimit)
-- On next resume of coroutine, it starts from index 1 higher from last finished one, if it's above number of elements in table, it loops over to the beggining of table
-- So it loops over n-elements or until it hits itself again on each coroutine resume
function IndicatorsManager:UpdateDistancesAll()
	while true do
		-- Reset updated elements counter to 0 at the beggining of every resume of this coroutine
		self.distanceUpdateCounter = 0
		-- Get total number of indicators in table, this number bay have changed from last coroutine resume, and in that case current idexes
		-- will probably be out of table bounds, check for that and place index at end of table if that's the case
		local numOfIndicators = #self.indicators["all"]
		if self.distanceUpdateCurrentIndex > numOfIndicators then
			self.distanceUpdateCurrentIndex = numOfIndicators
			self.distanceUpdateLastIndex = numOfIndicators - 1
		end
		-- Get current camera positions, used to calculate distances from indicators
		local cx,cy,cz = getCameraMatrix()
		if cx then 
			-- Loop over indicators table until limit per frame is reached, or until it hits starting element for this iteration
			repeat
				self.indicators["all"][self.distanceUpdateCurrentIndex]:UpdateDistance(cx,cy,cz)
				self.distanceUpdateCurrentIndex = (self.distanceUpdateCurrentIndex%(numOfIndicators))+1
				self.distanceUpdateCounter = self.distanceUpdateCounter + 1
			until self.distanceUpdateCurrentIndex == self.distanceUpdateLastIndex or (self.distanceUpdateCounter > self.distanceUpdateCountLimit)
			-- Save current index as last indes for comparision in next coroutine continue
			self.distanceUpdateLastIndex = self.distanceUpdateCurrentIndex
			-- Increment current index by 1, loop to beggining if it's over the table bounds, it's gonna be first element updated on next coroutine resume
			self.distanceUpdateCurrentIndex = (self.distanceUpdateCurrentIndex%(numOfIndicators))+1
		end
		coroutine.yield( )
	end
end

-- This function updates current positions of indicators
-- It works this way:
-- It loops over indicators table, until it hit's starting index again, or until it reaches limit of updated indicators (positionUpdateCountLimit)
-- On next resume of coroutine, it starts from index 1 higher from last finished one, if it's above number of elements in table, it loops over to the beggining of table
-- So it loops over n-elements or until it hits itself again on each coroutine resume
function IndicatorsManager:UpdatePositionsAll()
	while true do
		-- Reset updated elements counter to 0 at the beggining of every resume of this coroutine
		self.positionUpdateCounter = 0
		-- Get total number of indicators in table, this number bay have changed from last coroutine resume, and in that case current idexes
		-- will probably be out of table bounds, check for that and place index at end of table if that's the case
		local numOfIndicators = #self.indicatorsDynamic["all"]
		if self.positionUpdateCurrentIndex > numOfIndicators then
			self.positionUpdateCurrentIndex = numOfIndicators
			self.positionUpdateLastIndex = numOfIndicators - 1
		end
		-- Loop over indicators table until limit per frame is reached, or until it hits starting element for this iteration
		repeat
			self.indicatorsDynamic["all"][self.positionUpdateCurrentIndex]:UpdatePosition()
			self.positionUpdateCurrentIndex = (self.positionUpdateCurrentIndex%(numOfIndicators))+1
			self.positionUpdateCounter = self.positionUpdateCounter + 1
		until self.positionUpdateCurrentIndex == self.positionUpdateLastIndex or (self.positionUpdateCounter > self.positionUpdateCountLimit)
		-- Save current index as last indes for comparision in next coroutine continue
		self.positionUpdateLastIndex = self.positionUpdateCurrentIndex
		-- Increment current index by 1, loop to beggining if it's over the table bounds, it's gonna be first element updated on next coroutine resume
		self.positionUpdateCurrentIndex = (self.positionUpdateCurrentIndex%(numOfIndicators))+1

		coroutine.yield( )
	end
end

-- This function updates current distance from camera of indicators
-- It works this way:
-- It loops over indicators table, until it hit's starting index again, or until it reaches limit of updated indicators (distanceUpdateCountLimit)
-- On next resume of coroutine, it starts from index 1 higher from last finished one, if it's above number of elements in table, it loops over to the beggining of table
-- So it loops over n-elements or until it hits itself again on each coroutine resume
function IndicatorsManager:UpdateDistancesCurDim()
	while true do
		-- Reset updated elements counter to 0 at the beggining of every resume of this coroutine
		self.distanceUpdateCurDimCounter = 0
		-- Get total number of indicators in table, this number bay have changed from last coroutine resume, and in that case current idexes
		-- will probably be out of table bounds, check for that and place index at end of table if that's the case
		local numOfIndicators = #self.indicators[self.currentDimension]
		if self.distanceUpdateCurDimCurrentIndex > numOfIndicators then
			self.distanceUpdateCurDimCurrentIndex = numOfIndicators
			self.distanceUpdateCurDimLastIndex = numOfIndicators - 1
		end
		-- Get current camera positions, used to calculate distances from indicators
		local cx,cy,cz = getCameraMatrix()
		if cx then 
			-- Loop over indicators table until limit per frame is reached, or until it hits starting element for this iteration
			repeat
				self.indicators[self.currentDimension][self.distanceUpdateCurDimCurrentIndex]:UpdateDistance(cx,cy,cz)
				self.distanceUpdateCurDimCurrentIndex = (self.distanceUpdateCurDimCurrentIndex%(numOfIndicators))+1
				self.distanceUpdateCurDimCounter = self.distanceUpdateCurDimCounter + 1
			until self.distanceUpdateCurDimCurrentIndex == self.distanceUpdateCurDimLastIndex or (self.distanceUpdateCurDimCounter > self.distanceUpdateCurDimCountLimit)
			-- Save current index as last indes for comparision in next coroutine continue
			self.distanceUpdateCurDimLastIndex = self.distanceUpdateCurDimCurrentIndex
			-- Increment current index by 1, loop to beggining if it's over the table bounds, it's gonna be first element updated on next coroutine resume
			self.distanceUpdateCurDimCurrentIndex = (self.distanceUpdateCurDimCurrentIndex%(numOfIndicators))+1
		end
		coroutine.yield( )
	end
end

-- This function updates current positions of indicators
-- It works this way:
-- It loops over indicators table, until it hit's starting index again, or until it reaches limit of updated indicators (positionUpdateCountLimit)
-- On next resume of coroutine, it starts from index 1 higher from last finished one, if it's above number of elements in table, it loops over to the beggining of table
-- So it loops over n-elements or until it hits itself again on each coroutine resume
function IndicatorsManager:UpdatePositionsCurDim()
	while true do
		-- Reset updated elements counter to 0 at the beggining of every resume of this coroutine
		self.positionUpdateCurDimCounter = 0
		-- Get total number of indicators in table, this number bay have changed from last coroutine resume, and in that case current idexes
		-- will probably be out of table bounds, check for that and place index at end of table if that's the case
		local numOfIndicators = #self.indicatorsDynamic[self.currentDimension]
		if self.positionUpdateCurDimCurrentIndex > numOfIndicators then
			self.positionUpdateCurDimCurrentIndex = numOfIndicators
			self.positionUpdateCurDimLastIndex = numOfIndicators - 1
		end
		-- Loop over indicators table until limit per frame is reached, or until it hits starting element for this iteration
		repeat
			self.indicatorsDynamic[self.currentDimension][self.positionUpdateCurrentIndex]:UpdatePosition()
			self.positionUpdateCurDimCurrentIndex = (self.positionUpdateCurDimCurrentIndex%(numOfIndicators))+1
			self.positionUpdateCurDimCounter = self.positionUpdateCurDimCounter + 1
		until self.positionUpdateCurDimCurrentIndex == self.positionUpdateCurDimLastIndex or (self.positionUpdateCurDimCounter > self.positionUpdateCurDimCountLimit)
		-- Save current index as last indes for comparision in next coroutine continue
		self.positionUpdateCurDimLastIndex = self.positionUpdateCurDimCurrentIndex
		-- Increment current index by 1, loop to beggining if it's over the table bounds, it's gonna be first element updated on next coroutine resume
		self.positionUpdateCurDimCurrentIndex = (self.positionUpdateCurDimCurrentIndex%(numOfIndicators))+1

		coroutine.yield( )
	end
end

function IndicatorsManager:UpdateDimension()
	self.currentDimension = getElementDimension( localPlayer )
end

function IndicatorsManager:UpdateIndicatorCounts()
	-- update count of indicators visible in all dimensions
	self.indicatorsCountAll = #self.indicators["all"]
	-- update count of indicators visible only in current dimension
	if self.indicators[self.currentDimension] then
		self.indicatorsCountCurDim = #self.indicators[self.currentDimension]
	else
		self.indicatorsCountCurDim = 0
	end

	-- update count of dynamic indicators visible in all dimensions
	self.indicatorsDynamicCountAll = #self.indicatorsDynamic["all"]
	-- update count of indicators visible only in current dimension
	if self.indicatorsDynamic[self.currentDimension] then
		self.indicatorsDynamicCountCurDim = #self.indicatorsDynamic[self.currentDimension]
	else
		self.indicatorsDynamicCountCurDim = 0
	end
end

function IndicatorsManager:ProcessActionsQueue()
	while self.actionsQueue[1] do
		self:ProcessAction(self.actionsQueue[1])
		table.remove(self.actionsQueue,1)
	end
end

function IndicatorsManager:HandleRender()
	-- Process actions queue at the start of render
	self:ProcessActionsQueue()

	-- Update current dimension
	self:UpdateDimension()

	-- Update indicator counts
	self:UpdateIndicatorCounts()

	-- Check if there are any indicators, return if not
	if (self.indicatorsCountAll+self.indicatorsCountCurDim) < 1 then return end

	-- If count of indicators visible in all dimensions is bigger than limit of updated indicators per frame, use coroutine for that, in other case just update all indicators
	if self.indicatorsCountAll > 0 then
		if self.indicatorsCountAll > self.distanceUpdateCountLimit then
			coroutine.resume( self.distanceUpdateAllCoroutine )
		else
			local cx,cy,cz = getCameraMatrix()
			if cx then 
				for i=1, self.indicatorsCountAll do
					self.indicators["all"][i]:UpdateDistance(cx,cy,cz)
				end
			end
		end
	end

	-- Update positions of dynamic indicators visible in all dimensions
	if self.indicatorsDynamicCountAll > 0 then
		if self.indicatorsDynamicCountAll > self.positionUpdateCountLimit then
			coroutine.resume( self.positionUpdateAllCoroutine )
		else
			for i=1, self.indicatorsDynamicCountAll do
				self.indicatorsDynamic["all"][i]:UpdatePosition()
			end
		end
	end

	-- Update distance from indicators in current dimension
	if self.indicatorsCountCurDim > 0 then
		if self.indicatorsCountCurDim > self.distanceUpdateCurDimCountLimit then
			coroutine.resume( self.distanceUpdateCurDimCoroutine )
		else
			local cx,cy,cz = getCameraMatrix()
			if cx then 
				for i=1, self.indicatorsCountCurDim do
					self.indicators[self.currentDimension][i]:UpdateDistance(cx,cy,cz)
				end
			end
		end
	end

	-- Update position of indicators in current dimension
	if self.indicatorsDynamicCountCurDim > 0 then
		if self.indicatorsDynamicCountCurDim > self.positionUpdateCurDimCountLimit then
			coroutine.resume( self.positionUpdateCurDimCoroutine )
		else
			for i=1, self.indicatorsDynamicCountCurDim do
				self.indicatorsDynamic[self.currentDimension][i]:UpdatePosition()
			end
		end
	end

	for i=1,self.indicatorsCountAll do
		local indicator = self.indicators["all"][i]
		if indicator.isInDistRange then
			indicator:Draw()
		end
	end

	for i=1,self.indicatorsCountCurDim do
		local indicator = self.indicators[self.currentDimension][i]
		if indicator.isInDistRange then
			indicator:Draw()
		end
	end
end
