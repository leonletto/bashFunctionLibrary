#!/usr/bin/env bash

. ./bashLibrary.sh

# Test the checkPassword function
echo "Testing checkPassword function"
testPassword="Test1234$%^"
if checkPassword "$testPassword"; then
    echo "checkPassword: Password is valid"
else
    echo "checkPassword: Password is invalid"
fi
# Invalid test password
testPassword="Test1234&"
if checkPassword "$testPassword"; then
    echo "Password is valid"
else
    echo "Password is invalid"
fi

# test the prepScript.sh script
files=("bashLibrary.sh" "bashLibrary.sh")
destination="fullScript.sh"
./prepScript.sh "${files[@]}" "$destination"

echo "Testing the prepScript.sh script"
echo " Check the $destination file to see if it was created and has the correct contents"
echo " Press any key to continue"
read -r -s -n 1
rm -f "$destination"

