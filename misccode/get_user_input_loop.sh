#!/bin/sh

# type 'enough' to quit, a function would normally go on disk_space=$templocation
get_user_input_loop() {
  valid_alt_dir="false"

  until [ "$valid_alt_dir" = "true" ] ; do
    echo "Enter alternate directory or (q) to quit: "
    read usrinp
    templocation=$usrinp

    case "$templocation" in
      q|Q|quit|Quit|QUIT)
        exit 0
      ;;
      *)
        if [ -n "$templocation" ] ; then
          disk_space=$templocation
          if [ "$disk_space" = "enough" ] ; then
            valid_alt_dir=true
          else
            continue
          fi
        else
          read state
          case "$state" in
            q|Q|quit|Quit|QUIT)
            exit 0
          ;;
          esac
        fi
      ;;
    esac
  done

  return
}
get_user_input_loop
