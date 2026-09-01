# Now, let's try creating a file.
with open("data.txt", "w")as file:  # If data.txt does not yet exist, Python will create it.
    file.write("Hello python")      #If it already exists, the "w" mode will overwrite the file's contents.


