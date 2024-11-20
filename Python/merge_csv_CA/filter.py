import os
import re

#查找指定文件夹里面所有以file_name开头的文件，赋值给files
def file_filter(directory,file_name):
    try:
        # 先获取指定目录下所有文件，避免多次调用os.listdir
        files = os.listdir(directory)
        
        # 定义正则表达式，匹配以file_name变量开头且以.xlsx结尾的文件
        pattern = re.compile(rf"^{re.escape(file_name)}.*\.xlsx$")

        # 使用列表推导式过滤出符合条件的文件
        file_filter = [file for file in files if pattern.match(file)]

        return file_filter
    
    except FileNotFoundError:
        print(f"错误：目录 {directory} 不存在。")
        return []
    except OSError as e:
        print(f"操作错误：{e}")
        return []



def main():
    #模式选择，选择指定文件或者自动查找
    mode = input("模式选择：1.指定文件 2.自动查找\n")
    if mode == "1":
        setup_new = input("请输入setup_new文件名：")
        setup_old = input("请输入setup_old文件名：")
        #打印setup_new和setup_old
        print("setup_new:",setup_new)
        print("setup_old:",setup_old)
    elif mode == "2":    
        #find setup files
        setup_files = file_filter(r"d:\data\CODE\merge","setup")
        #setup_files比大小
        print(sorted(setup_files))

        #赋值seup_new和setup_old
        setup_new = setup_files[1]
        setup_old = setup_files[0]

        #打印setup_new和setup_old
        print("setup_new:",setup_new)
        print("setup_old:",setup_old)
    else:
        print("输入错误，请重新输入！")

if __name__ == "__main__":
    main()