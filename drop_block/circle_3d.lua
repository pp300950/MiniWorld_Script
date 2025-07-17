-- กำหนด ID ของบล็อกที่คุณต้องการใช้
local BLOCK_ID = 1 -- เปลี่ยนเป็น ID บล็อกที่คุณต้องการ

-- กำหนดจุดศูนย์กลางของทรงกลม
local CENTER_X = 0
local CENTER_Y = 60 -- จุดศูนย์กลางของทรงกลมบนแกน Y
local CENTER_Z = 0

-- กำหนดรัศมีของทรงกลม
local RADIUS = 10

-- ค่าคงที่สำหรับมุม
local PHI_STEP = math.pi / 20 -- ยิ่งน้อย ทรงกลมยิ่งละเอียด
local THETA_STEP = math.pi / 20 -- ยิ่งน้อย ทรงกลมยิ่งละเอียด

-- ฟังก์ชันสำหรับสร้างทรงกลมบล็อกทั้งหมดในคราวเดียว
function CreateInstantSphere()
    print("เริ่มต้นการสร้างทรงกลมบล็อก...")

    -- วนลูปสำหรับมุม Phi (แนวตั้ง)
    for phi = 0, math.pi, PHI_STEP do
        local r_xz = RADIUS * math.sin(phi) -- รัศมีของวงกลมในระนาบ XZ สำหรับความสูงปัจจุบัน

        -- วนลูปสำหรับมุม Theta (แนวนอน)
        for theta = 0, math.pi * 2, THETA_STEP do
            local x = math.floor(CENTER_X + r_xz * math.cos(theta) + 0.5)
            local y = math.floor(CENTER_Y + RADIUS * math.cos(phi) + 0.5)
            local z = math.floor(CENTER_Z + r_xz * math.sin(theta) + 0.5)

            -- วางบล็อกที่พิกัดที่คำนวณได้
            Block:placeBlock(BLOCK_ID, x, y, z, 0, 0)
        end
    end
    print("สร้างทรงกลมบล็อกเสร็จสมบูรณ์แล้ว!")
end

-- เรียกฟังก์ชันเมื่อแผนที่โหลด (แนะนำ)
ScriptSupportEvent:registerEvent([[Map.Load]], CreateInstantSphere)

-- หรือเรียกโดยตรงเพื่อทดสอบ (สำหรับใช้ในคอนโซลของ Editor)
CreateInstantSphere()
