
_BIT_LENGTH = 10
_BIT_FILLER = '0'

key = 02
message = 50

def to_int(word):
    new_word = []
    for char in word:
        new_word.append(int(char))
    return new_word

def to_bit(num):
    bit_num = "{0:b}".format(num).rjust(_BIT_LENGTH, _BIT_FILLER)
    return bit_num

key_bit = to_int(to_bit(key))
message_bit = to_int(to_bit(message))

print (key_bit)
print (message_bit)
print ("------------------------------")

def makeXOR(x,y):
    XOR_list=[ ]
    for i, j in enumerate(zip(x, y)):
        xo = j[0] ^ j[1]
        XOR_list.insert(i, xo)
    
    print (XOR_list)
    return XOR_list

makeXOR(key_bit, message_bit)
