
$ cat file.txt
id9,Mohit Kishore,19,13,14,10
id2,Niraj Kumar,13,8,23,8
id8,Kate Nil,19,18,15
id4,Rashi S,19,28,65,10,19

$ awk '
BEGIN {FS=OFS=","}
{
sum=0; n=0
for(i=3;i<=NF;i++)
     {sum+=$i; ++n}
     print $0,"sum:"sum,"count:"n,"avg:"sum/n
}' file.txt
