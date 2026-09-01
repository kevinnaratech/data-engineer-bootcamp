#| Mode  | Meaning         |
#---------------------------
#| `"r"` | read            |
#| `"w"` | write           |
#| `"a"` | append          |
#| `"x"` | create new file |

file = open("data.txt", "r")

content = file.read()

print(content)

file.close()

