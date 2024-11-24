i=1
sum=0
until [ $i -gt 50 ]
do
  let sum+=$i
  let i++
done
echo $sum