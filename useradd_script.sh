#!/bin/bash

#Creating users from a list / CSV of users and their details
#Courtesy Earleywine (YT)


#Get the file
filein='userstobeadded.csv'
IFS=$'\n'

#Script begins

if [ ! -f “$filein” ]  #Check if the file exists
then
	echo “File does not exist: $filein”
else

	#Create arrays for each columns so that they can be used
	#for working with data and index
	
	column1=('cut -d: -f 2 “$filein” | sed ‘s/ //’')  #sed removes the spaces in between the column values
	column2=('cut -d -f 3 “$filein”')
	column3=('cut -d: -f 4 “$filein”')
	
	#Getting and Names and using just First alhpabet and Last name with Awk
	column4=('cut -d: -f 5 “$filein” | tr [A-Za-z] | awk ‘{print substr($1,1,1} $2}’')
  	#Useful snippet, for values like Usernames
	
	#Snippet:
	# Anything going within the parantheis () becomes an array


  #Create Group if it does not exist
	for group in ${groups[*]}
	do
		grep -q “^group” /etc/group ; let x=$?
		if [ $x -eq 1 ]
		then
			groupadd “$group”
		fi
	done
	
  #Counters
  created=0
  x=0
	
  #Create user accounts
	for user in ${column1[*]}
	do
		useradd -nMN -c ${fullnamesoftheuser[$x]} -g “$(groups[$x])” $user 2> /dev/nul
    
    		#Options:
  		#M = No user home directory (good for testing)
    		#N = Don't assign groups (good for testing)
    		#n = Do not create the User-group (good)
    		#c = Comment
    		#g = group to be assigned
    
		if [ $? -eq 0 ]
		then
			let created=$created+1
			#Another option for this line
			#created='expr $created+1'
		fi
		
   		 #Example: Use a column value for Password
   		 #Use AWK or SED to substitute for stronger passwords
		
		echo “$(column3[$x]}” | passwd --stdin “$user” > /dev/null
		
		#Above returns an error due to invalid option to command passwd
		#Option is to use chpass to set the password. chpass accepts the piped input.
		#echo "$(column3[$x]}" | chpass $user
	
	done

fi 	
	
