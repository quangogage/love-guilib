local defaultElementStyles = require("guilib/defaultElementStyles")
local getDataFromMarkup = require("guilib/util/getDataFromMarkup")
local getDataFromStyleSheet = require("guilib/util/getDataFromStyleSheet")
local display = {}

-- [[ Public Functions ]] --
-- Create a new display
function display:new(options)
    local obj = {
        x = options.displayOptions.x,
        y = options.displayOptions.y,
        width = options.displayOptions.width,
        height = options.displayOptions.height,
        markup = options.markup,
        styleSheet = options.styleSheet,
        elements = {}
    }
    setmetatable(obj, self)
    self.__index = self

    -- Read files
    obj:getElements()
    obj:applyStyles()

    return obj
end

-- Update the display
function display:update(dt)
end

-- Draw the display
function display:draw()
end

-- [[ Private Functions ]] --
-- Get the element data
function display:getElements()
    self.elements = getDataFromMarkup(self.markup)
end
-- Get and apply styling
function display:applyStyles()
    -- Get the styles from the stylesheet
    self.styles = getDataFromStyleSheet(self.styleSheet)

    -- Apply them to elements
    for styleIndex, stylePair in ipairs(self.styles) do
        for elementIndex, element in ipairs(self.elements) do
            -- Apply default styles
            if element.styles == nil then
                element.styles = defaultElementStyles
            end

            -- Apply any stylesheet styles to the element
        end
    end
end

return display
