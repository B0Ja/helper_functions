"""
In this version, the block sizes are not used for calcualtions, but a simple padded key is used. This would lead to a very weak cipher as majority of the bits are zero. For very large length of bits of messages, the proportional number of key's bits would be minimal, leading to a very weak cipher.

One way of adding strength would be to increase key length to a very long length.

Another limitation of this version is that it is coded for integers. Next version would be for strings, including numerals.

Next version would include a repeating block of messages XORing with the repeating blocks of key to arrive at much stronger encryption.

Additional phases would include confusion and diffusion matrix.

"""

#TODO: 1. Make the variables clearer
#TODO: 2. Make the Key Blocks repititive (Streaming Cipher implementation)
#TODO: 3. Make/ Synthesize Key Blocks using the blocks of Text/Number & Key (K1) (Continous Block Chains)

#Imports
import time

#The secret message
x = str(input("Enter your message here: ") or "hello")

if x.isdigit() == True:
    x = int(x)

#The secret key
k = 53

#The block size
"""Keep the block size at 8, as english Characters are in the 8-byte range"""
y = 8


#UDFs

def to_bin(string):

    #Take a string and convert it into Binary
    res = ''
    for char in string:
        tmp = bin(ord(char))[2:]
        tmp = '%08d' % int(tmp)
        res += tmp
    return res


def to_int(word):

    #Take the String binary from to_bin function
    #convert it into a list of binary digits
    new_word = []
    for char in word:
        new_word.append(int(char))
    return new_word


def int_to_bin_list(x):

    # Converts the Integer into a list of binary
    x_tmp1 = bin(x)[2:]
    x_tmp2 = [int(d) for d in str(x_tmp1)]
    return (x_tmp2)


def input_int_string_to_list(x):

    # Takes the input, checks if it is string or integer
    # Returns the value as List of Binary digits
    if type(x) == str:
        x_tmp = to_bin(x)
        x_tmp2 = to_int(x_tmp)
        return x_tmp2
    else:
        x_tmp = int_to_bin_list(x)
        return x_tmp


#Convert list of Integers to Characters
#Using the blocks defined
def binary_to_string(x):
    res = ''
    for i in range(0, len(x), y):
        yes = ''
        if 1 in x[i:i + y]:
            y_tmp = (x[i:i + y])
            for j in y_tmp:
                yes += str(j)
            res += chr(int(yes, 2))
    return res


v = input_int_string_to_list(x)  #v
v1 = input_int_string_to_list(k)  #v1

#
#Setting the block sizes
#
if len(v1) > y:
    """"
  If the Key length exceeds the 'block size', it is better to use the longer key length. Hence, in this calculation, we reassign the longer 'key length' as new 'block size.' 
  """
    #y = len(v1) #Works
    y = len(v1) + (y - (len(v1) % y))

if len(v) < y:
    """
    Unlikely case: In the case if the message is smaller than the Block Size, use the padding.
    This case is applicable if the key's length is much longer than message.
    """
    diff = y - len(v)
    v = [0] * diff + v

if len(v) > y:
    """
    Here we ensure that we pad the message length
    to multiples of block size
    """
    diff_4 = y - (len(v) % y)
    v = [0] * diff_4 + v

if len(v1) < y:
    """
    If the key length is lesser than the
    block size, we retain the block size, but
    prepend with zeros
    """

    diff_v1 = y - len(v1)
    v1 = [0] * diff_v1 + v1

if len(v1) > y:
    """
    In the case, the key is greater than block size.
    Most likely this block is not triggered as we set Key length = block size
    """
    diff_v2 = y - (len(v1) % y)
    print(diff_v2)
    v1 = [0] * diff_v2 + v1
"""

For the case where message length > key length,
pad the message with Zeros to ensure block size.

Next version to include the repetitive block sizes

"""

#Solve for Message > Key, and multiple the keys
if len(v) > len(v1):
    diff_5 = len(v1) - (len(v) % len(v1))
    #Equivalent
    #y - (len(v) % len(v1))
    v = [0] * diff_5 + v

if len(v) > len(v1):
    diff_6 = len(v) - len(v1)
    v1 = [0] * diff_6 + v1

#XOR the two lists to get an encrypted list
XOR = []
if len(v) == len(v1):
    for i, j in enumerate(zip(v, v1)):
        XOR.append(j[0] ^ j[1])
else:
    print("The lists are not matched.")

#Start the decoding process
print("\n____Challenge_KEY____\n")
x__ = int(input("Enter the key number: "))

#Convert the key-number into a binary list
x_ = bin(x__)[2:]
v4 = [int(d) for d in str(x_)]

#One way of doing it
#Take the number, and append everything with 0
#Key is not repeated by blocks
if len(v4) != len(XOR):
    diff_7 = abs(len(v4) - len(XOR))
    v4 = [0] * diff_7 + v4
"""
XOR the given key with the XOR_output list
"""
XOR_d = []
if len(v4) == len(XOR):
    for i, j in enumerate(zip(v4, XOR)):
        XOR_d.append(j[0] ^ j[1])
else:
    print("The lists are not matched.")

#Derive the number from the XOR'd ouput
#And remove the padding
XOR2 = XOR_d[XOR_d.index(1):]
v_d = [str(i) for i in XOR2]
v_d = int("".join(v_d), 2)

if type(x) == str:
    v3 = binary_to_string(XOR_d)
else:
    v3 = int(v_d)

#Check if the Number derived and Original
#message are same
if XOR_d == v and v3 == x:
    print(f'\nThe key is confirmed.')
    time.sleep(2)
    print(f'The message is {v3}')
else:
    #print (type(x), x)
    print(f'The key {x__} is wrong.')
