-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

-- INDICATOR TYPE FUNCTIONS
function Indicator:GetType()
	return self.type
end

function Indicator:GetDimension()
	return self.dimension
end

function Indicator:GetGroup()
	return self.group
end

function Indicator:GetPosition()
	return self.x,self.y,self.z
end

function Indicator:SetTarget()
	return self.targetElement
end

function Indicator:GetOnTargetLostBehaviour()
	return self.onTargetLostBehaviour
end

-- INDICATOR IMAGE FUNCTIONS
function Indicator:GetImage()
	return self.image,self.imageSizeX,self.imageSizeY
end

function Indicator:GetImageScale()
	return self.imageScale
end

function Indicator:GetImageColor()
	return self.imageColor
end

function Indicator:GetImageVisible()
	return self.imageVisible
end

-- DISTANCE SETTINGS
function Indicator:GetMinDistance()
	return self.minDist
end

function Indicator:GetMaxDistance()
	return self.maxDist
end

-- TEXT SETTINGS
function Indicator:GetTextPlacement()
	return self.textPlacement
end

function Indicator:GetTextAlignmentX()
	return self.textAlignmentX
end

function Indicator:GetTextAlignmentY()
	return self.textAlignmentY
end

function Indicator:GetTextMargin()
	return self.textMargin
end

function Indicator:GetTextVisible()
	return self.textVisible
end

function Indicator:GetTextBackgroundVisible()
	return self.textBackgroundVisible
end

function Indicator:GetTextBackgroundColor()
	return self.textBackgroundColor
end

-- DISTANCE TEXT SETTINGS
function Indicator:GetDistancePlacement()
	return self.distPlacement
end

function Indicator:GetDistanceAlignmentX()
	return self.distAlignmentX
end

function Indicator:GetDistanceAlignmentY()
	return self.distAlignmentY
end

function Indicator:GetDistanceMargin()
	return self.distMargin
end

function Indicator:GetDistanceVisible()
	return self.distVisible
end

function Indicator:GetDistanceBackgroundVisible()
	return self.distBackgroundVisible
end

function Indicator:GetDistanceBackgroundColor()
	return self.distBackgroundColor
end

-- FONT SETTINGS
function Indicator:GetFont()
	return self.font
end

function Indicator:GetFontScale()
	return self.fontSize
end

function Indicator:GetText()
	return self.text
end

function Indicator:GetTextColor()
	return self.textColor
end