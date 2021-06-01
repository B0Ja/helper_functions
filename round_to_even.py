x = 3.4

# 3.2 = 4
# 2.8 = 2
# 3 = 2

if round(x) % 2 == 0:
    print (round(x))
else:
    z1 = round (x) + 1
    z2 = round (x) - 1
    if abs(z1 - x) > abs(z2 - x):
        print (z2)
    elif abs(z1 - x) == abs(z2 -x):
        print (z2)
    else:
        print (z1)
