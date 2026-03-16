# HyperMesh 二次开发学习日志

> 创建时间：2026-03-16  
> 目标：系统掌握 HyperMesh TCL/Python 二次开发能力

---

## 学习路线总览

```
阶段一：环境 & 基础        （Week 1-2）
阶段二：TCL 脚本核心       （Week 3-5）
阶段三：HyperMesh API      （Week 6-9）
阶段四：Python 集成        （Week 10-12）
阶段五：实战项目           （Week 13-16）
```

---

## 阶段一：环境搭建 & 基础认知

### 1.1 HyperMesh 脚本环境

- **版本：HyperMesh 2023**
- 内置 TCL/TK 解释器版本：**TCL 8.5.9**
- 内置 Python 版本：**Python 3.9**
- 脚本入口：`View → Command Window` 或 `Tools → Script`
- 脚本文件扩展名：`.tcl`（TCL）/ `.py`（Python）
- Python 路径：`安装目录\altair\hwdesktop\hw\python\win64\python.exe`
- 2023 新特性：支持 HyperMesh Automation（REST API 模式）、改进的 Python hm 模块

### 1.2 开发工具推荐

| 工具 | 用途 |
|------|------|
| VS Code + TCL 插件（tcl-lang） | TCL 脚本编写、语法高亮 |
| VS Code + Python 插件 | Python 脚本编写 |
| HyperMesh Command Window | 实时调试（支持 TCL/Python 切换） |
| HyperMesh Message Log | 错误输出查看（View → Message Log） |
| Notepad++ | 轻量编辑备用 |

> **2023 版 Command Window 切换语言：**
> Command Window 右上角下拉菜单可在 TCL / Python 之间切换

### 1.3 第一个脚本

脚本路径：`scripts/01_hello_hypermesh.tcl`

**运行方式：** HyperMesh Command Window 输入：
```tcl
source {C:/Users/13378/Desktop/HyperMesh-Dev/scripts/01_hello_hypermesh.tcl}
```

**脚本功能：**
1. 用 `hm_entitylist` 获取节点/单元/组件 ID 列表，`llength` 计数
2. 遍历组件列表，用 `hm_getvalue` 读取组件名称
3. 用 `*createnode` 创建 4 个节点（100×100 正方形）
4. 回读坐标验证创建结果

**踩坑记录：**

| 错误 | 原因 | 正确写法 |
|------|------|----------|
| `hm_entityinfo count nodes 0` | TCL 8.5.9 不支持此语法 | `llength [hm_entitylist nodes id]` |
| `puts "[ Component List ]"` | `[]` 在 TCL 中是命令替换符，会尝试执行括号内内容 | 改用 `---` 或 `{}` 包裹 |

**TCL 字符串规则（重要）：**
```tcl
puts "hello $var"     ;# 会解析变量 $var 和命令 []
puts {hello $var}     ;# 原样输出，不解析任何内容
puts "--- title ---"  ;# 安全，不含特殊符号
```

---

## 阶段二：TCL 脚本核心语法

### 2.1 基础语法

> **注意：** HyperMesh TCL 8.5.9 中 `[ ]` 是命令替换符，在字符串里使用时需特别小心。

```tcl
# 变量
set name "HyperMesh"
set version 2023

# 字符串拼接
set msg "软件：$name 版本：$version"
puts $msg

# 列表
set items {node element component}
foreach item $items {
    puts $item
}

# 条件判断
if {$version >= 2021} {
    puts "支持Python"
} else {
    puts "仅支持TCL"
}

# 循环
for {set i 0} {$i < 10} {incr i} {
    puts "第 $i 次"
}

# 过程（函数）
proc greet {name} {
    return "Hello, $name"
}
puts [greet "Engineer"]
```

### 2.2 文件操作

```tcl
# 读取文件
set fid [open "C:/data/input.txt" r]
while {[gets $fid line] >= 0} {
    puts $line
}
close $fid

# 写入文件
set fid [open "C:/data/output.txt" w]
puts $fid "写入内容"
close $fid
```

### 2.3 字符串处理

```tcl
set str "HyperMesh_2023_Model"
# 分割
set parts [split $str "_"]
# 长度
string length $str
# 查找
string first "2023" $str
# 替换
string map {"2023" "2024"} $str
```

---

## 阶段三：HyperMesh TCL API

### 3.1 核心命令体系

HyperMesh TCL 命令分两类：
- `*command`：执行操作（有副作用，修改模型）
- `hm_command`：查询信息（只读）

### 3.2 实体操作

> **语法说明（TCL 8.5.9 实测）：**
> - 查询实体数量：`llength [hm_entitylist nodes id]`（`hm_entityinfo` 在此版本语法不同，建议避免使用）
> - 获取属性值：`hm_getvalue node id=1 dataname=x`
> - 所有修改模型的操作用 `*command` 前缀

#### 节点（Node）

```tcl
# 创建节点
*createnode 0.0 0.0 0.0 0 0 0

# 标记节点
*createmark nodes 1 "all"          ;# 标记所有节点
*createmark nodes 1 1 2 3          ;# 标记指定ID节点
*createmark nodes 1 "by id" 1 10   ;# 标记ID范围

# 查询节点数量
set count [hm_entityinfo count nodes 1]

# 获取节点坐标
set x [hm_getvalue node id=1 dataname=x]
set y [hm_getvalue node id=1 dataname=y]
set z [hm_getvalue node id=1 dataname=z]

# 移动节点
*nodesmove 1 1 0.0 0.0 10.0
```

#### 单元（Element）

```tcl
# 创建四边形单元
*createelement 1 "quad4" 1 2 3 4

# 标记单元
*createmark elems 1 "all"

# 查询单元数量
set count [hm_entityinfo count elems 1]

# 获取单元节点
set nodes [hm_getvalue elem id=1 dataname=nodes]

# 删除单元
*createmark elems 1 5 6 7
*deletemark elems 1
```

#### 组件（Component）

```tcl
# 创建组件
*createentity comps name="Shell_Part"

# 设置当前组件
*setcurrentcollector comps "Shell_Part"

# 获取组件ID
set comp_id [hm_getvalue comp name="Shell_Part" dataname=id]

# 遍历所有组件
set comp_list [hm_entitylist comps id]
foreach cid $comp_list {
    set cname [hm_getvalue comp id=$cid dataname=name]
    puts "组件 $cid: $cname"
}
```

### 3.3 材料与属性

```tcl
# 创建材料
*createentity mats name="Steel"
*setvalue mats name="Steel" status=1 cardimage="MAT1"
*setvalue mats name="Steel" status=1 id=1 E=210000.0 NU=0.3 RHO=7.85e-9

# 创建属性
*createentity props name="Shell_Prop"
*setvalue props name="Shell_Prop" status=1 cardimage="PSHELL"
*setvalue props name="Shell_Prop" status=1 MID=1 T=1.5

# 将属性赋给组件
*createmark comps 1 "Shell_Part"
*assignproperty comps 1 "Shell_Prop"
```

### 3.4 模型导入导出

```tcl
# 导入模型
*readfile "C:/models/input.hm" 0 0 0

# 导出为 Nastran
*feoutputwithdata "C:/output/model.bdf" 1 0 0 1 1 1

# 导出为 Abaqus
*feoutputwithdata "C:/output/model.inp" 1 0 0 1 1 1

# 保存 HM 文件
*writefile "C:/output/model.hm" 1
```

### 3.5 网格操作

```tcl
# 2D 自动网格
*createmark surfs 1 "all"
*automesh 1 2 1 0 0

# 设置网格尺寸
*createmark surfs 1 "all"
*automesh 1 2 1 0 0
hm_framework setmeshsize 5.0

# 检查网格质量
*createmark elems 1 "all"
*elementtestjacobian elems 1 0.7 2 1

# 节点合并
*createmark nodes 1 "all"
*mergenodes 1 0.01
```

---

## 阶段四：Python 集成开发

### 4.1 环境配置

HyperMesh 2021+ 支持 Python，路径：
```
安装目录/altair/hwdesktop/hw/python/win64/python.exe
```

在 HyperMesh 中运行 Python：
```
Tools → Script → 选择 .py 文件
```

### 4.2 Python 调用 HyperMesh API

```python
import hm

# 获取模型信息
node_count = hm.entityinfo("nodes", "count")
print(f"节点数: {node_count}")

# 创建节点
hm.createnode(0, 0, 0)
hm.createnode(100, 0, 0)
hm.createnode(100, 100, 0)

# 标记并操作
hm.createmark("nodes", 1, "all")
count = hm.entityinfo("nodes", "count", 1)
print(f"标记节点数: {count}")
```

### 4.3 Python 读写外部数据

```python
import hm
import csv
import os

def import_nodes_from_csv(filepath):
    """从CSV导入节点坐标"""
    with open(filepath, 'r') as f:
        reader = csv.reader(f)
        next(reader)  # 跳过表头
        for row in reader:
            x, y, z = float(row[0]), float(row[1]), float(row[2])
            hm.createnode(x, y, z)
    print("节点导入完成")

def export_nodes_to_csv(filepath):
    """导出节点坐标到CSV"""
    hm.createmark("nodes", 1, "all")
    node_ids = hm.getmark("nodes", 1)
    with open(filepath, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['ID', 'X', 'Y', 'Z'])
        for nid in node_ids:
            x = hm.getvalue("node", f"id={nid}", "x")
            y = hm.getvalue("node", f"id={nid}", "y")
            z = hm.getvalue("node", f"id={nid}", "z")
            writer.writerow([nid, x, y, z])
    print(f"已导出到: {filepath}")
```

### 4.4 GUI 开发（Tkinter）

```python
import tkinter as tk
import hm

def create_gui():
    root = tk.Tk()
    root.title("HyperMesh 工具箱")
    root.geometry("400x300")

    def get_model_info():
        n = hm.entityinfo("nodes", "count")
        e = hm.entityinfo("elems", "count")
        info_label.config(text=f"节点: {n}  单元: {e}")

    tk.Button(root, text="获取模型信息", command=get_model_info,
              width=20, height=2).pack(pady=20)
    
    info_label = tk.Label(root, text="点击按钮获取信息", font=("Arial", 12))
    info_label.pack()

    root.mainloop()

create_gui()
```

---

## 阶段五：实战项目

### 项目一：批量重命名组件

```tcl
# 按规则批量重命名组件
proc rename_comps_by_rule {prefix} {
    set comp_list [hm_entitylist comps id]
    set idx 1
    foreach cid $comp_list {
        set new_name "${prefix}_${idx}"
        *renameentity comps $cid $new_name
        puts "组件 $cid 重命名为: $new_name"
        incr idx
    }
    puts "完成，共重命名 [llength $comp_list] 个组件"
}
rename_comps_by_rule "PART"
```

### 项目二：网格质量批量检查报告

```tcl
proc mesh_quality_report {output_file} {
    set fid [open $output_file w]
    puts $fid "网格质量报告"
    puts $fid "生成时间: [clock format [clock seconds]]"
    puts $fid "=========================="
    
    # 雅可比检查
    *createmark elems 1 "all"
    set total [hm_entityinfo count elems 1]
    puts $fid "总单元数: $total"
    
    # 长宽比检查
    *createmark elems 1 "all"
    *elementtestaspectratio elems 1 5.0 2 1
    set failed [hm_entityinfo count elems 1]
    puts $fid "长宽比>5 的单元数: $failed"
    
    close $fid
    puts "报告已保存: $output_file"
}
mesh_quality_report "C:/output/quality_report.txt"
```

### 项目三：参数化建模

```tcl
# 参数化创建矩形板并网格划分
proc create_plate {length width thickness mesh_size comp_name} {
    # 创建组件
    *createentity comps name=$comp_name
    *setcurrentcollector comps $comp_name
    
    # 创建4个节点
    *createnode 0 0 0 0 0 0
    *createnode $length 0 0 0 0 0
    *createnode $length $width 0 0 0 0
    *createnode 0 $width 0 0 0 0
    
    # 获取最新节点ID（简化处理）
    set n [hm_entityinfo count nodes 0]
    set n1 [expr {$n - 3}]
    set n2 [expr {$n - 2}]
    set n3 [expr {$n - 1}]
    set n4 $n
    
    # 创建曲面并网格
    *createplane nodes $n1 $n2 $n3 $n4
    
    puts "矩形板创建完成: ${length}x${width}x${thickness}, 网格尺寸: ${mesh_size}"
}

create_plate 500 300 2.0 10 "Bottom_Plate"
```

---

## 常用 API 速查表

### 实体查询

| 命令 | 说明 |
|------|------|
| `hm_entityinfo count nodes 1` | 获取标记集1中节点数量 |
| `hm_entitylist comps id` | 获取所有组件ID列表 |
| `hm_getvalue node id=1 dataname=x` | 获取节点属性值 |
| `hm_entityinfo exists node id=5` | 检查实体是否存在 |

### 标记操作

| 命令 | 说明 |
|------|------|
| `*createmark nodes 1 "all"` | 标记所有节点 |
| `*createmark elems 1 1 2 3` | 标记指定ID单元 |
| `*clearmark nodes 1` | 清除标记 |
| `hm_getmark nodes 1` | 获取标记列表 |

### 模型操作

| 命令 | 说明 |
|------|------|
| `*deletemark nodes 1` | 删除标记实体 |
| `*mergenodes 1 0.01` | 合并重复节点 |
| `*renameentity comps 1 "NewName"` | 重命名实体 |
| `*writefile "path.hm" 1` | 保存模型 |

---

## 学习资源

- **官方文档：** HyperMesh Help → Scripting Guide
- **TCL 官方：** https://www.tcl.tk/doc/
- **Altair 社区：** https://community.altair.com
- **本地帮助：** `安装目录/help/hwdesktop/`

---

## 学习进度记录

| 日期 | 内容 | 状态 | 备注 |
|------|------|------|------|
| 2026-03-16 | 创建学习日志 | ✅ | - |
| 2026-03-16 | 阶段一：环境搭建 | ✅ | TCL 8.5.9，Command Window source 运行 |
| 2026-03-16 | 01_hello_hypermesh.tcl | ✅ | 运行成功，踩坑 hm_entityinfo 和 [] 问题 |
| | 阶段二：TCL 基础语法 | ⬜ | |
| | 阶段三：HyperMesh API | ⬜ | |
| | 阶段四：Python 集成 | ⬜ | |
| | 阶段五：实战项目 | ⬜ | |

---

*持续更新中...*
