-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

Indicator = {}
Indicator.metatable = {
	__index = Indicator,
}
setmetatable( Indicator, {__call = function(self,...) return self:New(...) end} )


function Indicator:New(name, text, x, y, z)
	local indicator = setmetatable( {}, Indicator.metatable )

	indicator.name = name

	-- Indicator positions in the world
	indicator.x = x
	indicator.y = y
	indicator.z = z
	indicator.dimension = nil

	indicator.visible = true
	indicator.destroyed = false
	indicator.registered = false
	indicator.group = "default"

	-- Indicator distance settings
	indicator.minDist = 0
	indicator.maxDist = 0
	indicator.lastDist = 0
	indicator.isInDistRange = false
	indicator.distPlacement = "bottom"
	indicator.distAlignmentX = "center"
	indicator.distAlignmentY = "center"
	indicator.distWidth = 0
	indicator.distHeight = 0
	indicator.distMargin = 1
	indicator.distVisible = false
	indicator.distText = ""
	indicator.distBackgroundVisible = false
	indicator.distBackgroundColor = nil

	-- Indicator type settings
	indicator.type = nil
	indicator.targetElement = nil
	indicator.targetOffX = 0
	indicator.targetOffY = 0
	indicator.targetOffZ = 0
	indicator.onTargetLostBehaviour = "destroy"

	-- Indicator image settings
	indicator.image = nil
	indicator.imageColor = nil
	indicator.imageSizeX = 1
	indicator.imageSizeY = 1
	indicator.imageScale = 1
	indicator.imageVisible = false

	-- Indicator font settings
	indicator.font = "default"
	indicator.fontSize = 1

	-- Indicator text settings
	indicator.text = text
	indicator.textPlacement = "top"
	indicator.textAlignmentX = "center"
	indicator.textAlignmentY = "center"
	indicator.textWidth = 0
	indicator.textHeight = 0
	indicator.textMargin = 0
	indicator.textColor = nil
	indicator.textVisible = false
	indicator.textBackgroundVisible = false
	indicator.textBackgroundColor = nil

	-- Indicator parameters that are used when it is being drawn on the screen to position elements
	indicator.imageRealHalfX = 0
	indicator.imageRealHalfY = 0
	indicator.imageRealImageSizeX = 0
	indicator.imageRealImageSizeY = 0
	indicator.textOffX = 0
	indicator.textOffY = 0
	indicator.distOffX = 0
	indicator.distOffY = 0
	indicator.screenW, indicator.screenH = guiGetScreenSize()

	if self.text then
		self:RefreshTextSizes()
		self:RefreshDistSizes()
	end

	return indicator
end

function Indicator:Destroy()
	self.destroyed = true
	IndicatorsManager():OnIndicatorDestroy(self)
end

function Indicator:UpdateDistance(cx,cy,cz)
	local oldDist = self.lastDist
	self.lastDist = getDistanceBetweenPoints3D( cx, cy, cz, self.x, self.y, self.z )
	if self.lastDist ~= oldDist then
		self.distText = formatDistance(self.lastDist)
	end
	self.isInDistRange = (self.lastDist >= self.minDist) and (self.lastDist <= self.maxDist)
end

function Indicator:UpdatePosition()
	if isElement( self.targetElement ) then
		local ex,ey,ez = getElementPosition( self.targetElement )
		if ex then
			self.x = ex+self.targetOffX
			self.y = ey+self.targetOffY
			self.z = ez+self.targetOffZ
		end
	else
		if self.onTargetLostBehaviour == "destroy" then
			self:Destroy()
		elseif self.onTargetLostBehaviour == "static" then
			self:SetType("static")
		end
	end
end

-- FUNCTIONS USED TO CALCUATE SIZES AND POSITIONS OF TEXT AND IMAGES
function Indicator:RefreshImageDrawingParameters()
	-- Get scaled image sizes divided by 2, used to position text around image, we start offset from center of image
	self.imageRealImageSizeX = self.imageSizeX*self.imageScale
	self.imageRealImageSizeY = self.imageSizeY*self.imageScale
	self.imageRealHalfX = self.imageRealImageSizeX/2
	self.imageRealHalfY = self.imageRealImageSizeY/2
end

function Indicator:RefreshTextSizes()
	if not self.text then 
		self.textWidth = 0
		self.textHeight = 0
	else
		self.textWidth = dxGetTextWidth( self.text, self.fontSize, self.font )
		self.textHeight = dxGetFontHeight( self.fontSize, self.font )
	end
end

function Indicator:RefreshDistSizes()
	if self.font and self.fontSize and self.distText then
		self.distWidth = GetDistanceWidth( self.fontSize, self.font )
		self.distHeight = dxGetFontHeight( self.fontSize, self.font )
	end
end

function Indicator:RefreshTextPosition()
	-- Offsets used to position text upper left corner
	local offsetX = 0
	local offsetY = 0

	-- If the image isn't visible, the text position defaults to top center
	if not self.imageVisible then
		offsetX = offsetX - self.textWidth/2
		offsetY = offsetY - self.textMargin - self.textHeight
		-- Assign those calculated offsets to indicator
		self.textOffX = offsetX
		self.textOffY = offsetY
		return
	end

	-- Calculations for TOP placement
	if self.textPlacement == "top" then

		-- LEFT ALIGNMENT
		if self.textAlignmentX == "left" then
			-- Move text to left side of image
			offsetX = offsetX - self.imageRealHalfX
			-- Move text up by image half size and margin length, substract textWidth to make it position correctly
			offsetY = offsetY - self.imageRealHalfY - self.textMargin - self.textHeight

		-- CENTER ALIGNMENT
		elseif self.textAlignmentX == "center" then
			-- Move text to the left by half of the text width, that centers text in image
			offsetX = offsetX - self.textWidth/2
			-- Move text up by image half size and margin length, substract textWidth to make it position correctly
			offsetY = offsetY - self.imageRealHalfY - self.textMargin - self.textHeight

		-- RIGHT ALIGNMENT
		elseif self.textAlignmentX == "right" then
			-- Move text by half image size to the right and substract text width to make sure that 
			offsetX = offsetX + self.imageRealHalfX - self.textWidth
			-- Move text up by image half size and margin length, substract textWidth to make it position correctly
			offsetY = offsetY - self.imageRealHalfY - self.textMargin - self.textHeight
		end

	-- Calculations for BOTTOM placement
	elseif self.textPlacement == "bottom" then

		-- LEFT ALIGNMENT
		if self.textAlignmentX == "left" then
			-- Move text to left side of image
			offsetX = offsetX - self.imageRealHalfX
			-- Move text down by image half size and margin length
			offsetY = offsetY + self.imageRealHalfY + self.textMargin

		-- CENTER ALIGNMENT
		elseif self.textAlignmentX == "center" then
			-- Move text to the left by half of the text width, that centers text in image
			offsetX = offsetX - self.textWidth/2
			-- Move text down by image half size and margin length
			offsetY = offsetY + self.imageRealHalfY + self.textMargin

		-- RIGHT ALIGNMENT
		elseif self.textAlignmentX == "right" then
			-- Move text by half image size to the right and substract text width to make sure that 
			offsetX = offsetX + self.imageRealHalfX - self.textWidth
			-- Move text down by image half size and margin length
			offsetY = offsetY + self.imageRealHalfY + self.textMargin
		end

	-- Calculations for LEFT placement
	elseif self.textPlacement == "left" then

		-- TOP ALIGNMENT
		if self.textAlignmentY == "top" then
			-- Move text to the left just enough so it ends margin lenght away from image
			offsetX = offsetX - self.imageRealHalfX - self.textMargin - self.textWidth
			-- Move text up by half image length
			offsetY = offsetY - self.imageRealHalfY

		-- CENTER ALIGNMENT
		elseif self.textAlignmentY == "center" then
			-- Move text to the left just enough so it ends margin lenght away from image
			offsetX = offsetX - self.imageRealHalfX - self.textMargin - self.textWidth
			-- Move text up by half of text height, it center's text on Y axis on image
			offsetY = offsetY - self.textHeight/2

		-- TOP ALIGNMENT
		elseif self.textAlignmentY == "bottom" then
			-- Move text to the left just enough so it ends margin lenght away from image
			offsetX = offsetX - self.imageRealHalfX - self.textMargin - self.textWidth
			-- Move text down by half image length, move up by text height so the bottom of text aligns with bottom of image 
			offsetY = offsetY + self.imageRealHalfY - self.textHeight
		end

	-- Calculations for LEFT placement
	elseif self.textPlacement == "right" then

		-- TOP ALIGNMENT
		if self.textAlignmentY == "top" then
			-- Move text to the right just enough so it starts margin lenght away from image
			offsetX = offsetX + self.imageRealHalfX + self.textMargin
			-- Move text up by half image length
			offsetY = offsetY - self.imageRealHalfY

		-- CENTER ALIGNMENT
		elseif self.textAlignmentY == "center" then
			-- Move text to the right just enough so it starts margin lenght away from image
			offsetX = offsetX + self.imageRealHalfX + self.textMargin
			-- Move text up by half of text height, it center's text on Y axis on image
			offsetY = offsetY - self.textHeight/2

		-- TOP ALIGNMENT
		elseif self.textAlignmentY == "bottom" then
			-- Move text to the right just enough so it starts margin lenght away from image
			offsetX = offsetX + self.imageRealHalfX + self.textMargin
			-- Move text down by half image length, move up by text height so the bottom of text aligns with bottom of image 
			offsetY = offsetY + self.imageRealHalfY - self.textHeight
		end
	end

	-- Assign those calculated offsets to indicator
	self.textOffX = offsetX
	self.textOffY = offsetY
end

function Indicator:RefreshDistTextPosition()
	if not (self.distMargin and self.distHeight and self.textMargin and self.textHeight) then return end
	-- Offsets used to position text upper left corner
	local offsetX = 0
	local offsetY = 0

	-- If the image isn't visible, the dist position defaults to bottom center
	if not self.imageVisible then
		offsetX = offsetX - self.distWidth/2
		offsetY = offsetY + self.distMargin
		-- Assign those calculated offsets to indicator
		self.distOffX = offsetX
		self.distOffY = offsetY
		return
	end

	-- Calculations for TOP placement
	if self.distPlacement == "top" then
		-- LEFT ALIGNMENT
		if self.distAlignmentX == "left" then
			-- Move text to left side of image
			offsetX = offsetX - self.imageRealHalfX
			-- Move text up by image half size and margin length, subtract distHeight to make it position correctly
			offsetY = offsetY - self.imageRealHalfY - self.distMargin - self.distHeight

		-- CENTER ALIGNMENT
		elseif self.distAlignmentX == "center" then
			-- Move text to the left by half of the text width, that centers text in image
			offsetX = offsetX - self.distWidth/2
			-- Move text up by image half size and margin length, subtract distHeight to make it position correctly
			offsetY = offsetY - self.imageRealHalfY - self.distMargin - self.distHeight

		-- RIGHT ALIGNMENT
		elseif self.distAlignmentX == "right" then
			-- Move text by half image size to the right and substract text width to make sure that distance text ends on right side of image
			offsetX = offsetX + self.imageRealHalfX - self.distWidth
			-- Move text up by image half size and margin length, substract distHeight to make it position correctly
			offsetY = offsetY - self.imageRealHalfY - self.distMargin - self.distHeight
		end

		-- If text is also placed on top, move distance up 
		if self.distPlacement == self.textPlacement then
			offsetY = offsetY - self.textHeight - self.textMargin
		end

	-- Calculations for BOTTOM placement
	elseif self.distPlacement == "bottom" then

		-- LEFT ALIGNMENT
		if self.distAlignmentX == "left" then
			-- Move text to left side of image
			offsetX = offsetX - self.imageRealHalfX
			-- Move text down by image half size and margin length
			offsetY = offsetY + self.imageRealHalfY + self.distMargin

		-- CENTER ALIGNMENT
		elseif self.distAlignmentX == "center" then
			-- Move text to the left by half of the text width, that centers text in image
			offsetX = offsetX - self.distWidth/2
			-- Move text down by image half size and margin length
			offsetY = offsetY + self.imageRealHalfY + self.distMargin

		-- RIGHT ALIGNMENT
		elseif self.distAlignmentX == "right" then
			-- Move text by half image size to the right and substract text width to make sure that distance text ends on right side of image
			offsetX = offsetX + self.imageRealHalfX - self.distWidth
			-- Move text down by image half size and margin lengt
			offsetY = offsetY + self.imageRealHalfY + self.distMargin
		end

		-- If text is also placed on bottom, move distance down 
		if self.distPlacement == self.textPlacement then
			offsetY = offsetY + self.textHeight + self.textMargin
		end

	-- Calculations for LEFT placement
	elseif self.distPlacement == "left" then

		-- TOP ALIGNMENT
		if self.distAlignmentY == "top" then
			-- Move text to the left just enough so it ends margin lenght away from image
			offsetX = offsetX - self.imageRealHalfX - self.distMargin - self.distWidth
			-- Move text up by half image length
			offsetY = offsetY - self.imageRealHalfY

		-- CENTER ALIGNMENT
		elseif self.distAlignmentY == "center" then
			-- Move text to the left just enough so it ends margin lenght away from image
			offsetX = offsetX - self.imageRealHalfX - self.distMargin - self.distWidth
			-- Move text up by half of text height, it center's text on Y axis on image
			offsetY = offsetY - self.distHeight/2

		-- BOTTOM ALIGNMENT
		elseif self.distAlignmentY == "bottom" then
			-- Move text to the left just enough so it ends margin lenght away from image
			offsetX = offsetX - self.imageRealHalfX - self.distMargin - self.distWidth
			-- Move text down by half image length, move up by text height so the bottom of text aligns with bottom of image 
			offsetY = offsetY + self.imageRealHalfY - self.distHeight
		end

		-- If text is also placed on left side, move distance to make place for text
		if (self.distPlacement == self.textPlacement) and (self.distAlignmentY == self.textAlignmentY) then
			if self.textAlignmentY ~= "bottom" then
				offsetY = offsetY + self.textHeight - self.distMargin
			else
				offsetY = offsetY - self.textHeight - self.distMargin
			end
		end

	elseif self.distPlacement == "right" then

		-- TOP ALIGNMENT
		if self.distAlignmentY == "top" then
			-- Move text to the right just enough so it starts margin lenght away from image
			offsetX = offsetX + self.imageRealHalfX + self.distMargin
			-- Move text up by half image length
			offsetY = offsetY - self.imageRealHalfY

		-- CENTER ALIGNMENT
		elseif self.distAlignmentY == "center" then
			-- Move text to the right just enough so it starts margin lenght away from image
			offsetX = offsetX + self.imageRealHalfX + self.distMargin
			-- Move text up by half of text height, it center's text on Y axis on image
			offsetY = offsetY - self.distHeight/2

		-- BOTTOM ALIGNMENT
		elseif self.distAlignmentY == "bottom" then
			-- Move text to the right just enough so it starts margin lenght away from image
			offsetX = offsetX + self.imageRealHalfX + self.distMargin
			-- Move text down by half image length, move up by text height so the bottom of text aligns with bottom of image 
			offsetY = offsetY + self.imageRealHalfY - self.distHeight
		end

		-- If text is also placed on right side, move distance to make place for text
		if (self.distPlacement == self.textPlacement) and (self.distAlignmentY == self.textAlignmentY) then
			if self.textAlignmentY ~= "bottom" then
				offsetY = offsetY + self.textHeight - self.distMargin
			else
				offsetY = offsetY - self.textHeight - self.distMargin
			end
		end
	end

	-- Assign those calculated offsets to indicator
	self.distOffX = offsetX
	self.distOffY = offsetY
end

function Indicator:Refresh()
	if self.text then
		self:RefreshTextSizes()
		self:RefreshTextPosition()
	end
	if self.distText then
		self:RefreshDistSizes()
		self:RefreshDistTextPosition()
	end
	return self
end

function Indicator:Draw()
	if not (self.visible and (not self.destroyed)) then return end
	local sx,sy = getScreenFromWorldPosition( self.x, self.y, self.z )
	if sx then
		if self.imageVisible then
			dxDrawImage( sx-self.imageRealHalfX, sy-self.imageRealHalfY, self.imageRealImageSizeX, self.imageRealImageSizeY, self.image, _, _, self.imageColor )
		end
		if self.textVisible then
			if self.textBackgroundVisible then
				dxDrawRectangle( sx+self.textOffX, sy+self.textOffY, self.textWidth, self.textHeight, self.textBackgroundColor )
			end
			dxDrawText( self.text, sx+self.textOffX, sy+self.textOffY, sx+self.textOffX+self.textWidth, sy+self.textOffY+self.textHeight, self.textColor, self.fontSize, self.font, self.textAlignmentX, self.textAlignmentY, _, _, _, _, true, _, _, _ )
		end
		if self.distVisible and self.distText then
			if self.distBackgroundVisible then
				dxDrawRectangle( sx+self.distOffX, sy+self.distOffY, self.distWidth, self.distHeight, self.distBackgroundColor )
			end
			dxDrawText( self.distText, sx+self.distOffX, sy+self.distOffY, sx+self.distOffX+self.distWidth, sy+self.distOffY+self.distHeight, self.textColor, self.fontSize, self.font, self.textAlignmentX, self.textAlignmentY, _, _, _, _, true, _, _, _ )
		end
	end
end