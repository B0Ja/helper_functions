_BLOCK_SIZE = 5


def to_bin(string):
    res = ''
    for char in string:
        tmp = bin(ord(char))[2:]
        tmp = '%08d' % int(tmp)
        res += tmp
    return res


message_ = to_bin(str(input("Enter you text here: ") or "Hello"))
key_ = to_bin(str(input("Enter you key here: ") or "key"))

def crypto_block(message_string):

    MSG, result = [], []

    for char in message_string:
        char_ = int(char)
        MSG.append(char_)

    for i in range(0, len(MSG), _BLOCK_SIZE):
        result.append(MSG[i:i + _BLOCK_SIZE])

    if len(result[-1]) < _BLOCK_SIZE:
        y = _BLOCK_SIZE - len(result[-1])
        for i in range(0, y):
            result[-1].insert(i, 0)

    print(len(message_string))
    print(result)


crypto_block(message_)
crypto_block(key_)


'''
for char in str1:
    char_ = int(char)
    MSG.append(char_)
    
print (len(str1))


#x = len(str1) % n  
#output=[MSG[i:i + n] for i in range(0, (len(MSG)+x), n)]
#print(output)


result = []
for i in range (0, len(MSG), n):
	result.append(MSG[i:i+n])
   
if len(result[-1]) < n:
  y = n - len(result[-1])
  for i in range(0, y):
    result[-1].insert(i, 0)
 
print(result)
'''
