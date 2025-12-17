<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform functions</h1></b>
</p>

Terraform provides built-in functions similar to those in other programming languages. These can be used anywhere based on your needs. Only Terraform-provided built-in functions are available; custom functions cannot be created. We’ve already covered Terraform meta-arguments and expressions, which help improve Terraform configurations efficiently — such as using a single resource block to create multiple resources, customizing default Terraform behavior, and avoiding multiple nested blocks within resource blocks. Terraform functions also add value when implementing infrastructure based on dynamic values rather than static ones, like creating subnets based on the number of availability zones and assign CIDR range for each subnets. We will see examples below.

There are lot of categories in terraform functions. Each category has multiple functions. We will see some of them one by one.

<b><h3>Numeric functions:</h3></b>

<b>abs():</b> It returns the given value as it is. If given value is negative then it will return as positive value.

```
C:\Users\My>terraform console
> abs(10)
10
> abs(-10)
10
>
```

<b>min():</b> It return the minimum value from the given values, the values should be individual not collection. If you are going to put collection in this function the you need to use … operator to convert the collection into individual value.
```
> min(1,2,3,4,5)
1
> min([1,2,3,4,5]...)
1
>
```

<b>max():</b> It returns the maximum value from the given values.
```
> max(2,3,7,8,10)
10
> max([5,10, 25, 456]...)
456
>
```
<b>ceil():</b> It returns the given value if it is whole number otherwise will return the whole number of the next immediate from the given decimal number.
```
> ceil(10)
10
> ceil(10.1)
11
>
```
<b>floor():</b> It is also like ceil function, but it returns the whole number of the previous one from the given decimal number.
```
> floor(10)
10
> floor(10.1)
10
>
```

<b><h3>String functions:</h3></b>

<b>lower():</b> It convert all the upper case letter into lower case and also retain the lower case if some letters are already lower case.
```
> lower("Terraform Practice")
"terraform practice"
>
```
<b>upper():</b> It convert all the lower case into upper case.
```
> upper("Terraform Practice")
"TERRAFORM PRACTICE"
>
```
<b>replace():</b> It replaces sub string from the actual string as you wish.
```
replace(actual string, sub string, replace string)

> replace("terraform practice", "a", "bc")
"terrbcform prbcctice"
>
```
<b>substr():</b> It is like slice, extract specific string from the given one based on the given start and end index.
```
> substr("Terraform Practice", 0, 9)
"Terraform"
> substr("Terraform Practice", 10, 18)
"Practice"
>
```
<b>split():</b> It helps to covert the string into list based on the given separator.
```
> split("a", "Terraform Practice")
tolist([
  "Terr",
  "form Pr",
  "ctice",
])
>
```
<b>join():</b> It helps to convert the list into string based on the first argument of the join function.
```
both second argument is same list but I have passed in different way.

> join("a", split("a", "Terraform Practice"))
"Terraform Practice"
> join("a", ["Terr", "form Pr", "ctice"])
"Terraform Practice"
>
```
<b>trim():</b> It removes the given word or character in the second argument of this function from the actual string start and end not every occurrence.
```
> trim("Terraform Practice", "e")
"Terraform Practic"
>
```
<b>trimspace():</b> It removes the space from the start and end of the string. It only expect one argument.
```
> trimspace("  Terraform Practice     ")
"Terraform Practice"
>
```
<b>title():</b> It converts the lower case into upper case of the every word first letter.
```
> title("terraform practice")
"Terraform Practice"
>
```
<b>startswith():</b> It checks whether the string starts with the specified string or not. If start then it will return true otherwise false.
```
> startswith("Terraform Practice", "Terraform")
true
> startswith("Terraform Practice", "terraform")
false
>
```
<b>endswith():</b> It return Boolean value based on the string ends with the specified string or not.
```
> endswith("Terraform Practice", "Practice")
true
> endswith("Terraform Practice", "Terraform")
false
>
```

<b><h3>Collection functions:</h3></b>

<b>element():</b> It return the value of the given index.
```
> element(["Terraform", "EKS", "AWS"], 2)
"AWS"
>
```
<b>index():</b> It return the index value of the given value from the list.
```
> index(["Terraform", "EKS", "AWS"], "EKS")
1
>
```
<b>lookup():</b> It give the value of the corresponding given key, if the key does not exist then it will return the default value.
```
> lookup({IAC = "Terraform", Cont-Orch = "EKS", Cloud = "AWS"}, "Cont-Orch", "Azure")
"EKS"
> lookup({IAC = "Terraform", Cont-Orch = "EKS", Cloud = "AWS"}, "Cloud-1", "Azure")
"Azure"
>
```
<b>contains():</b> It evaluate the given the value is there in the collection or not, If there it will return true otherwise false. It helps when we need some condition evaluation.
```
> contains(["Terraform", "EKS", "AWS"], "Terraform")
true
>
```
<b>concat():</b> It helps to club the multiple list into single list.
```
> concat([1,2], [3,4], [5,7])
[
  1,
  2,
  3,
  4,
  5,
  7,
]
>
```
<b>merge():</b> It helps to clube multiple map into single map.
```
> merge({IAC = "Terraform", Cont-Orch = "EKS", Cloud = "AWS"}, {Automation = "Python"})
{
  "Automation" = "Python"
  "Cloud" = "AWS"
  "Cont-Orch" = "EKS"
  "IAC" = "Terraform"
}
>
```
<b>length():</b> It count the number of elements in the collection.
```
> length(merge({IAC = "Terraform", Cont-Orch = "EKS", Cloud = "AWS"}, {Automation = "Python"}))
4
>  length("Terraform")
9
>
```
<b>keys():</b> It returns list of the keys from the map or object.
```
> keys(merge({IAC = "Terraform", Cont-Orch = "EKS", Cloud = "AWS"}, {Automation = "Python"}))
[
  "Automation",
  "Cloud",
  "Cont-Orch",
  "IAC",
]
>
```
<b>values():</b> It returns the list of values from the map or object.
```
> values(merge({IAC = "Terraform", Cont-Orch = "EKS", Cloud = "AWS"}, {Automation = "Python", count = 2}))
[
  "Python",
  "AWS",
  "EKS",
  "Terraform",
  2,
]
>
```
<b>distinct():</b> It return the new list once removed duplicates from the given list.
```
> distinct([1, 2, 3, 2, 5, 4, 4])
tolist([
  1,
  2,
  3,
  5,
  4,
])
>
```

<b><h3>File system functions:</h3></b>

<b>file():</b> It reads the content of the file and return as string.
```
> file("terraform-functions.txt")
<<EOT
Terraform functions:
---------------------
Numeric functions: abs(), ceil(), floor(), min(), max()
String functions: lower(), upper(), replace(), substr(), trim(), trimspace(), split(), join(), title(), endswith(), startswith(), chomp(), regex()
Collection functions: element(), index(), lookup(), keys(), values(), length(), contains(). merge(), concat(), distinct()
FileSystem functions: file(), fileexists(), filebase64(), fileset(), abspath(), dirname(), basename()
Encode functions: base64encode(), base64decode(), jsonencode(), jsondecode()
Time Date functions: timestamp(). formatdate()
Network functions: cidrhost(), cidrnetmask(), cidrsubnet(), cidrsubnets()

EOT
>
```
<b>abspath():</b> It returns the absolute path of the given file.
```
> abspath("terraform-functions.txt")
"C:/Users/My/Desktop/terraform-functions.txt"
>
```
<b>dirname():</b> It returns the folder path of the given absolute path of the file. It removes only last portion of the absolute path.
```
> dirname(abspath("terraform-functions.txt"))
"C:\\Users\\My\\Desktop"
>
```
<b>basename():</b> It returns the file name only from the absolute path. It remove the portion except the last portion.
```
> basename(abspath("terraform-functions.txt"))
"terraform-functions.txt"
> basename("C:/Users/My/Desktop/terraform-functions.txt")
"terraform-functions.txt"
>
```
<b>fileexists():</b> It helps to check whether the file is present or not. If there then it will return true otherwise return false.
```
> fileexists("terraform-functions.txt")
true
>  fileexists("terraform-function.txt")
false
>
```
<b>filebase64():</b> It reads the content of the file and return base64 encoded format.
```
> filebase64("terraform-functions.txt")
"VGVycmFmb3JtIGZ1bmN0aW9uczoNCi0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KTnVtZXJpYyBmdW5jdGlvbnM6IGFicygpLCBjZWlsKCksIGZsb29yKCksIG1pbigpLCBtYXgoKQ0KU3RyaW5nIGZ1bmN0aW9uczogbG93ZXIoKSwgdXBwZXIoKSwgcmVwbGFjZSgpLCBzdWJzdHIoKSwgdHJpbSgpLCB0cmltc3BhY2UoKSwgc3BsaXQoKSwgam9pbigpLCB0aXRsZSgpLCBlbmRzd2l0aCgpLCBzdGFydHN3aXRoKCksIGNob21wKCksIHJlZ2V4KCkNCkNvbGxlY3Rpb24gZnVuY3Rpb25zOiBlbGVtZW50KCksIGluZGV4KCksIGxvb2t1cCgpLCBrZXlzKCksIHZhbHVlcygpLCBsZW5ndGgoKSwgY29udGFpbnMoKS4gbWVyZ2UoKSwgY29uY2F0KCksIGRpc3RpbmN0KCkNCkZpbGVTeXN0ZW0gZnVuY3Rpb25zOiBmaWxlKCksIGZpbGVleGlzdHMoKSwgZmlsZWJhc2U2NCgpLCBmaWxlc2V0KCksIGFic3BhdGgoKSwgZGlybmFtZSgpLCBiYXNlbmFtZSgpDQpFbmNvZGUgZnVuY3Rpb25zOiBiYXNlNjRlbmNvZGUoKSwgYmFzZTY0ZGVjb2RlKCksIGpzb25lbmNvZGUoKSwganNvbmRlY29kZSgpDQpUaW1lIERhdGUgZnVuY3Rpb25zOiB0aW1lc3RhbXAoKS4gZm9ybWF0ZGF0ZSgpDQpOZXR3b3JrIGZ1bmN0aW9uczogY2lkcmhvc3QoKSwgY2lkcm5ldG1hc2soKSwgY2lkcnN1Ym5ldCgpLCBjaWRyc3VibmV0cygpDQo="
>
```
<b>fileset():</b> It return the set of filenames based on the path that you have mentioned and pattern.
```
fileset(path, pattern)

> fileset("./", "**/main.tf")
toset([
  "Day-03/main.tf",
  "Day-04/main.tf",
  "Day-07/main.tf",
  "Day-08/main.tf",
  "Day-09/main.tf",
  "Day-10/main.tf",
  "Day-11-12/main.tf",
])
>
```

<b><h3>Encode and Decode functions:</h3></b>

<b>jsondecode():</b> It reads the json string and convert it into terraform native data type like map, object.
```
> jsondecode(file("config.json"))
{
  "database" = {
    "host" = "db.example.com"
    "port" = 5432
    "username" = "admin"
  }
}
> exit

C:\Users\My\Desktop>cat config.json
{
 "database": {
 "host": "db.example.com",
 "port": 5432,
 "username": "admin"
 }
}
C:\Users\My\Desktop>
```
<b>jsonencode():</b> It convert it into json string from the terraform native data type.
```
> jsonencode({
:   "database" = {
:     "host" = "db.example.com"
:     "port" = 5432
:     "username" = "admin"
:   }
: })
"{\"database\":{\"host\":\"db.example.com\",\"port\":5432,\"username\":\"admin\"}}"
>
```

<b><h3>Date and Time functions:</h3></b>

<b>timestamp():</b> It return the current date and time in UTC time zone.
```
> timestamp()
"2025-12-16T15:30:54Z"
>
```
<b>formatdate():</b> It helps to format the date and time as per our need.
```
> formatdate("DD-MMM-YY", timestamp())
"16-Dec-25"
>
```

<b><h3>Network functions:</h3></b>

<b>cidrhost():</b> It return the specific host IP address from the prefix.
```
cidrhost(prefix, hostnum)
> cidrhost("192.168.0.0/24", 44)
"192.168.0.44"
>
```
<b>cidrnetmask():</b> It return the subnet mask value of the given CIDR value.
```
> cidrnetmask("192.168.0.0/24")
"255.255.255.0"
>
```

<b>cidrsubnet():</b> It return the CIDR range from the given prefix, new bits and net num.
```
cidrsubnet(cidr, new-bits, net-num)

> cidrsubnet("192.168.0.0/24", 4, 5)
"192.168.0.80/28"
>
```
new bits extent the number of network bits from the exiting one.

net num means apply the binary value of the given decimal value in the extended network bits. From this it return CIDR range.