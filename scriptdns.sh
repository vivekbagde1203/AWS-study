ALB_DNS="replace-with-your-alb-dns-name"

for i in $(seq 1 15); do
  curl -s "http://${ALB_DNS}/" | grep "Served by"
done
