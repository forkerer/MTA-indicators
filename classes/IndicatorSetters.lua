-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

-- INDICATOR TYPE FUNCTIONS
function Indicator:SetType(newType)
	-- Check if type is allowed
	if not AllowedTypes[newType] then
		outputDebugString( "Tried to give indicator unknown type: "..tostring(newType), 2 )
		return false
	end

	-- Check if type is different from current one
	if newType == self.type then return end

	-- Save old type, used ro refresh cache in Indicators Manager
	local oldType = self.type
	self.type = newType
	if self.registered then
		IndicatorsManager():OnIndicatorTypeChange(self, oldType)
	end
	return self
end

function Indicator:SetDimension(dimension)
	-- Check if dimension is allowed
	if type(dimension) == "string" then
		if dimension ~= "all" then
			outputDebugString( "Tried to give indicator unknown dimension: "..tostring(dimension), 2 )
			return false
		end
	elseif type(dimension) ~= "number" then
		outputDebugString( "Tried to give indicator unknown dimension: "..tostring(dimension), 2 )
		return false	
	end

	-- Check if type is different from current one
	if dimension == self.dimension then return end

	-- Save old type, used ro refresh cache in Indicators Manager
	local oldDim = self.dimension
	self.dimension = dimension
	if self.registered then
		IndicatorsManager():OnIndicatorDimensionChange(self, oldDim)
	end
	return self
end

function Indicator:SetGroup(group)
	-- If type of group is number, make it string
	if type(group) == "number" then
		group = tostring(group)
	end

	-- If type of text is neither number nor string give warning and return false
	if type(group) ~= "string" then
		outputDebugString( "Tried to set indicator group, but given value is neither string nor number: "..tostring(group), 2 )
		return false
	end

	if group == "" then
		outputDebugString( "Tried to set indicator group, but given value is an empty string: "..tostring(group), 2 )
		return false
	end

	-- Check if group is different from current one
	if group == self.group then return end
	
	local oldGroup = self.group
	-- Assign group to indicator
	self.group = group

	-- Refresh indicator group in manager
	if self.registered then
		IndicatorsManager():OnIndicatorGroupChange(self, oldGroup)
	end
	return self
end

function Indicator:SetPosition(x, y, z)
	-- Check if all arguments are given
	if not (x and y and z) then
		outputDebugString( "Tried to set position in indicator, but some arguments are missing", 2 )
		return false
	end

	-- Set those arguments as indicator positions
	self.x = x
	self.y = y
	self.z = z
	return self
end

function Indicator:SetTarget(element)
	if not isElement(element) then
		outputDebugString( "Tried to set indicator target, but given target isn't an element", 2 )
		return false
	end
	if self.type == "static" then
		self:SetType("dynamic")
	end

	self.targetElement = element
	self:UpdatePosition()
	return self
end

function Indicator:SetTargetOffset(x, y, z)
	if not (x and y and z) then
		outputDebugString( "Tried to set target offsets in indicator, some argument missing", 2 )
		return false
	end
	self.targetOffX = x
	self.targetOffY = y
	self.targetOffZ = z
	--self:UpdatePosition()
	return self
end

function Indicator:SetOnTargetLostBehaviour(behaviour)
	if not AllowedLostTargetBehaviours[behaviour] then
		outputDebugString( "Tried to change indicator on target lost behaviour, but given behaviour isn't correct: "..tostring(behaviour), 2 )
		return false
	end
	self.onTargetLostBehaviour = behaviour
	return self
end

-- INDICATOR IMAGE FUNCTIONS
function Indicator:SetImage(image, sizeX, sizeY)
	-- Chech if image is element
	if not isElement(image) then
		outputDebugString( "Tried to change indicator image, but it isn't an element", 2 )
		return false
	end

	-- Set image
	self.image = image

	-- Update cached image size with given arguments, or calculate it if it isn't given
	if sizeX then
		self.imageSizeX = sizeX
		self.imageSizeY = sizeY
	else
		self.imageSizeX,self.imageSizeY = dxGetMaterialSize(self.image)
	end

	-- Refresh image positions and scales, used to calculate image drawing point
	self:RefreshImageDrawingParameters()

	-- Refresh text positions
	if self.text and self.textVisible then
		self:RefreshTextPosition()
	end
	if self.distText and self.distVisible then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetImageScale(scale)
	if type(scale) ~= "number" then
		outputDebugString( "Tried to change indicator image scale, but given argument isn't a number", 2 )
		return false
	end

	-- Change image scale
	self.imageScale = scale

	-- Refresh image positions and scales, used to calculate image drawing point
	self:RefreshImageDrawingParameters()

	-- Refresh text positions
	if self.text and self.textVisible then
		self:RefreshTextPosition()
	end
	if self.distText and self.distVisible then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetImageColor(color, colG, colB, colA)
	-- Make sure it was either valid color, or 3 valid numbers to make a color
	if color and colG and colB then
		colA = colA or 255
		color = tocolor( color, colG, colB, colA )
	elseif type(color) ~= "number" then
		outputDebugString( "Tried to set indicator image color, but given arguments were invalid.", 2 )
		return false
	end

	self.imageColor = color
	return self
end

function Indicator:SetImageVisible(state)
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator image visibility but given state isn't a boolean", 2 )
		return false
	end

	self.imageVisible = state

	-- Refresh text positions
	if self.text and self.textVisible then
		self:RefreshTextPosition()
	end
	if self.distText and self.distVisible then
		self:RefreshDistTextPosition()
	end

	return self
end

-- DISTANCE SETTINGS
function Indicator:SetMinDistance(dist)
	-- Change indicator minimum show distance
	self.minDist = dist
	return self
end

function Indicator:SetMaxDistance(dist)
	-- Change indicator minimum show distance
	self.maxDist = dist
	return self
end

-- TEXT SETTINGS
function Indicator:SetTextPlacement(placement)
	-- Check if placement is allowed
	if not AllowedPlacements[placement] then
		outputDebugString( "Tried to give indicator text unknown placement: "..tostring(placement), 2 )
		return false
	end

	self.textPlacement = placement

	-- Refresh text positions
	if self.text and self.textVisible then
		self:RefreshTextPosition()
	end

	-- Refresh distance placement if it's visible and it's placement is same as text one
	if self.distVisible and self.distText and (self.textPlacement == self.distPlacement) then
		self:RefreshDistTextPosition()
	end

	return self
end

function Indicator:SetTextAlignementX(alignment)
	-- Check if alignment is allowed
	if not AllowedAlignmentX[alignment] then
		outputDebugString( "Tried to give indicator text unknown alignmentX: "..tostring(alignment), 2 )
		return false
	end

	self.textAlignmentX = alignment
	-- Refresh text positions
	if self.text and self.textVisible then
		self:RefreshTextPosition()
	end
	return self
end

function Indicator:SetTextAlignementY(alignment)
	-- Check if alignment is allowed
	if not AllowedAlignmentY[alignment] then
		outputDebugString( "Tried to give indicator text unknown alignmentY: "..tostring(alignment), 2 )
		return false
	end

	self.textAlignmentY = alignment
	-- Refresh text positions
	if self.text and self.textVisible then
		self:RefreshTextPosition()
	end

	if self.distVisible and self.distText and (self.textPlacement == self.distPlacement) and (self.textAlignmentY == self.distAlignmentY ) then
		self:RefreshDistTextPosition()
	end

	return self
end

function Indicator:SetTextMargin(margin)
	-- Check if given margin is a number
	if type(margin) ~= "number" then
		outputDebugString( "Tried to change indicator margin, but given parameter isn't a number", 2 )
		return false
	end

	-- Refresh text positions
	self.textMargin = margin
	if self.text and self.textVisible then
		self:RefreshTextPosition()
	end

	-- Refresh distance text position if it's showing and it's placement is same as text one
	if self.distVisible and self.distText and (self.textPlacement == self.distPlacement) then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetTextVisible(state)
	-- Check if given state is boolean
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator text visibility but given state isn't a boolean", 2 )
		return false
	end

	-- set text visible state
	self.textVisible = state

	if self.textVisible and self.text then
		self:RefreshTextSizes()
		self:RefreshTextPosition()
	end

	-- Refresh distance if it's placement is same as tet
	if self.distVisible and self.distText and (self.textPlacement == self.distPlacement) then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetTextBackgroundVisible(state)
	-- Check if given state is boolean
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator text background visibility but given state isn't a boolean", 2 )
		return false
	end

	-- set distance text visible state
	self.textBackgroundVisible = state

	-- Refresh distance if it's placement is same as tet
	if self.textBackgroundVisible and (not self.textBackgroundColor) then
		self:SetDistanceBackgroundColor(255,255,255,100)
	end
	return self
end

function Indicator:SetTextBackgroundColor(color, colG, colB, colA)
	-- Make sure it was either valid color, or 3 valid numbers to make a color
	if color and colG and colB then
		colA = colA or 255
		color = tocolor( color, colG, colB, colA )
	elseif type(color) ~= "number" then
		outputDebugString( "Tried to set indicator text background color, but given arguments were invalid." )
		return false
	end

	self.textBackgroundColor = color
	return self
end

-- DISTANCE TEXT SETTINGS
function Indicator:SetDistancePlacement(placement)
	-- Check if placement is allowed
	if not AllowedPlacements[placement] then
		outputDebugString( "Tried to give indicator distance text unknown placement: "..tostring(placement), 2 )
		return false
	end

	self.distPlacement = placement

	-- Refresh distance text positions
	if self.distVisible and self.distText then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetDistanceAlignmentX(alignment)
	-- Check if alignment is allowed
	if not AllowedAlignmentX[alignment] then
		outputDebugString( "Tried to give indicator distance unknown alignmentX: "..tostring(alignment), 2 )
		return false
	end

	self.distAlignmentX = alignment

	-- Refresh distance text positions
	if self.distVisible and self.distText then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetDistanceAlignmentY(alignment)
	-- Check if alignment is allowed
	if not AllowedAlignmentY[alignment] then
		outputDebugString( "Tried to give indicator distance unknown alignmentY: "..tostring(alignment), 2 )
		return false
	end

	self.distAlignmentY = alignment
	
	-- Refresh distance text positions
	if self.distVisible and self.distText then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetDistanceMargin(margin)
	-- Check if given margin is a number
	if type(margin) ~= "number" then
		outputDebugString( "Tried to change indicator distance margin, but given parameter isn't a number", 2 )
		return false
	end

	self.distMargin = margin

	-- Refresh distance text positions
	if self.distVisible and self.distText then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetDistanceVisible(state)
	-- Check if given state is boolean
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator distance visibility but given state isn't a boolean", 2 )
		return false
	end

	-- set distance text visible state
	self.distVisible = state

	-- Refresh distance if it's placement is same as tet
	if self.distVisible and self.distText then
		self:RefreshDistSizes()
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetDistanceBackgroundVisible(state)
	-- Check if given state is boolean
	if type(state) ~= "boolean" then
		outputDebugString( "Tried to change indicator distance background visibility but given state isn't a boolean", 2 )
		return false
	end

	-- set distance text visible state
	self.distBackgroundVisible = state

	-- Refresh distance if it's placement is same as tet
	if self.distBackgroundVisible and (not self.distBackgroundColor) then
		self:SetDistanceBackgroundColor(255,255,255,100)
	end
	return self
end

function Indicator:SetDistanceBackgroundColor(color, colG, colB, colA)
	-- Make sure it was either valid color, or 3 valid numbers to make a color
	if color and colG and colB then
		colA = colA or 255
		color = tocolor( color, colG, colB, colA )
	elseif type(color) ~= "number" then
		outputDebugString( "Tried to set indicator distance background color, but given arguments were invalid." )
		return false
	end

	self.distBackgroundColor = color
	return self
end

-- FONT SETTINGS
function Indicator:SetFont(font)
	-- Check if font is valid font name or dx-font element, return false if not
	if type(font) == "string" then
		if not AllowedFonts[font] then
			outputDebugString( "Tried to set invalid indicator font: "..tostring(font), 2 )
			return false
		end
	elseif not (isElement(font) and (getElementType(font) == "dx-font")) then
		outputDebugString( "Tried to set invalid indicator font: "..tostring(font), 2 )
		return false
	end

	-- Set font setting
	self.font = font

	-- Refresh font sizes
	if self.text then
		self:RefreshTextSizes()
	end
	self:RefreshDistSizes()

	-- If indicator text is set, and visible, refresh positions. Font may have different size than last one
	if self.text and self.textVisible then
		self:RefreshTextPosition()
	end

	-- If distance is visible, refresh positions. Font may have different size than last one
	if self.distVisible and self.distText then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetFontScale(scale)
	-- Check if given scale is a number
	if type(scale) ~= "number" then
		outputDebugString( "Tried to change indicator font scale, but given parameter isn't a number", 2 )
		return false
	end

	-- Set font scale
	self.fontSize = scale

	-- Refresh font sizes
	if self.text then
		self:RefreshTextSizes()
	end
	self:RefreshDistSizes()

	-- If indicator text is set, and visible, refresh positions. Font may have different size than last one
	if self.text and self.textVisible then
		self:RefreshTextPosition()
	end

	-- If distance is visible, refresh positions. Font may have different size than last one
	if self.distText and self.distVisible then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetText(text)
	-- If type of text is number, make it string
	if type(text) == "number" then
		text = tostring(text)
	end

	-- If type of text is neither number nor string give warning and return false
	if type(text) ~= "string" then
		outputDebugString( "Tried to set indicator text, but given value is neither string nor number: "..tostring(text), 2 )
		return false
	end

	-- Assign text to indicator
	self.text = text

	-- Refresh text size calculations and position
	self:RefreshTextSizes()
	self:RefreshTextPosition()
	if self.distText and self.distVisible then
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:SetTextColor(color, colG, colB, colA)
	-- Make sure it was either valid color, or 3 valid numbers to make a color
	if color and colG and colB then
		colA = colA or 255
		color = tocolor( color, colG, colB, colA )
	elseif type(color) ~= "number" then
		outputDebugString( "Tried to set indicator text color, but given arguments were invalid." )
		return false
	end

	self.textColor = color
	return self
end