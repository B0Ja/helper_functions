#Objective: Initial version of Shifting Bits and XOR
# v0.01

#TODO: 
# 1. Enable String inputs
# 2. Enable Key, 
# 3. Shifting bits of Keys
# 4. Enable Blocking
# 5. Enable output of Encrypted Text
# 6. Add iterations of Shifts
# 7. Add Confusion with a Confusion matrix
# 8. Add Diffusion to bits
# 9. Add Decrypting part for the code


#Set a numeral
_ = 10

#Number of the places for the bits to shift
n = 3

#Convert the input into binary
x = int(bin(_)[2:])

#Shift the bits in the input's binary
y = x << n

#Convert the string bits to intergers
y_ = int(bin(y)[2:])

#Convert the two sets of integers into a list of digits
x_ = list(map(int, str(x)))
y_list = list(map(int, str(bin(y)[2:])))


#Zero pad the initial numeral's bits
#Since the shifted bit would be higher in length
if len(y_list) > len(x_):
  c = len(y_list) - len(x_)
  for i in range(0, c):
    x_.insert(0, '0')

#Make a new list which holds the values of the padded list
x2 = []
for i in range(0, len(x_)):
  x2.append( int(x_[i]) )
    
#Just a check on the lists as
print (x2 , len(x2))
print (y_list, len(y_list))

#XORing the two lists
XOR = []
for i, j in enumerate(zip(y_list, x2)):
  XOR.append(j[0] ^ j[1])
print (XOR)

