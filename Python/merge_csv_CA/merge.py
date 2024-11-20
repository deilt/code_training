import csv
import os
import pandas as pd
import numpy as np
#from tqdm import tqdm

#获取当前文件夹 路径
current_dir = "D:/data/code/table"
# 指定新的表格文件路径+文件名
new_table_path = os.path.join(current_dir, 'new_table.xlsx')
# 指定旧的表格文件路径
old_table_path = os.path.join(current_dir, 'old_table.xlsx')
#打印新表和旧表的名字
print('指定新表格为：',new_table_path)
print('指定旧表格为：',old_table_path)

# 读取新的表格文件
new_table = pd.read_excel(new_table_path)
# 读取旧的表格文件
old_table = pd.read_excel(old_table_path)
#新表预处理，该在15列后面增加列索引owner、version、SG分析描述、SG执行结果、Enno分析描述、Enno执行结果、Unnamed，这7个列索引
#if 'owner' not in new_table.columns:
#    new_table.insert(15, 'owner', '')
#    new_table.insert(16, 'version', '')
#    new_table.insert(17, 'SG分析描述', '')
#    new_table.insert(18, 'SG执行结果', '')
#    new_table.insert(19, 'Enno分析描述', '')
#    new_table.insert(20, 'Enno执行结果', '')
#    new_table.insert(21, 'Unnamed', '')
#else:
#    print("后续描述已经存在")
#print("after preprocessing xlsx:\n")
#print(new_table)

if 'owner' not in old_table.columns:
    old_table.insert(15, 'owner', '')
    old_table.insert(16, 'version', '')
    old_table.insert(17, 'SG分析描述', '')
    old_table.insert(18, 'SG执行结果', '')
    old_table.insert(19, 'Enno分析描述', '')
    old_table.insert(20, 'Enno执行结果', '')
    old_table.insert(21, 'Unnamed', '')
else:
    print("后续描述已经存在")
print("after preprocessing xlsx:\n")
print(old_table)

#新表预处理，需要对列索引为“result”的列进行筛选，去除值为match及pass的行
no_pass_new_table = new_table[new_table['result'] != 'match']
no_pass_new_table = no_pass_new_table[no_pass_new_table['result'] != 'pass']
print("after filter xlsx:\n")
print(no_pass_new_table)
#no_pass_new_table.to_excel("D:/Script/pythonProject/merge/3/nopass.xlsx",index=False)

##旧表预处理，需要对列索引为“result”的列进行筛选，去除值为match及pass的行
no_pass_old_table = old_table[old_table['result'] != 'match']
no_pass_old_table = no_pass_old_table[no_pass_old_table['result'] != 'pass']
print("old filter xlsx:\n")
print(no_pass_old_table)

#新表预处理，需要对列索引为“result”的列进行筛选，筛选出值为match或pass的行
pass_new_table = new_table[(new_table['result'] == 'match') | (new_table['result'] == 'pass')]
print("after filter xlsx:保留match\n")
print(pass_new_table)
pass_new_table.to_excel('D:/data/code/table/pass.xlsx',index=False)

# 旧表预处理，需要对列索引为“result”的列进行筛选，筛选出值为match及pass的行
pass_old_table = old_table[(old_table['result'] == 'match') | (old_table['result'] == 'pass')]
print("after filter xlsx:保留match\n")
print(pass_old_table)

#去除no_pass_old_table中的重复的行
no_pass_old_table = no_pass_old_table.drop_duplicates()

# 基于两张表格前7列、11列到十4列的数据，若相同，则将旧表的前7列，和新表的第九列和第十列进行合并
#df_merged = pd.merge(new_table, old_table, how='left',left_on=new_table.columns[0:6].tolist() + new_table.columns[10:14].tolist(),right_on=old_table.columns[0:8].tolist() + old_table.columns[10:16].tolist(),on=['enno_msgid', 'sg_rule', 'file_name', 'enno_line_num', 'sg_line_num', 'obj_list', 'result', 'running_flag', 'unmatch_reason','test_name','e_severity','s_severity'])
df_merged = pd.merge(no_pass_new_table, no_pass_old_table, how='left',on=['enno_msgid', 'sg_rule', 'file_name', 'enno_line_num', 'sg_line_num', 'obj_list', 'result','test_name','e_severity','s_severity'])
#打印df_merged的列索引
print("merge后的列索引为\n",df_merged.columns)
df_merged.to_excel('D:/data/code/table/merge.xlsx',index=False)

#删除列索引为is_new_y的列
df_merged = df_merged.drop(columns=['is_new_y'])
#更改列索引is_analysis_x的类型为str
df_merged['is_analysis_x'] = df_merged['is_analysis_x'].astype(str)
df_merged['is_analysis_y'] = df_merged['is_analysis_y'].astype(str)
df_merged['diff_basis_x'] = df_merged['diff_basis_x'].astype(str)
df_merged['diff_basis_y'] = df_merged['diff_basis_y'].astype(str)
df_merged = df_merged.replace('nan','')

#对比is_analysis_x和is_analysis_y是否相同，若is_analysis_x不为空且不同则在is_analysis_x填入is_analysis_x和is_analysis_y的值中间用“？”相连，若相同则在is_analysis_x填入is_analysis_y的值
#df_merged['is_analysis_x'] = df_merged.apply(lambda row: row['is_analysis_x'] if row['is_analysis_x'] == row['is_analysis_y'] else row['is_analysis_x'] + '？' +row['is_analysis_y'], axis=1)
df_merged['is_analysis_x'] = df_merged.apply(lambda row: row['is_analysis_x'] + '？' + row['is_analysis_y'] if row['is_analysis_x'] and row['is_analysis_x'] != row['is_analysis_y'] else row['is_analysis_y'],axis=1)

# #对比diff_basis_x和diff_basis_y是否相同，若不同则在diff_basis_x填入diff_basis_x和diff_basis_y的值中间用“？”相连，若相同则在diff_basis_x填入diff_basis_y的值
#df_merged['diff_basis_x'] = df_merged.apply(lambda row: row['diff_basis_x'] if row['diff_basis_x'] == row['diff_basis_y'] else row['diff_basis_x'] + '？' + row['diff_basis_y'], axis=1)
df_merged['diff_basis_x'] = df_merged.apply(lambda row: row['diff_basis_x'] + '？' + row['diff_basis_y'] if row['diff_basis_x'] and row['diff_basis_x'] != row['diff_basis_y'] else row['diff_basis_y'],axis=1)


print("merge后列索引为\n", df_merged.columns)


# 删除列索引为is_analysis_y和diff_basis_y的列
df_merged = df_merged.drop(columns=['is_analysis_y', 'diff_basis_y'])

#删除列索引为running_flag_y，unmatch_reason_y
df_merged = df_merged.drop(columns=['running_flag_y', 'unmatch_reason_y'])

#将列索引is_analysis_x类型转换为整型
#df_merged['is_analysis_x'] = df_merged['is_analysis_x'].replace(1.0, 1)
#df_merged['is_analysis_x'] = df_merged['is_analysis_x'].replace(7.0, 7)

# 打印df_merged的列索引
print("merge后删除列索引为\n", df_merged.columns)


#将df_merged和pass_new_table进行合并，两者的所有数据都保留下来
df_merged = pd.merge(df_merged, pass_new_table, how='outer')


#以file_name的列索引按照字母顺序排列
#df_merged = df_merged.sort_values(by='file_name')
# 将合并后的数据写入新的csv文件
df_merged.to_excel('D:/data/code/table/merged_file.xlsx', index=False)
