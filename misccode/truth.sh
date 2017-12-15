#!/bin/bash

echo
echo "Testing \"0\""
if [ 0 ]; then
  echo "0 is true."   # <---
else
  echo "0 is false."
fi

echo
echo "Testing \"1\""
if [ 1 ]; then
  echo "1 is true."   # <---
else
  echo "1 is false."
fi

echo
echo "Testing \"NULL\""
if [ ]; then        # NULL (empty condition)
  echo "NULL is true."
else
  echo "NULL is false."   # <---
fi

echo
echo "Testing \"xyz\""
if [ xyz ]; then    # string
  echo "Random string is true."   # <---
else
  echo "Random string is false."
fi

echo
echo "Testing \"\$xyz\""
if [ $xyz ]   # Tests if $xyz is null, but...
              # it's only an uninitialized variable.
then
  echo "Uninitialized variable is true."
else
  echo "Uninitialized variable is false."   # <---
fi

echo
echo "Testing \"-n \$xyz\""
if [ -n "$xyz" ]; then            # more pedantically correct
  echo "Uninitialized variable is true."
else
  echo "Uninitialized variable is false."   # <---
fi

# When is "false" true?
echo
echo "Testing \"false\""
if [ "false" ]; then
  echo "\"false\" is true."   # <---
else
  echo "\"false\" is false."
fi

echo
echo "Testing \"\$false\""  # Again, uninitialized variable.
if [ "$false" ]; then
  echo "\"\$false\" is true."
else
  echo "\"\$false\" is false."   # <---
fi

exit 0
