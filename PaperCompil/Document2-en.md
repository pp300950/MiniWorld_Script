Code Commands Documentation


---

1. var Command

Description:
Creates a new variable with a specified type and initial value.

Syntax:

var variableName type = value

Examples:

var myVar str = "hello"  
var numVar num = 42  
var boolVar bool = true  
var arrVar arr = {1, 2, 3}

Data Types:

str: Stores text or strings.

num: Stores numeric values.

bool: Stores boolean values (true/false).

arr: Stores an array of values.



---

2. print Command

Description:
Displays a message or the value of a variable in the system.

Syntax:

print(expression)

Examples:

print("Hello, World!")  
print(myVar)  
print(2 + 3)

Parameter:

expression: The expression to be printed.



---

3. if Command

Description:
Checks a condition and executes statements if the condition is true.

Syntax:

if(condition) {
    -- statements
}

Example:

if(myVar == "hello") {
    print("Condition is true")
}

Parameter:

condition: The condition to be checked. If true, the statements inside the block are executed.



---

4. for Command

Description:
Loops through a block of code a specified number of times.

Syntax:

for var variableName num = start; conditionVar < end; incDecVar+step;

Example:

for var i num = 1; i < 5; i+1;

Parameters:

variableName: The loop control variable.

start: The initial value of the loop variable.

end: The end condition for the loop.

step: The increment step for each iteration.



---

5. sort Command

Description:
Sorts the values in an array.

Syntax:

sort(arrayName)

Example:

sort(arrVar)

Parameter:

arrayName: The name of the array to be sorted.



---

6. insert Command

Description:
Inserts a value into an array.

Syntax:

insert(arrayName, value)

Example:

insert(arrVar, 4)

Parameters:

arrayName: The name of the array to which the value will be inserted.

value: The value to be inserted into the array.



---

7. remove Command

Description:
Removes a value at a specific index from an array.

Syntax:

remove(arrayName, index)

Example:

remove(arrVar, 2)

Parameters:

arrayName: The name of the array from which the value will be removed.

index: The index of the value to be removed (indexing starts from 0 or 1, depending on system design).



---

8. function Command

Description:
Declares a new function.

Syntax:

function functionName(params) {
    -- statements
}

Example:

-- Declare a function  
function sayHello(name)  
    Chat:sendSystemMsg("Hello, " .. name, 0)  
end  

-- Call the function  
sayHello("Alice")

Parameters:

functionName: The name of the function.

params: The list of parameters that the function accepts.



---

9. function call Command

Description:
Calls a function that has been previously declared.

Syntax:

functionName(args)

Example:

sayHello("Alice")

Parameters:

functionName: The name of the function to be called.

args: The arguments or parameters to be passed to the function.



---

This document provides a comprehensive explanation of all the commands used in the code. It enables users to understand and utilize the code efficiently.

