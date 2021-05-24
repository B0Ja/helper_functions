
message = str(input("Please enter your text: ") or "Hello")
key = str(input("Enter a secret key: ") or "key")


def to_bin(string):
    res = ''
    for char in string:
        tmp = bin(ord(char))[2:]
        tmp = '%08d' % int(tmp)
        res += tmp
    return res


msg_length = len((to_bin(message)))
key_length = len((to_bin(key)))


def padded(message, key):

    if msg_length > key_length:
        pad_required = msg_length - key_length
        key = to_bin(key).rjust(msg_length, '0')
        message = to_bin(message)
        return (message, key)

    elif msg_length < key_length:
        pad_required = key_length - msg_length
        message = to_bin(message).rjust(key_length, '0')
        key = to_bin(key)
        return (message, key)


str1, str2 = padded(message, key)

MSG_1, KEY_1, XOR = [], [], []

for char in str1:
    char_ = int(char)
    MSG_1.append(char_)

for char in str2:
    char_ = int(char)
    KEY_1.append(char_)

for i, j in enumerate(zip(MSG_1, KEY_1), start=0):
    XOR.append(j[0] ^ j[1])

print(f'Message: Length: {len(MSG_1)}. Type:{type(MSG_1)}  {MSG_1}')
print(f'Key: Length: {len(KEY_1)}. Type:{type(KEY_1)}    : {KEY_1}')
print(f'XOR: Length: {len(XOR)}. Type:{type(XOR)}   : {XOR}')
