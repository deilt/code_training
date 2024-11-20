import os
import re


def filter_files(path):
    #定义正则表达式，匹配文件名以setup开头，不同的日期结尾，日期格式为YYYY_MM_DD
    pattern = re.compile(r"^setup.*(\d{4}_\d{2}_\d{2})\.xlsx$")
    #遍历指定文件夹里面的文件
    for file in os.listdir(path):
        #如果文件名匹配正则表达式
        if pattern.match(file):
            #提取文件名中的日期
            date = pattern.search(file).group(1)
            #打印文件名和日期
            print("文件：", file, "日期：", date)
#测试
filter_files(r"d:\data\CODE\merge")