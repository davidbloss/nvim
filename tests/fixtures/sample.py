import os


def greet(name: str) -> str:
    return f"hello {name} from {os.getcwd()}"


print(greet("world"))
