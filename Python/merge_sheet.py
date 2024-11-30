#此脚本用来将给定路径下的csv文件合并为一个csv的不同sheet
import pandas as pd
import os

#获取输入的需要合并的csv文件路径
path = input("请输入需要合并的csv文件路径：")
#path = r'D:\data\code\git_code\code_training\Python\table'
#在给定文件夹下寻找csv文件
csv_files = [os.path.join(path, file) for file in os.listdir(path) if file.endswith('.csv')]
print(csv_files)
#读取csv文件保存为一个csv的不同sheet
with pd.ExcelWriter(os.path.join(path,"merged_sheet_csv.xlsx")) as writer:
    # 读取csv文件并保存为一个csv的不同sheet
    for file in csv_files:
        df = pd.read_csv(file, encoding='utf-8')

        # 使用文件名（去掉扩展名）作为 sheet 名
        sheet_name = os.path.splitext(os.path.basename(file))[0]
        df.to_excel(writer, sheet_name=sheet_name, index=False)
print("合并完成！")
