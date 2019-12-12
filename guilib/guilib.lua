local display = require("guilib/elements/display")
local gui = {}

-- [[ Public Functions ]] --
-- Create a new display
function gui.newDisplay(markup, styleSheet, displayOptions)
    local freshDisplay =
        display:new(
        {
            markup = markup,
            styleSheet = styleSheet,
            displayOptions = displayOptions
        }
    )
    return freshDisplay
end

return gui
