local result, value = VarLib2:getGlobalVarByName(4, "str1")

if value then
    -- สร้างอาเรย์เพื่อเก็บคำสั่งที่แยกออกมา
    local commands = {}

    -- แยกคำสั่งโดยใช้ "@|&" เป็นตัวแบ่ง
    for cmd in string.gmatch(value, "([^@|&]+)") do
        table.insert(commands, cmd)
    end

    -- ตารางสำหรับเก็บตัวแปรที่ประกาศ
    local variables = {}

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
                variables[varName] = tonumber(varValue)
            elseif varType == "bool" then
                variables[varName] = (varValue == "true")
            elseif varType == "arr" then
                local array = load("return " .. varValue)()
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
            -- ประมวลผล expression ถ้ามีการเชื่อมตัวแปรหรือคำนวณ
            local result = load("return " .. expression)()
            Chat:sendSystemMsg("value is " .. tostring(result), 0)

        -- ตรวจสอบคำสั่ง if
        elseif string.match(command, "^if%((.+)%)%s*{") then
            local _, _, condition = string.find(command, "^if%((.+)%)%s*{")
            -- ประมวลผลเงื่อนไข
            local condResult = load("return " .. condition)()
            if condResult then
                -- ประมวลผลคำสั่งภายในบล็อก if
                Chat:sendSystemMsg("Condition passed, executing block.", 0)
            end

        -- ตรวจสอบคำสั่ง for
        elseif string.match(command, "^for%s+var%s+([%w_]+)%s+num%s*=%s*([%-?%d]+)%s*;([%w_]+)%s*<%s*(%d+)%s*;([%w_]+)%s*[%+%-]%s*%d+%s*;$") then
            local _, _, varName, startVal, conditionVar, endVal, incDecVar = string.find(command, "^for%s+var%s+([%w_]+)%s+num%s*=%s*([%-?%d]+)%s*;([%w_]+)%s*<%s*(%d+)%s*;([%w_]+)%s*[%+%-]%s*%d+%s*;$")
            local i = tonumber(startVal)
            local endNum = tonumber(endVal)
            while i < endNum do
                variables[varName] = i
                Chat:sendSystemMsg("i = " .. tostring(i), 0)
                i = i + 1
            end
        else
            Chat:sendSystemMsg("Invalid command: " .. command, 0)
        end
    end
else
    Chat:sendSystemMsg("value is nil", 0)
end
