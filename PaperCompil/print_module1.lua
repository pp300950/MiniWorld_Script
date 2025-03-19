local value = 'var name str = "Phongsakorn"@|&var last_name str = "Phabjansing"@|&print("My name is "+name+last_name)'

if value ~= nil and value ~= "" then
    -- ตารางสำหรับเก็บตัวแปร
    local variables = {}

    -- แยกคำสั่งออกจากกัน
    local commands = {}
    for cmd in string.gmatch(value, "([^@%|&]+)") do
        table.insert(commands, cmd)
    end

    -- ประมวลผลแต่ละคำสั่ง
    for _, command in ipairs(commands) do
        -- ตรวจสอบคำสั่ง var
        if string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$") then
            local varName, varType, varValue = string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$")
            
            -- ตรวจสอบว่าเป็นประเภท `str` และลบเครื่องหมายคำพูดออกจากค่า
            if varType == "str" then
                varValue = string.match(varValue, '^"(.-)"$') or varValue -- กำจัดเครื่องหมายคำพูด
                variables[varName] = varValue
                print("ประกาศตัวแปร: " .. varName .. " = " .. varValue)
            else
                print("ประเภทตัวแปรไม่รองรับ: " .. varType)
            end

        -- ตรวจสอบคำสั่ง print
        elseif string.match(command, "^%s*print%s*%((.-)%)%s*$") then
            local expression = string.match(command, "^%s*print%s*%((.-)%)%s*$")
            
            -- แยกนิพจน์ด้วยเครื่องหมาย +
            local parts = {}
            for part in string.gmatch(expression, '([^%+]+)') do
                part = part:match("^%s*(.-)%s*$") -- ตัดช่องว่างออก
                table.insert(parts, part)
            end

            -- ตรวจสอบสมาชิกแต่ละตัว
            local result = ""
            for _, part in ipairs(parts) do
                if string.match(part, '^".*"$') then
                    -- ถ้ามีเครื่องหมาย "" ให้เพิ่มข้อความลงใน result
                    result = result .. part:sub(2, -2) -- ตัด "" ออก
                else
                    -- ถ้าไม่มี "" ให้ถือว่าเป็นตัวแปร
                    local varValue = variables[part]
                    if varValue then
                        result = result .. varValue
                    else
                        print("ข้อผิดพลาด: ตัวแปร '" .. part .. "' ไม่มีอยู่ในระบบ")
                    end
                end
            end

            print("คำสั่ง print: " .. result)
        else
            print("คำสั่งไม่ถูกต้อง: " .. command)
        end
    end
else
    print("value is nil or empty", 0)
end
