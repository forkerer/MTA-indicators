# MTA-Indicators  
&nbsp;
This resource allows player to create custom indicators, both static positions and indicators following target element are possible to be created using this.
&nbsp;
# Main features:
  - Well optimized code, thousands of indicators can be created without causing lags on most PC's.
  - OOP codebase.
  - The resource is very customizable, there are function to get/set pretty much every variable. 

# File structure:
 - The resource is made of 2 classes:
   - IndicatorsManager class, it's a singleton that's used to manage, update, create and deestroy indicators. It also contains default indicator settings, that are given to each new indicator.
   - Indicator class, each instance of this class is new indicator, each indicator can have it's own settings/look independant of other indicators.
 - Both of those classes main definitions are written in their <classname>.lua file, both of those also have 2 other files containing setters and getters for their properties.
 - This resource doesn't export any functions because custom classes can't be exported properly along with their metatables easily.

&nbsp;
 # Note about updating indicators
 To prevent lagging while using this resource, only ceratin number of indicators will be refreshed every frame, so with larger amount of indicators, you may notice that their distance/visibility doesn't update right away, this only happens if number of indicators is getting abnormaly large, or limits dictating amount of updated indicators per frame is set too low in IndicatorsManager, all those limits are configurable, so user can change it to fit their needs. 
 There are 4 update count limits:
  - Distance update limit for indicators in current dimension.
  - Distance update limit for indicators visible in all dimensions.
  - Position update limit for indicators in current dimension (affect's only dynamic indicators).
  - Position update limit for indicators in all dimensions (affect's only dynamic indicators).
&nbsp;
# Example video of it in action:
[![Click to open video](https://img.youtube.com/vi/AL1Oxu85HPI/0.jpg)](https://www.youtube.com/watch?v=AL1Oxu85HPI)

# Creating indicators
To create new indicators you have to go through IndicatorsManager class, each new indicator has to have unique id/name that will be used to retrieve it for later uses. Indicators can also have their dimension specified, and can be grouped.
Example code showing creation of indicator
```lua
    -- This will create indicator visible in all dimensions, with text: "Example Text" in position 0,0,10
    local indicator = IndicatorsManager():CreateIndicator("exampleIndicator", "Example Text", 0, 0, 10, "all")
    
    -- We can now change the indicator properties using indicator variable, for example we can change image scale
    indicator:SetImageScale(2)
    
    -- All indicator setters return the indicator itself if there weren't any errors, so we can chain those function calls
    indicator:SetText("Example new text"):SetTextScale(2):SetTextPlacement("left")
    
    -- We can change indicator type from static to dynamic, and make it follow element.
    indicator:SetTarget(localPlayer)
    
    -- To destroy the indicator we have to go through IndicatorsManager again
    IndicatorsManager():DestroyIndicatorByName("exampleIndicator")
```

# All functions availible for indicators:
```lua
    Indicator:SetType(newType) --Changes indicator type, allowed ones are "static","dynamic"
    Indicator:SetDimension(dimension) --Changes indicator dimension, dimension has to be either a number, or "all" to make it visible in all dimensions
    Indicator:SetGroup(group) --Assigns indicator to a group, given group has to be a not empty string or a number
    Indicator:SetPosition(x, y, z) --Changes indicator position in world
    Indicator:SetTarget(element) --Changes indicator target element, if indicator was static beforehand, it sets it's type to dynamic
    Indicator:SetTargetOffset(x, y, z) --Changes offset from target element at which indicator will be drawn
    Indicator:SetOnTargetLostBehaviour(behaviour) --Changes how indicator will react to losing target element(because it was destroyed for example), allowed behaviours are "static"-which will turn indicator to static in last target position, and "destroy"-which will destroy indicator once target is lost

-- Image functions
    Indicator:SetImage(image, sizeX, sizeY) --Sets indicator image, given image has to be dxTexture element, sizeX and sizeY arguments aren't required, if they aren't sent sizes will be calculated. Option of sending them is left because it ay be useful in situation of batch image change, where it can be calulated once beforehand to lessen number of function calls.
    Indicator:SetImageScale(scale) --Sets indicator image scale
    Indicator:SetImageColor(color, colG, colB, colA) --Sets image color, it can either be called with single argument that's already a color, or with 3/4 arguments ranging between (0,255) that will be changed to color using tocolor()
    Indicator:SetImageVisible(state) --Changes visibility state of indicator image
    
    Indicator:SetMinDistance(dist) --Set's max distance at which indicator will display on screen
    Indicator:SetMaxDistance(dist) --Set's min distance at which indicator will display on screen
    
--Text functions
    Indicator:SetTextPlacement(placement) --Changes placement of indicator text, it can be "left","right","top","bottom"
    Indicator:SetTextAlignmentX(alignment) --Changes alignment of indicator text horizontally, it only affects indicator if it's text placement is "top" or "bottom", availible alignments are "left","center","right"
    Indicator:SetTextAlignmentY(alignment) --Changes alignment of indicator text vertically, it only affects indicator if it's text placement is "left" or "right", availible alignments are "top","center","bottom"
    Indicator:SetTextMargin(margin) --Sets indicator margin between the text and image.
    Indicator:SetTextVisible(state) --Changes visibility state of indicator text
    Indicator:SetTextBackgroundVisible(state) --Changes state of rectangular background behind indicator text
    Indicator:SetTextBackgroundColor(color, colG, colB, colA) --Changes color of indicator text background, arguments are exactly the same as for SetTextColor
    
--Distance text functions, those work exactly like text ones, but affect only distance label
    Indicator:SetDistancePlacement(placement)
    Indicator:SetDistanceAlignmentX(alignment)
    Indicator:SetDistanceAlignmentY(alignment)
    Indicator:SetDistanceMargin(margin)
    Indicator:SetDistanceVisible(state)
    Indicator:SetDistanceBackgroundVisible(state)
    Indicator:SetDistanceBackgroundColor(color, colG, colB, colA)
    
--Font functions
    Indicator:SetFont(font) --Sets font used by indicator, it has to either be one of default mta fonts as strings, or a dx-font element
    Indicator:SetFontScale(scale) --Sets font scale
    Indicator:SetText(text) --Sets indicator text
    Indicator:SetTextColor(color, colG, colB, colA) --Sets indicator text color
    
--Getters:
    Indicator:GetType()
    Indicator:GetDimension()
    Indicator:GetGroup()
    Indicator:GetPosition()
    Indicator:SetTarget()
    Indicator:GetOnTargetLostBehaviour()
    
    Indicator:GetImage()
    Indicator:GetImageScale()
    Indicator:GetImageColor()
    Indicator:GetImageVisible()
    
    Indicator:GetMinDistance()
    Indicator:GetMaxDistance()
    
    Indicator:GetTextPlacement()
    Indicator:GetTextAlignmentX()
    Indicator:GetTextAlignmentY()
    Indicator:GetTextMargin()
    Indicator:GetTextVisible()
    Indicator:GetTextBackgroundVisible()
    Indicator:GetTextBackgroundColor()
    
    Indicator:GetDistancePlacement()
    Indicator:GetDistanceAlignmentX()
    Indicator:GetDistanceAlignmentY()
    Indicator:GetDistanceMargin()
    Indicator:GetDistanceVisible()
    Indicator:GetDistanceBackgroundVisible()
    Indicator:GetDistanceBackgroundColor()
    
    Indicator:GetFont()
    Indicator:GetFontScale()
    Indicator:GetText()
    Indicator:GetTextColor()
```

# All functions availible for IndicatorsManager:
```lua
    IndicatorsManager:SetActive(state) --Disables/enables IndicatorsManager, while it's disabled all indicator related actions will not work, indicators won't be drawn or refreshed
    IndicatorsManager:SetDistanceUpdateCountLimit(updateType, limit) --Set's max number of indicators whose distance will be updated per frame, allowed types are "dimension" and "all"
    IndicatorsManager:SetPositionUpdateCountLimit(updateType, limit) --Set's max number of dynamic indicators whose position will be updated per frame, allowed types are "dimension" and "all"
    
-- Those functions are used to set indicators default values, their arguments are exactly the same as their Indicator function equvalents
    IndicatorsManager:SetDefaultType(newType)
    IndicatorsManager:SetDefaultDimension(dimension)
    IndicatorsManager:SetDefaultGroup(group)
    IndicatorsManager:SetDefaultPosition(x, y, z)
    IndicatorsManager:SetDefaultOnTargetLostBehaviour(behaviour)
    
    IndicatorsManager:SetDefaultImage(image, sizeX, sizeY)
    IndicatorsManager:SetDefaultImageScale(scale)
    IndicatorsManager:SetDefaultImageColor(color, colG, colB, colA)
    IndicatorsManager:SetDefaultImageVisible(state)
    
    IndicatorsManager:SetDefaultMinDistance(dist)
    IndicatorsManager:SetDefaultMaxDistance(dist)
    
    IndicatorsManager:SetDefaultTextPlacement(placement)
    IndicatorsManager:SetDefaultTextAlignmentX(alignment)
    IndicatorsManager:SetDefaultTextAlignmentY(alignment)
    IndicatorsManager:SetDefaultTextMargin(margin)
    IndicatorsManager:SetDefaultTextVisible(state)
    IndicatorsManager:SetDefaultTextBackgroundVisible(state)
    IndicatorsManager:SetDefaultTextBackgroundColor(color, colG, colB, colA)
    
    IndicatorsManager:SetDefaultDistancePlacement(placement)
    IndicatorsManager:SetDefaultDistanceAlignmentX(alignment)
    IndicatorsManager:SetDefaultDistanceAlignmentY(alignment)
    IndicatorsManager:SetDefaultDistanceMargin(margin)
    IndicatorsManager:SetDefaultDistanceVisible(state)
    IndicatorsManager:SetDefaultDistanceBackgroundVisible(state)
    IndicatorsManager:SetDefaultDistanceBackgroundColor(color, colG, colB, colA)
    
    IndicatorsManager:SetDefaultFont(font)
    IndicatorsManager:SetDefaultFontScale(scale)
    IndicatorsManager:SetDefaultText(text)
    IndicatorsManager:SetDefaultTextColor(color, colG, colB, colA)

--Getters
    IndicatorsManager:GetIndicator(name) --Gets indicator by it's id/name
    IndicatorsManager:GetAllIndicators() --Returns table containing all indicators
    IndicatorsManager:GetIndicatorsInDimension(dimension) --Returns table containing all indicators in given dimension
    IndicatorsManager:GetAllStaticIndicators() --Returns table containing all static indicators
    IndicatorsManager:GetStaticIndicatorsInDimension(dimension) --Returns table containing all static indicators in given dimension
    IndicatorsManager:GetAllDynamicIndicators() --Returns table containing all dynamic indicators
    IndicatorsManager:GetDynamicIndicatorsInDimension(dimension) --Returns table containing all dynamic indicators in given dimension
    IndicatorsManager:GetIndicatorsInGroup(group) --Returns  table containing all indicators in given group
    IndicatorsManager:GetActive() -- Returns boolean representing current activity state of IndicatorsManager
    IndicatorsManager:GetDistanceUpdateCountLimit(updateType) --Gets current limit for distance updates per frame, allowed updateType is "all" or "dimension"
    IndicatorsManager:GetPositionUpdateCountLimit(updateType) --Gets current limit for position updates per frame, allowed updateType is "all" or "dimension"
    
    IndicatorsManager:GetDefaultType()
    IndicatorsManager:GetDefaultDimension()
    IndicatorsManager:GetDefaultGroup()
    IndicatorsManager:GetDefaultPosition()
    IndicatorsManager:GetDefaultOnTargetLostBehaviour()
    
    IndicatorsManager:GetDefaultImage()
    IndicatorsManager:GetDefaultImageScale()
    IndicatorsManager:GetDefaultImageColor()
    IndicatorsManager:GetDefaultImageVisible()
    
    IndicatorsManager:GetDefaultMinDistance()
    IndicatorsManager:GetDefaultMaxDistance()
    
    IndicatorsManager:GetDefaultTextPlacement()
    IndicatorsManager:GetDefaultTextAlignmentX()
    IndicatorsManager:GetDefaultTextAlignmentY()
    IndicatorsManager:GetDefaultTextMargin()
    IndicatorsManager:GetDefaultTextVisible()
    IndicatorsManager:GetDefaultTextBackgroundVisible()
    IndicatorsManager:GetDefaultTextBackgroundColor()
    
    IndicatorsManager:GetDefaultDistancePlacement()
    IndicatorsManager:GetDefaultDistanceAlignmentX()
    IndicatorsManager:GetDefaultDistanceAlignmentY()
    IndicatorsManager:GetDefaultDistanceMargin()
    IndicatorsManager:GetDefaultDistanceVisible()
    IndicatorsManager:GetDefaultDistanceBackgroundVisible()
    IndicatorsManager:GetDefaultDistanceBackgroundColor()
    
    IndicatorsManager:GetDefaultFont()
    IndicatorsManager:GetDefaultFontScale()
    IndicatorsManager:GetDefaultText()
    IndicatorsManager:GetDefaultTextColor()
```

# Example gifs showing possible changes to indicators
>![SetFont](https://media.giphy.com/media/5tw1iGOZltV0pLoiOv/giphy.gif)
>SetFont

>![SetImageScale](https://media.giphy.com/media/L14QoMejC3pcupUo8I/giphy.gif)
>SetImageScale

>![SetTextPlacement](https://media.giphy.com/media/1AHopOnKJ1Z7SsD2js/giphy.gif)
>SetTextPlacement

>![SetPosition](https://media.giphy.com/media/2xPPo5ze9oJSOOthAh/giphy.gif)
>SetPosition

License
----
> ----------------------------------------------------------------------------
> Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
> notice, you can do whatever you want with this stuff. If we
> meet someday, and you think this stuff is worth it, you can
> buy me a beer in return.
 ----------------------------------------------------------------------------


