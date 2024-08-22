import sys


def main(name):
    print(f"Hello, {name}!")


if __name__ == "__main__":

    # Check if an argument is provided, default to "world"
    name = sys.argv[1] if len(sys.argv) > 1 else "world"

    main(name)
