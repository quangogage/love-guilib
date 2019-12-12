-- Get a character of a string at a specific index
local function getChar(str, index)
    return string.sub(str, index, index)
end

-- Return a word given the index position of the starting character
-- (Must have space after it or this will bork)
-- (This could probably be significantly improved)
local function getWord(line, startIndex)
    local word = ""
    local charIndex = startIndex

    while charIndex < #line do
        local char = getChar(line, charIndex)
        if char ~= " " and char ~= ":" and char ~= ";" then
            word = word .. char
        else
            break
        end
        charIndex = charIndex + 1
    end

    return word
end

-- Get an attribute value given the index position of the starting character
function getValueData(line, startIndex, attribute)
    local charIndex = startIndex
    local valueType
    local value
    local currentStr = ""
    local endIndex

    -- Checking for different value types
    if attribute == "background" or attribute == "color" or attribute == "background-color" then
        valueType = "color"
        value = {}
    elseif attribute == "x" or attribute == "y" or attribute == "left" or attribute == "top" then
        valueType = "number"
    end

    -- Getting the value text
    while charIndex < #line do
        local char = getChar(line, charIndex)

        -- Colors
        if valueType == "color" then
            if char ~= "," and char ~= ";" then
                currentStr = currentStr .. char
            elseif char == "," or char == ";" then
                table.insert(value, tonumber(currentStr))
                currentStr = ""

                if char == ";" then
                    endIndex = charIndex
                    break
                end
            end
        end

        -- Numbers
        if valueType == "number" then
            if char ~= ";" then
                currentStr = currentStr .. char
            else
                value = tonumber(currentStr)
                endIndex = charIndex
                break
            end
        end

        charIndex = charIndex + 1
    end
    return {value = value, endIndex = endIndex}
end

-- Return all classes starting at specified index
local function getClassListData(line, startIndex)
    local classes = {}
    local currentClass = ""
    local charIndex = startIndex
    local endIndex

    while charIndex < #line do
        local char = getChar(line, charIndex)

        if char ~= " " and char ~= "{" and char ~= "." then
            currentClass = currentClass .. char
        elseif char == " " then
            table.insert(classes, currentClass)
            currentClass = ""
        elseif char == "{" then
            endIndex = charIndex
            break
        end

        charIndex = charIndex + 1
    end

    return {
        classes = classes,
        endIndex = endIndex
    }
end

local function getDataFromStyleSheet(fileDir)
    local lines = love.filesystem.read(fileDir)
    local styleData = {}
    local currentElement
    local charIndex = 1
    local state = "storing classes"
    local subState = "finding attribute"
    local tempHierarchy = {}
    local currentAttribute

    while charIndex <= #lines do
        local char = getChar(lines, charIndex)

        -- Storing classes
        if state == "storing classes" then
            if char == "." then -- Class names have started
                local classListData = getClassListData(lines, charIndex + 1)
                table.insert(
                    styleData,
                    {
                        classes = classListData.classes,
                        styles = {}
                    }
                )

                -- Move the iterator to the end of the class names
                charIndex = classListData.endIndex
                char = getChar(lines, charIndex)

                state = "storing style data"
            end
        end

        -- Storing styles
        if state == "storing style data" then
            local currentStyleData = styleData[#styleData]
            local currentAttribute
            if #currentStyleData.styles ~= 0 then
                currentStylePair = currentStyleData.styles[#currentStyleData.styles]
            end

            -- If it's not the end of the list of attributes
            if char ~= "}" then
                -- Finding an attribute
                if subState == "finding attribute" then
                    -- Check if the current char is a letter
                    if char:match("%w") and char ~= "{" and char ~= "}" then
                        local attribute = getWord(lines, charIndex)
                        table.insert(currentStyleData.styles, {attribute = attribute})
                        subState = "finding value"

                        charIndex = charIndex + #attribute
                        char = getChar(lines, charIndex)
                    end
                end

                -- Finding the value for an attribute
                if subState == "finding value" then
                    if char:match("%w") and char ~= ":" and char ~= ";" and char ~= " " then
                        local valueData = getValueData(lines, charIndex, currentStylePair.attribute)

                        -- Store this value
                        currentStylePair.value = valueData.value

                        -- Start finding the next attribute
                        subState = "finding attribute"
                        charIndex = valueData.endIndex
                        char = getChar(lines, charIndex)
                    end
                end
            else
                state = "storing classes"
            end
        end
        charIndex = charIndex + 1
    end

    return styleData
end

return getDataFromStyleSheet
