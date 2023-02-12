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
