#Set a numeral
_ = 10

#Number of the places for the bits to shift
n = 3

#Key
k_ = 25
k = int(bin(k_)[2:])
k_list = list(map(int, str(bin(k_)[2:])))

#Convert the input into binary
x = int(bin(_)[2:])

#Shift the bits in the input's binary
y = x << n


def to_binary(x):

    _ = int((bin(x))[2:], 2)
    return _



def str_tolist_of_integers(x):

    _ = list(map(int, str(x)))
    return _


def int_tolist_of_integers(x):

    _ = list(map(int, str(bin(x)[2:])))
    return _




def string_list_to_int(x):

    #Takes the list of string, converts to list of integers
    integer_list = []
    for i in range(0, len(x)):
        integer_list.append(int(x[i]))

    return integer_list


def pad_lists(x, y):

    new_list = []
    if len(x) > len(y):
        c = len(x) - len(y)
        for i in range(0, c):
            y.insert(0, '0')
        new_list = y
    else:
        c = len(y) - len(x)
        for i in range(0, c):
            x.insert(0, '0')
        new_list = x

    #Run the String to lists
    integer_list = string_list_to_int(new_list)

    return integer_list


def XOR_lists(x, y):

    #Takes two lists and XOR it
    XOR = []

    for i, j in enumerate(zip(x, y)):
        XOR.append(j[0] ^ j[1])

    return XOR

y_ = to_binary(y)
x_ = int_tolist_of_integers(x)
y_list = int_tolist_of_integers(y)
x2 = pad_lists(y_list, x_)
k2 = pad_lists(y_list, k_list)
XOR = XOR_lists(y_list, x2)
XOR2 = XOR_lists(XOR, k2)

result = ''
for i in range(0, len(XOR2)):
    __ = "".join(str(XOR2[i]))
    result += __

output = int(result, 2)
print(f'The input text/number    : {_}')
print(f'The encrypted text/number: {output}')
