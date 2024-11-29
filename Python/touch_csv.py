import pandas as pd

# 创建一些示例数据
data = {
    '姓名': ['张三', '李四', '王五'],
    '年龄': [25, 30, 22],
    '城市': ['北京', '上海', '广州aaa']
}

# 将数据转换为 DataFrame
df = pd.DataFrame(data)

# 保存为 CSV 文件
df.to_csv('bbb.csv', index=False, encoding='utf-8-sig')
