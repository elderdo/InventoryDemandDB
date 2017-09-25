#!/bin/ksh

start=`date "+%H:%M:%S %Z %Y"`
sleep 20
end=`date "+%H:%M:%S %Z %Y"`

((start_mins = $(expr substr "$start" 1 2)*60 + $(expr substr "$start" 4 2)))
((end_mins = $(expr substr "$end" 1 2)*60 + $(expr substr "$end" 4 2)))
((elapsed_mins = end_mins - start_mins))

if [[ "$elapsed_mins" -lt 0 ]]
then
   ((elapsed_mins += 1440))
fi

if [[ "$elapsed_mins" -gt 59 ]]
then
   print $((elapsed_mins / 60)) hours and $((elapsed_mins % 60)) minutes
else
   print $elapsed_mins minutes
fi

