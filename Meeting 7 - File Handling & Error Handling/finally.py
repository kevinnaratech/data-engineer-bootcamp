try:
    number = int(input("Number: "))

except ValueError:
    print("Invalid number.")

finally:
    print("Program finished.")