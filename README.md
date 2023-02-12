# bashFunctionLibrary
some common utility functions I use in my other libraries and scripts that are too small to need a separate repo.

## Usage for bashLibrary.sh
```bash
. ./bashFunctionLibrary.sh

# Use the functions
# Test the checkPassword function
echo "Testing checkPassword function"
testPassword="Test1234$%^"
if checkPassword "$testPassword"; then
    echo "checkPassword: Password is valid"
else
    echo "checkPassword: Password is invalid"
fi

```

## Usage for prepScript.sh
```bash
# create an array of files to combine
files=("bashFunctionLibrary.sh" "bashFunctionLibrary.sh")
# decide on a destination file name
destination="fullScript.sh"
# run the script
example: ./prepScript.sh "${files[@]}" "$destination"
# Notice how you must use the "${files[@]}" syntax to pass the array to the script
```
