#Change current working directory

def change_dir(folder):
    """ Helper function to change the working directory."""
    import os
    current = os.getcwd()
    print ("Current WD is: {}".format(current))
    path_ = '/home/lubuntu/Downloads/TempDelete/' + folder
    
    if not os.path.exists(path_):
        os.makedirs(path_)
    
    os.chdir(path_)
    new = os.getcwd()
    print ("The changed WD is: {}".format(new))
    if current == new:
        print("Working Directory - NOT changed. ERROR.")
    else:
        print("Working Directory - Successfully changed")
    
change_dir('pytest3')
