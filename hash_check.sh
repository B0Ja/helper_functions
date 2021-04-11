#!/bin/bash

#A simple function to check the hash of two strings.
# V2. To check the hashes of different files, dirs, and tars

echo “Enter a string to check: “ 
read input
echo “”
echo “Enter a string to check: “
read input2

#Simple function to generate MD5
hashit() {
echo -n $1 | md5sum | awk ‘{print $1}’
}

#Running inputs through the hash function
var1=$(hashit “$input”)
var2=$(hashit “$input2”)

#Check
if [ $var1 — $var2 ]; then
	echo “The hashes match. The strings are same.”
else
	echo “The hashes don’t match. The strings are different.”
fi
