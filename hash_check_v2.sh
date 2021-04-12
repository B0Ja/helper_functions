#!/bin/bash

#A simple function to check the hash of two strings.
# V2. To check the hashes of different files, dirs, and tars

#Limitations of this version

echo “Enter a string to check: “ 
read input
echo “”
echo “Enter a string to check: “
read input2


echo “ Select the algorithm: :
echo “ 1. MD5	: “
echo “ 2. SHA256	: “
echo “ 3. SHA512	: “
echo “ … “
read user_input

if [ $user_input == 1 ]; then
	hash=“md5sum”
elif [ $user_input == 2 ]; then
	hash=“sha256sum”
elif [$user_input == 3 ]; then
	hash=“sha512sum”
else
	echo “Please enter valid input”


#Simple function to generate MD5
hashit() {

echo -n $1 | $hash | awk ‘{print $1}’

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
