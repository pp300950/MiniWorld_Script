Paper Compiler

Code Documentation

This document explains the code that processes commands in a simple programming language, supporting basic programming features.

Features Supported:

1. Variable Declaration


2. String Concatenation


3. Mathematical Operations


4. if-else Conditional Statements


5. For Loop




---

1. Variable Declaration

Variables can be declared using the var keyword followed by the variable name, type (e.g., str, num, bool, arr), and the value to assign to the variable.

Syntax:

var <name> <type> = <value>

Examples:

var name str = "PangPone"  -- Declares a variable `name` of type string with value "PangPone"
var pi num = 0             -- Declares a variable `pi` of type number with value 0
var isTrue bool = true     -- Declares a variable `isTrue` of type boolean with value true


---

2. String Concatenation

You can concatenate string variables using the + sign to combine strings.

Example:

var name str = "PangPone"
print("Your name is " + name)  -- Output: "Your name is PangPone"


---

3. Mathematical Operations

Basic mathematical operations such as addition (+), subtraction (-), multiplication (*), division (/), and parentheses () to control the order of operations are supported.

Example:

var pi num = 0
pi = (22 / 7) + 1 * 2 - 2
print("pi + 1 = " + pi)  -- Output: "pi + 1 = 4.142857"


---

4. Conditional Statements (if-else)

The code supports conditional checks for values such as numbers, strings, and booleans. If the condition is true, the block inside {} will execute.

Syntax:

if (<condition>) {
    <action>
}
else {
    <alternative_action>
}

Examples:

var num num = 5
if (num > 0) {
    print("Number is positive")  -- Output: "Number is positive"
} else {
    print("Number is not positive")
}

var string str = "hi"
if (string == "hi") {
    print("Greeting received")  -- Output: "Greeting received"
}


---

5. For Loop

A for loop is used to repeat a set of instructions for a certain number of iterations. The index variable starts at the defined value and increments or decrements based on the condition.

Syntax:

for var <index> num = <start_value>; <index> < <end_value>; <index>++ {
    <action>
}

Example:

for var i num = 0; i < 5; i++ {
    print(i)  -- Output: 0, 1, 2, 3, 4
}


---

Supported Commands

1. Variable Declaration:



var <name> <type> = <value>

<name>: Variable name (e.g., name, pi).

<type>: Variable type (e.g., str, num, bool, arr).

<value>: The value assigned to the variable (e.g., "PangPone", 0, true, {1, 2, 3}).


2. Print Command:



print(<expression>)

<expression>: A value to print, such as a variable, number, string concatenation, or mathematical calculation.


3. If Command:



if (<condition>) {
    <action>
}
else {
    <alternative_action>
}

<condition>: The condition to check, such as num > 0, string == "hi", or isTrue == true.


4. For Command:



for var <index> num = <start_value>; <index> < <end_value>; <index>++ {
    <action>
}

<index>: The variable used as the loop counter (e.g., i).

<start_value>: The starting value of the loop (e.g., 0).

<end_value>: The value at which the loop will stop (e.g., 10).

<action>: The command executed in each loop iteration.



---

Example Use Cases

Example 1: Variable Declaration and Printing a Message

var name str = "PangPone"
print("Hello, " + name)  -- Output: "Hello, PangPone"

Example 2: Mathematical Calculation and Output

var pi num = 0
pi = (22 / 7) + 1 * 2 - 2
print("Calculated pi + 1: " + pi)  -- Output: "Calculated pi + 1: 4.142857"

Example 3: Using if-else Conditional Statement

var num num = 5
if (num > 0) {
    print("Number is positive")  -- Output: "Number is positive"
} else {
    print("Number is not positive")
}

Example 4: Using if with String Variable

var string str = "hi"
if (string == "hi") {
    print("Greeting received")  -- Output: "Greeting received"
}

Example 5: Using a For Loop

for var i num = 0; i < 5; i++ {
    print(i)  -- Output: 0, 1, 2, 3, 4
}


---

Limitations

Currently, only basic commands are supported, such as variable declaration, calculations, if-else statements, and for loops. Complex commands like function declaration or more advanced array operations are not yet supported.

Commands with incorrect syntax or those not defined in this documentation will not be processed.



---

Summary

This documentation explains how to use basic commands to write simple programs, including variable declarations, mathematical operations, if-else conditions, and for loops, with supported functions for these features.

