-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

-- MANAGER SETTINGS SETTERS
function IndicatorsManager:SetActive(state)
	-- Check if given state is boolean
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change IndicatorsManager active state, but given state isn't a boolean: "..tostring(group), 2 )
		return false
	end
	-- Return function right here if given state is same as current one
	if state == self.active then return true end

	-- Add or remove onClientRender event handler based on what state was given
	if state then
		self.active = true
		addEventHandler( "onClientRender", root, self.onRenderBoundFunction )
	else
		self.active = false
		removeEventHandler( "onClientRender", root, self.onRenderBoundFunction )
	end
	return true
end

function IndicatorsManager:SetDistanceUpdateCountLimit(updateType, limit)
	-- Check if given type is valid
	if not (updateType and AllowedUpdateLimitsTypes[updateType]) then
		outputDebugString( "Tried to change distance update count limit, but given type isn't allowed: "..tostring(limit), 1 )
		return false
	end

	-- Check if given limit is a number
	if type(limit) ~= "number" then
		outputDebugString( "Tried to change distance update count limit, but given limit isn't a number: "..tostring(limit), 1 )
		return false
	end

	-- Limit shouldn't ever be a negative number
	if limit < 0 then limit = 0 end

	if updateType == "all" then
		self.distanceUpdateCountLimit = limit
	elseif updateType == "dimension" then
		self.distanceUpdateCurDimCountLimit = limit
	end
	return self
end

function IndicatorsManager:SetPositionUpdateCountLimit(updateType, limit)
	-- Check if given type is valid
	if not (updateType and AllowedUpdateLimitsTypes[updateType]) then
		outputDebugString( "Tried to change position update count limit, but given type isn't allowed: "..tostring(limit), 1 )
		return false
	end

	-- Check if given limit is a number
	if type(limit) ~= "number" then
		outputDebugString( "Tried to change position update count limit, but given limit isn't a number: "..tostring(limit), 1 )
		return false
	end

	-- Limit shouldn't ever be a negative number
	if limit < 0 then limit = 0 end

	if updateType == "all" then
		self.positionUpdateCountLimit = limit
	elseif updateType == "dimension" then
		self.positionUpdateCurDimCountLimit = limit
	end
	return self
end

-- DEFAULT INDICATOR SETTINGS
	-- INDICATOR TYPE FUNCTIONS
function IndicatorsManager:SetDefaultType(newType)
	-- Check if type is allowed
	if not AllowedTypes[newType] then
		outputDebugString( "Tried to give indicator default unknown type: "..tostring(newType), 2 )
		return false
	end

	-- Check if type is different from current one
	if newType == self.defaultIndicatorType then return end

	self.defaultIndicatorType = newType
	return self
end

function IndicatorsManager:SetDefaultDimension(dimension)
	-- Check if dimension is allowed
	if type(dimension) == "string" then
		if dimension ~= "all" then
			outputDebugString( "Tried to give indicator default unknown dimension: "..tostring(dimension), 2 )
			return false
		end
	elseif type(dimension) ~= "number" then
		outputDebugString( "Tried to give indicator default unknown dimension: "..tostring(dimension), 2 )
		return false	
	end

	-- Check if type is different from current one
	if dimension == self.defaultIndicatorDimension then return end

	self.defaultIndicatorDimension = dimension
	return self
end

function IndicatorsManager:SetDefaultGroup(group)
	-- If type of group is number, make it string
	if type(group) == "number" then
		group = tostring(group)
	end

	-- If type of text is neither number nor string give warning and return false
	if type(group) ~= "string" then
		outputDebugString( "Tried to set indicator default group, but given value is neither string nor number: "..tostring(group), 2 )
		return false
	end

	if group == "" then
		outputDebugString( "Tried to set indicator default group, but given value is an empty string: "..tostring(group), 2 )
		return false
	end

	-- Check if group is different from current one
	if group == self.defaultIndicatorGroup then return end
	self.defaultIndicatorGroup = group

	return self
end

function IndicatorsManager:SetDefaultPosition(x, y, z)
	-- Check if all arguments are given
	if not (x and y and z) then
		outputDebugString( "Tried to set default position in indicatorsManager, but some arguments are missing", 2 )
		return false
	end

	-- Set those arguments as indicator positions
	self.defaultIndicatorX = x
	self.defaultIndicatorY = y
	self.defaultIndicatorZ = z
	return self
end

function IndicatorsManager:SetDefaultOnTargetLostBehaviour(behaviour)
	if not AllowedLostTargetBehaviours[behaviour] then
		outputDebugString( "Tried to change indicator default on target lost behaviour, but given behaviour isn't correct: "..tostring(behaviour), 2 )
		return false
	end
	self.defaultIndicatorOnTargetLost = behaviour
	return self
end

-- INDICATOR IMAGE FUNCTIONS
function IndicatorsManager:SetDefaultImage(image, sizeX, sizeY)
	-- Chech if image is element
	if not isElement(image) then
		outputDebugString( "Tried to change default indicator image, but it isn't an element", 2 )
		return false
	end

	-- Set image
	self.defaultImage = image

	-- Update cached image size with given arguments, or calculate it if it isn't given
	if sizeX then
		self.defaultImageSizeX = sizeX
		self.defaultImageSizeY = sizeY
	else
		self.defaultImageSizeX,self.defaultImageSizeY = dxGetMaterialSize(self.defaultImage)
	end
	return self
end

function IndicatorsManager:SetDefaultImageScale(scale)
	if type(scale) ~= "number" then
		outputDebugString( "Tried to change indicator default image scale, but given argument isn't a number", 2 )
		return false
	end
	-- Change image scale
	self.defaultImageScale = scale
	return self
end

function IndicatorsManager:SetDefaultImageColor(color, colG, colB, colA)
	-- Make sure it was either valid color, or 3 valid numbers to make a color
	if color and colG and colB then
		colA = colA or 255
		color = tocolor( color, colG, colB, colA )
	elseif type(color) ~= "number" then
		outputDebugString( "Tried to set indicator default image color, but given arguments were invalid.", 2 )
		return false
	end

	self.defaultIndicatorColor = color
	return self
end

function IndicatorsManager:SetDefaultImageVisible(state)
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator default image visibility but given state isn't a boolean", 2 )
		return false
	end

	self.defaultImageShowing = state
	return self
end

-- DISTANCE SETTINGS
function IndicatorsManager:SetDefaultMinDistance(dist)
	-- Change indicator minimum show distance
	self.defaultIndicatorMinDistance = dist
	return self
end

function IndicatorsManager:SetDefaultMaxDistance(dist)
	-- Change indicator minimum show distance
	self.defaultIndicatorMaxDistance = dist
	return self
end

-- TEXT SETTINGS
function IndicatorsManager:SetDefaultTextPlacement(placement)
	-- Check if placement is allowed
	if not AllowedPlacements[placement] then
		outputDebugString( "Tried to give indicator default text unknown placement: "..tostring(placement), 2 )
		return false
	end

	self.defaultTextPlacement = placement
	return self
end

function IndicatorsManager:SetDefaultTextAlignementX(alignment)
	-- Check if alignment is allowed
	if not AllowedAlignmentX[alignment] then
		outputDebugString( "Tried to give indicator default text unknown alignmentX: "..tostring(alignment), 2 )
		return false
	end

	self.defaultTextAlignmentX = alignment
	return self
end

function IndicatorsManager:SetDefaultTextAlignementY(alignment)
	-- Check if alignment is allowed
	if not AllowedAlignmentY[alignment] then
		outputDebugString( "Tried to give indicator default text unknown alignmentY: "..tostring(alignment), 2 )
		return false
	end

	self.defaultTextAlignmentY = alignment
	return self
end

function IndicatorsManager:SetDefaultTextMargin(margin)
	-- Check if given margin is a number
	if type(margin) ~= "number" then
		outputDebugString( "Tried to change indicator default margin, but given parameter isn't a number", 2 )
		return false
	end

	self.defaultTextMargin = margin
	return self
end

function IndicatorsManager:SetDefaultTextVisible(state)
	-- Check if given state is boolean
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator default text visibility but given state isn't a boolean", 2 )
		return false
	end

	self.defaultTextShowing = state
	return self
end

function IndicatorsManager:SetDefaultTextBackgroundVisible(state)
	-- Check if given state is boolean
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator default text background visibility but given state isn't a boolean", 2 )
		return false
	end

	self.defaultTextBackgroundVisible = state
	return self
end

function IndicatorsManager:SetDefaultTextBackgroundColor(color, colG, colB, colA)
	-- Make sure it was either valid color, or 3 valid numbers to make a color
	if color and colG and colB then
		colA = colA or 255
		color = tocolor( color, colG, colB, colA )
	elseif type(color) ~= "number" then
		outputDebugString( "Tried to set indicator default text background color, but given arguments were invalid." )
		return false
	end

	self.defaultTextBackgroundColor = color
	return self
end

-- DISTANCE TEXT SETTINGS
function IndicatorsManager:SetDefaultDistancePlacement(placement)
	-- Check if placement is allowed
	if not AllowedPlacements[placement] then
		outputDebugString( "Tried to give indicator default distance text unknown placement: "..tostring(placement), 2 )
		return false
	end

	self.defaultDistancePlacement = placement
	return self
end

function IndicatorsManager:SetDefaultDistanceAlignmentX(alignment)
	-- Check if alignment is allowed
	if not AllowedAlignmentX[alignment] then
		outputDebugString( "Tried to give indicator default distance unknown alignmentX: "..tostring(alignment), 2 )
		return false
	end

	self.defaultDistanceAlignmentX = alignment
	return self
end

function IndicatorsManager:SetDefaultDistanceAlignmentY(alignment)
	-- Check if alignment is allowed
	if not AllowedAlignmentY[alignment] then
		outputDebugString( "Tried to give indicator default distance unknown alignmentY: "..tostring(alignment), 2 )
		return false
	end

	self.defaultDistanceAlignmentY = alignment
	return self
end

function IndicatorsManager:SetDefaultDistanceMargin(margin)
	-- Check if given margin is a number
	if type(margin) ~= "number" then
		outputDebugString( "Tried to change indicator distance default margin, but given parameter isn't a number", 2 )
		return false
	end

	self.defaultDistanceMargin = margin
	return self
end

function IndicatorsManager:SetDefaultDistanceVisible(state)
	-- Check if given state is boolean
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator default distance visibility but given state isn't a boolean", 2 )
		return false
	end

	-- set distance text visible state
	self.defaultDistanceShowing = state
	return self
end

function IndicatorsManager:SetDefaultDistanceBackgroundVisible(state)
	-- Check if given state is boolean
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator default distance background visibility but given state isn't a boolean", 2 )
		return false
	end

	-- set distance text visible state
	self.defaultDistanceBackgroundVisible = state
	return self
end

function IndicatorsManager:SetDefaultDistanceBackgroundColor(color, colG, colB, colA)
	-- Make sure it was either valid color, or 3 valid numbers to make a color
	if color and colG and colB then
		colA = colA or 255
		color = tocolor( color, colG, colB, colA )
	elseif type(color) ~= "number" then
		outputDebugString( "Tried to set indicator default distance background color, but given arguments were invalid." )
		return false
	end

	self.defaultDistanceBackgroundColor = color
	return self
end

-- FONT SETTINGS
function IndicatorsManager:SetDefaultFont(font)
	-- Check if font is valid font name or dx-font element, return false if not
	if type(font) == "string" then
		if not AllowedFonts[font] then
			outputDebugString( "Tried to set invalid indicator default font: "..tostring(font), 2 )
			return false
		end
	elseif not (isElement(font) and (getElementType(font) == "dx-font")) then
		outputDebugString( "Tried to set invalid indicator default font: "..tostring(font), 2 )
		return false
	end

	-- Set font setting
	self.defaultFont = font
	return self
end

function IndicatorsManager:SetDefaultFontScale(scale)
	-- Check if given scale is a number
	if type(scale) ~= "number" then
		outputDebugString( "Tried to change indicator default font scale, but given parameter isn't a number", 2 )
		return false
	end

	-- Set font scale
	self.defaultFontScale = scale
	return self
end

function IndicatorsManager:SetDefaultText(text)
	-- If type of text is number, make it string
	if type(text) == "number" then
		text = tostring(text)
	end

	-- If type of text is neither number nor string give warning and return false
	if type(text) ~= "string" then
		outputDebugString( "Tried to set indicator default text, but given value is neither string nor number: "..tostring(text), 2 )
		return false
	end

	-- Assign text to indicator
	self.defaultIndicatorText = text
	return self
end

function IndicatorsManager:SetDefaultTextColor(color, colG, colB, colA)
	-- Make sure it was either valid color, or 3 valid numbers to make a color
	if color and colG and colB then
		colA = colA or 255
		color = tocolor( color, colG, colB, colA )
	elseif type(color) ~= "number" then
		outputDebugString( "Tried to set indicator default text color, but given arguments were invalid." )
		return false
	end

	self.defaultFontColor = color
	return self
end