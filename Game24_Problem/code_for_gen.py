import itertools

#เช็คตรวจว่าตัวเลข 4 ตัวจะทำเป้น 24ไหม
def is_solvable(nums):
    ops = ['+', '-', '*', '/']
    for num_perm in itertools.permutations(nums):
        for op_perm in itertools.product(ops, repeat=3):
            exprs = [
                f"(({num_perm[0]}{op_perm[0]}{num_perm[1]}){op_perm[1]}{num_perm[2]}){op_perm[2]}{num_perm[3]}",
                f"({num_perm[0]}{op_perm[0]}({num_perm[1]}{op_perm[1]}{num_perm[2]})){op_perm[2]}{num_perm[3]}",
                f"{num_perm[0]}{op_perm[0]}(({num_perm[1]}{op_perm[1]}{num_perm[2]}){op_perm[2]}{num_perm[3]})",
                f"{num_perm[0]}{op_perm[0]}({num_perm[1]}{op_perm[1]}({num_perm[2]}{op_perm[2]}{num_perm[3]}))"
            ]
            for expr in exprs:
                try:
                    if abs(eval(expr) - 24) < 1e-6:
                        return True
                except ZeroDivisionError:
                    continue
    return False

#สร้างลิสโจท
result = []
for nums in itertools.combinations_with_replacement(range(1, 10), 4):
    if is_solvable(nums):
        result.append(f'    "{"" .join(map(str, nums))}",')  # ต่อเลข + ใส่ ""

if result:
    result[-1] = result[-1].rstrip(',')

output = "{\n" + "\n".join(result) + "\n}"
with open("game24_dataset.txt", "w", encoding="utf-8") as f:
    f.write(output)

print(f"ได้game24_dataset.txt แล้ว ({len(result)} ชุด)")
