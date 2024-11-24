# 声明一个关联数组
declare -A my_dict

# 赋值
my_dict[apple]="红色"
my_dict[banana]="黄色"
my_dict[cherry]="红色"

# 遍历字典并输出
for key in ${!my_dict[@]}; do
    echo "键: $key, 值: ${my_dict[$key]}"
done