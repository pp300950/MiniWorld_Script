
1. คำสั่ง var

คำอธิบาย:
สร้างตัวแปรใหม่พร้อมกำหนดชนิดและค่าเริ่มต้น
รูปแบบ:

var variableName type = value

ตัวอย่าง:
var myVar str = "hello"
var numVar num = 42
var boolVar bool = true
var arrVar arr = {1, 2, 3}

str: เก็บข้อความ

num: เก็บตัวเลข

bool: เก็บค่าจริง/เท็จ (true/false)

arr: เก็บอาเรย์



---

2. คำสั่ง print

คำอธิบาย:
ใช้เพื่อแสดงข้อความหรือค่าตัวแปรในระบบ
รูปแบบ:

print(expression)

ตัวอย่าง:

print("Hello, World!")
print(myVar)
print(2 + 3)

expression: นิพจน์ที่ต้องการพิมพ์



---

3. คำสั่ง if

คำอธิบาย:
ตรวจสอบเงื่อนไข และดำเนินการเมื่อเงื่อนไขเป็นจริง
รูปแบบ:

if(condition) {
    -- statements
}

ตัวอย่าง:

if(myVar == "hello") {
    print("Condition is true")
}


---

4. คำสั่ง for

คำอธิบาย:
วนลูปตามเงื่อนไขที่กำหนด
รูปแบบ:

for var variableName num = start; conditionVar < end; incDecVar+step;

ตัวอย่าง:

for var i num = 1; i < 5; i+1;


---

5. คำสั่ง sort

คำอธิบาย:
เรียงลำดับค่าในอาเรย์
รูปแบบ:

sort(arrayName)

ตัวอย่าง:

sort(arrVar)


---

6. คำสั่ง insert

คำอธิบาย:
แทรกค่าลงในอาเรย์
รูปแบบ:

insert(arrayName, value)

ตัวอย่าง:

insert(arrVar, 4)


---

7. คำสั่ง remove

คำอธิบาย:
ลบค่าที่ตำแหน่งที่กำหนดในอาเรย์
รูปแบบ:

remove(arrayName, index)

ตัวอย่าง:

remove(arrVar, 2)


---

8. คำสั่ง function

คำอธิบาย:
ประกาศฟังก์ชันใหม่
รูปแบบ:

function functionName(params) {
    -- statements
}

ตัวอย่าง:

-- ประกาศฟังก์ชัน
function sayHello(name)
    Chat:sendSystemMsg("Hello, " .. name, 0)
end

-- เรียกใช้ฟังก์ชัน
sayHello("Alice")


---

9. คำสั่ง function call

คำอธิบาย:
เรียกใช้ฟังก์ชัน
รูปแบบ:

functionName(args)

ตัวอย่าง:

sayHello("Alice")


---



เอกสารนี้อธิบายคำสั่งทั้งหมดในโค้ดที่กำหนด ช่วยให้ผู้ใช้งานสามารถเข้าใจและใช้งานโค้ดได้เเบบเต็มที่

