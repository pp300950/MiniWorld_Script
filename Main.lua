local result, value = VarLib2:getGlobalVarByName(4, "group1")

if value then
    -- สร้างอาเรย์เพื่อเก็บคำสั่งที่แยกออกมา
    local commands = {}

    -- แยกคำสั่งโดยใช้ "@|&" เป็นตัวแบ่ง
    for cmd in string.gmatch(value, "([^@|&]+)") do
        table.insert(commands, cmd)
    end

    -- ตารางสำหรับเก็บตัวแปรที่ประกาศ
    local variables = {}

    -- ฟังก์ชันช่วยสำหรับประมวลผล array จาก string
    local function parseArray(arrayStr)
        local array = {}
        for val in string.gmatch(arrayStr, "[^,%s]+") do
            local num = tonumber(val)
            if num then
                table.insert(array, num)
            else
                table.insert(array, val) -- กรณีเป็น string
            end
        end
        return array
    end

    -- ฟังก์ชันประมวลผลคำสั่งทีละบรรทัด
    for _, command in ipairs(commands) do
        -- ตรวจสอบคำสั่ง var
        if string.match(command, "^var%s+[%w_]+%s+%a+%s+=%s+.+") then
            local _, _, varName, varType, varValue = string.find(command, "^var%s+([%w_]+)%s+(%a+)%s+=%s+(.+)$")
            if varType == "str" then
                -- กำจัดเครื่องหมายคำพูดถ้ามี
                varValue = string.match(varValue, '^"(.*)"$') or varValue
                variables[varName] = varValue
            elseif varType == "num" then
                local numValue = tonumber(varValue)
                if numValue then
                    variables[varName] = numValue
                else
                    Chat:sendSystemMsg("Invalid number format: " .. varValue, 0)
                end
            elseif varType == "bool" then
                variables[varName] = (varValue == "true")
            elseif varType == "arr" then
                local array = parseArray(varValue)
                if type(array) == "table" then
                    variables[varName] = array
                else
                    Chat:sendSystemMsg("Invalid array format: " .. varValue, 0)
                end
            else
                Chat:sendSystemMsg("Invalid var type: " .. varType, 0)
            end

        -- ตรวจสอบคำสั่ง print
        elseif string.match(command, "^print%(.+%)$") then
            local _, _, expression = string.find(command, "^print%((.+)%)$")
            -- ประมวลผล expression
            local output = string.gsub(expression, '([%w_]+)', function(var)
                return variables[var] or var
            end)
            Chat:sendSystemMsg("value is " .. tostring(output), 0)

        -- ตรวจสอบคำสั่ง if
        elseif string.match(command, "^if%((.+)%)%s*{") then
            local _, _, condition = string.find(command, "^if%((.+)%)%s*{")
            local parsedCondition = string.gsub(condition, '([%w_]+)', function(var)
                return variables[var] or "false"
            end)
            local condResult = parsedCondition == "true"
            if condResult then
                Chat:sendSystemMsg("Condition passed, executing block.", 0)
            end

        -- ตรวจสอบคำสั่ง for
        elseif string.match(command, "^for%s+var%s+([%w_]+)%s+num%s*=%s*([%-?%d]+)%s*;([%w_]+)%s*<%s*(%d+)%s*;([%w_]+)%s*[%+%-]%s*%d+%s*;$") then
            local _, _, varName, startVal, conditionVar, endVal, incDecVar = string.find(command, "^for%s+var%s+([%w_]+)%s+num%s*=%s*([%-?%d]+)%s*;([%w_]+)%s*<%s*(%d+)%s*;([%w_]+)%s*[%+%-]%s*%d+%s*;$")
            local i = tonumber(startVal)
            local endNum = tonumber(endVal)
            if i and endNum then
                while i < endNum do
                    variables[varName] = i
                    Chat:sendSystemMsg("i = " .. tostring(i), 0)
                    i = i + 1
                end
            else
                Chat:sendSystemMsg("Invalid for loop range.", 0)
            end
        else
            Chat:sendSystemMsg("Invalid command: " .. command, 0)
        end
    end
else
    Chat:sendSystemMsg("value is nil", 0)
end
