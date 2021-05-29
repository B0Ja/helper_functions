
"""
In this version, the block sizes are not used for calcualtions, but a simple padded key is used. This would lead to a very weak cipher as majority of the bits are zero. For very large length of bits of messages, the proportional number of key's bits would be minimal, leading to a very weak cipher.

One way of adding strength would be to increase key length to a very long length.

Another limitation of this version is that it is coded for integers. Next version would be for strings, including numerals.

Next version would include a repeating block of messages XORing with the repeating blocks of key to arrive at much stronger encryption.

Additional phases would include confusion and diffusion matrix.

"""

#The secret message
x = 29000
#The secret key
k = 53
#The block size
y = 8 #block

#Convert the integers to list of bits
x1 = bin(x)[2:]
v = [int(d) for d in str(x1)]

y1 = bin(k)[2:]
v1 = [int(d) for d in str(y1)]


#Setting the block sizes
"""
If the Key length exceeds the 'block size', it is better to use the longer key length. Hence, in this calculation, we reassign the longer 'key length' as new 'block size.' 
"""
if len(v1) > y:
  #y = len(v1) #Works 
  y = len(v1) + (y - (len(v1) % y))

"""
Unlikely case: In the case if the message is smaller than the Block Size, use the padding.
This case is applicable if the key's length is much longer than message.
"""
if len(v) < y:
  diff = y - len(v)
  v = [0] * diff + v


"""
Here we ensure that we pad the message length
to multiples of block size
"""
if len(v) > y:
  diff_4 = y - (len(v) % y)
  v = [0] * diff_4 + v


"""
If the key length is lesser than the
block size, we retain the block size, but
prepend with zeros
"""
if len(v1) < y:
  diff_v1 = y - len(v1)
  v1 = [0] * diff_v1 + v1


"""
In the case, the key is greater than block size.
Most likely this block is not triggered as we set Key length = block size
"""
if len(v1) > y:
  diff_v2 = y - (len(v1) % y)
  print (diff_v2)
  v1 = [0] * diff_v2 + v1



"""
For the case where message length > key length,
pad the message with Zeros to ensure block size.

Next version to include the repetitive block sizes
"""
#Solve for Message > Key, and multiple the keys
if len(v) > len (v1):
  diff_5 = len(v1) - (len(v) % len(v1))
  #Equivalent
  #y - (len(v) % len(v1))
  v = [0] * diff_5 + v


if len(v) > len (v1):
  diff_6 = len(v) - len(v1)
  v1 = [0] * diff_6 + v1



#XOR the two lists to get an encrypted list
XOR = []
if len(v) == len(v1):
  for i, j in enumerate(zip(v, v1)):
    XOR.append(j[0] ^ j[1])
else:
  print ("The lists are not matched.")



#Start the decoding process
print ("____Challenge____")
x_ = int(input("Enter the key number: "))


#Convert the key-number into a binary list
x_ = bin(x_)[2:]
v4 = [int(d) for d in str(x_)]



#One way of doing it
#Take the number, and append everything with 0
#Key is not repeated by blocks
if len(v4) != len(XOR):
  diff_7 = abs(len(v4)- len(XOR))
  v4 = [0] * diff_7 + v4



"""
XOR the given key with the XOR_output list
"""
XOR_d = []
if len(v4) == len(XOR):
  for i, j in enumerate(zip(v4, XOR)):
    XOR_d.append(j[0] ^ j[1])
else:
  print ("The lists are not matched.")


#Derive the number from the XOR'd ouput
#And remove the padding
z = XOR_d[XOR_d.index(1): ]


#Convert Binaries to Number/ Integer
v_d = [str(i) for i in XOR_d]
v_d = int("".join(v_d), 2)



#Check if the Number derived and Original
#message are same
if XOR_d == v and v_d == x:
  print (f'The message {v_d} is confirmed.')
else:
  print (f'The message {v_d} is wrong.')


