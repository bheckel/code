#!/usr/bin/env bash

retirement_date="2024-12-02"
holidays=("2024-05-22" "2024-05-27" "2024-09-01" "2024-07-04" "2024-09-02" "2024-11-28" "2024-11-29" "2024-12-25")

today_date=$(date +%F)

days_remaining=$((($(date -d "$retirement_date" +%s) - $(date -d "$today_date" +%s)) / 86400))

# Calculate the number of weekends (Saturday and Sunday) within the remaining days
weekends=$((days_remaining / 7 * 2))

# Exclude weekends and holidays from the total days remaining
workdays_remaining=$((days_remaining - weekends))

for holiday in "${holidays[@]}"; do
  if [[ "$holiday" > "$today_date" && "$holiday" < "$retirement_date" ]]; then
    workdays_remaining=$((workdays_remaining - 1))
  fi
done

echo "Workdays remaining until retirement: $workdays_remaining"
