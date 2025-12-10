<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform Input variable data types and type constraints</h1></b>
</p>

We will explore data type and type constraints in Terraform.

I have already covered the different types of variables in Terraform:

1] Input

2] Locals

3] Output

Input variables can hold values in various data types. First, we will explore the different data types, then we will examine type constraints.

There are two categories of data types:
1. <b>Primitive</b>
2. <b>Complex</b>

The following data types fall under the primitive category:
1) <b>Number</b>
2) <b>String</b>
3) <b>Boolean</b>

<b>Number</b>

In this data type, the value is a number.
Example: a = 10

variable "instance_count" {
  type = number
  default = 2
}

<b>String</b>

In this data type, the value should be enclosed in double quotes.
Example: name = “terraform”

variable "environment" {
    type = string
    default = "Development"
}

<b>Boolean</b>

In this data type, the value is either true or false.
Example: versioning_enabled = true

variable "public_ip" {
    type = bool
    default = true
}

The following data types fall under complex category.
1) <b>List</b>
2) <b>Set</b>
3) <b>Tuple</b>
4) <b>Map</b>
5) <b>Object</b>

<b>List</b>

In this data type, the value should be enclosed in square brackets `[]`, with multiple values separated by commas. All elements in the list must be of the same data type. For example, if specified as `list(string)`, all elements must be strings.

<b>Important notes</b>
* Elements are ordered and can be retrieved using an index.
* Duplicates are allowed.

Example: [“AWS”, “Terraform”, “Kubernetes”]

variable "az" {
    type = list(string)
    default = ["az-1", "az-2", "az-3"]
}

<b>Set</b>

In this data type, the value should be enclosed in square brackets `[]`, containing multiple values. However, all elements must be of the same data type.

<b>Important notes</b>
* It is unordered, so elements cannot be retrieved by index.
* Duplicates are not allowed; if duplicate values are provided, they will be automatically removed.

Example: set(number)
[1, 2, 3, 4, 5]

variable "allowed_vm_types" {
    type = set(string)
    default = ["t2.micro", "t3.micro"]
}

You can use this variable anywhere, but it is particularly suitable where you need to avoid duplicates.

<b>Tuple</b>

In this data type, the value should be enclosed in square brackets `[]`. It accepts elements of different data types, but the order and types must match the tuple definition exactly.

<b>Important notes</b>
* It is ordered, so values can be accessed using an index.
* Duplicates are allowed.

Example:
tuple([number, bool, string, list(string)])
[4, false, “terraform”, [“aws”, “Kubernetes”]]

variable "inbound_rules" {
    type = tuple([number, number, string])
    default = [80, 80, "tcp"]
}

<b>Map</b>

In this data type, the value should be enclosed in curly braces `{}` as key-value pairs. All values must be of the same data type as specified in the variable’s type constraint. There is no limit to the number of key-value pairs, but all values must share the same data type.

<b>Important notes</b>
* It is unordered; values are accessed using keys.

Example:
map(number)
{
Tamil = 90,
English = 70,
Math = 80
}

This is not allowed:
{
Tamil = 90,
English = “subject”, # Wrong: string instead of number
Math = 80
}

variable "tags" {
    type = map(string)
    default = { Name = "test-vpc", Environment = "Development", created_by = "Terraform" }
}

<b>Object</b>

In this data type, the value should be enclosed in curly braces `{}` as multiple key-value pairs. When declaring the variable, you must specify both the key and corresponding value data types. It accepts different data types for values as defined in the declaration.

example: object({
from_port = number,
to_port = number,
protocol = string,
cidr_blocks = list(string)
})

value like below.

{
from_port = 443,
to_port = 443,
protocol = “tcp”,
cidr_blocks = [“0.0.0.0/0”]
}

variable "inbound_rules" {
    type = object({ from_port = number, to_port = number, protocol = string, cidr_blocks = list(string)})
    default = { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"]}
}

<b><h2>Type constraint</h2></b>
If a specific data type is declared for a variable, it will only accept values that match that data type. If no data type is specified, it will accept values of any data type.