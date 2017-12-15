
clipboardx() {       # <---Note: No PARAMS PASSED!
  # $1 refers to 1st param passed into this fn
  echo "first parm is $1 and second is $2"
}

# $1 refers to param passed by user
clipboardx foo $1
