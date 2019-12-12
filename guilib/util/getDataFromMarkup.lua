-- Get a character of a string at a specific index
local function getChar(str, index)
    return string.sub(str, index, index)
end

-- Debugging
local function errorPrintLengthy(lines, charIndex)
    local string = ""
    local addChar = function(char)
        string = string .. char
    end
    for i = -10, 10 do
        if i == -1 or i == 1 then
            addChar(" ")
        end
        addChar(getChar(lines, charIndex + i))
    end
    error(string)
end

-- Split a string
local function splitString(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function getClasses(lines, startIndex)
    local str = ""
    for charIndex = startIndex + 1, #lines do
        local char = getChar(lines, charIndex)
        if char ~= ">" then
            str = str .. char
        else
            return splitString(str)
        end
    end
end

local function getDataFromMarkup(fileDir)
    local lines = love.filesystem.read(fileDir)
    local elementData = {}
    local wrappingElements = {{classes = {"body"}, children = {}}}
    local charIndex = 1

    while charIndex <= #lines do
        local char = getChar(lines, charIndex)
        local nextChar = ""

        -- Only set newChar if it isn't the end of the file
        if charIndex ~= #lines then
            nextChar = getChar(lines, charIndex + 1)
        end

        -- Check for a new element
        if char == "<" and nextChar ~= "/" then
            local classes = getClasses(lines, charIndex)
            local element = {classes = classes, children = {}}

            -- Add element data
            table.insert(elementData, element)

            -- Set parent element
            if #wrappingElements ~= 0 then
                local wrappingElement = wrappingElements[#wrappingElements]
                element.parent = wrappingElement
                table.insert(wrappingElement.children, element)
            end

            -- Set this element as a wrapping element
            table.insert(wrappingElements, element)
        end

        -- Check for end of element
        if char == "<" and nextChar == "/" then
            -- Close the last opened wrapping element
            table.remove(wrappingElements, #wrappingElements)
        end

        charIndex = charIndex + 1
    end
    return elementData
end

return getDataFromMarkup
