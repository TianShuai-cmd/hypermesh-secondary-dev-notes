# HyperMesh TCL/Python 二次开发 - 完整学习计划

> 制定日期：2026-03-16
> 目标：从零掌握 HyperMesh 二次开发，能独立完成自动化建模、网格处理、批量操作脚本
> 环境：HyperMesh 2023 / TCL 8.5.9 / Python 3.9

---

## 总体规划

| 阶段 | 主题 | 周期 | 脚本数量 |
|------|------|------|----------|
| 阶段一 | 环境 & 基础认知 | Week 1 | 1 个 |
| 阶段二 | TCL 核心语法 | Week 2-3 | 4 个 |
| 阶段三 | HyperMesh TCL API | Week 4-7 | 8 个 |
| 阶段四 | Python 集成开发 | Week 8-10 | 4 个 |
| 阶段五 | 综合实战项目 | Week 11-14 | 3 个 |
| **合计** | | **14 周** | **20 个脚本** |

---

## 阶段一：环境 & 基础认知（Week 1）

**目标：** 跑通第一个脚本，理解 HyperMesh 脚本运行机制

| 编号 | 内容 | 脚本 | 状态 |
|------|------|------|------|
| 1-1 | HyperMesh 2023 脚本运行方式（Command Window / source） | - | ✅ |
| 1-2 | TCL 8.5.9 基础规则（字符串、[] 陷阱、变量） | - | ✅ |
| 1-3 | 第一个脚本：读取模型信息 + 创建节点 | `01_hello_hypermesh.tcl` | ✅ |

**阶段一完成标准：** 能独立运行脚本，理解输出结果

---

## 阶段二：TCL 核心语法（Week 2-3）

**目标：** 掌握 TCL 语法，能编写逻辑完整的脚本

| 编号 | 内容 | 脚本 | 状态 |
|------|------|------|------|
| 2-1 | 变量、列表、字典、字符串操作 | `02_tcl_basics.tcl` | ⬜ |
| 2-2 | 条件判断（if/switch）、循环（for/foreach/while） | `03_tcl_control_flow.tcl` | ⬜ |
| 2-3 | 过程（proc）定义与调用、参数传递、返回值 | `04_tcl_proc.tcl` | ⬜ |
| 2-4 | 文件读写、错误处理（catch/error） | `05_tcl_file_io.tcl` | ⬜ |

**阶段二完成标准：** 能独立编写包含循环、函数、文件操作的 TCL 脚本

**重点知识：**
```tcl
# 列表操作
set lst {a b c d}
lindex $lst 0        ;# 取第0个元素
lappend lst e        ;# 追加元素
llength $lst         ;# 列表长度
lrange $lst 1 3      ;# 切片

# 字典操作（TCL 8.5+）
dict set d key value
dict get $d key

# 错误处理
if {[catch {可能出错的命令} err]} {
    puts "Error: $err"
}
```

---

## 阶段三：HyperMesh TCL API（Week 4-7）

**目标：** 掌握 HyperMesh 核心 API，能操作模型中的各类实体

### Week 4：节点与单元操作

| 编号 | 内容 | 脚本 | 状态 |
|------|------|------|------|
| 3-1 | 节点：创建、查询、移动、删除 | `06_nodes.tcl` | ⬜ |
| 3-2 | 单元：创建四边形/三角形单元、查询节点连接关系 | `07_elements.tcl` | ⬜ |

### Week 5：组件与属性

| 编号 | 内容 | 脚本 | 状态 |
|------|------|------|------|
| 3-3 | 组件：创建、重命名、遍历、设置当前组件 | `08_components.tcl` | ⬜ |
| 3-4 | 材料与属性：创建 MAT1/PSHELL，赋给组件 | `09_material_property.tcl` | ⬜ |

### Week 6：网格操作

| 编号 | 内容 | 脚本 | 状态 |
|------|------|------|------|
| 3-5 | 2D 自动网格划分、网格尺寸控制 | `10_mesh_2d.tcl` | ⬜ |
| 3-6 | 网格质量检查（雅可比、长宽比、翘曲度） | `11_mesh_quality.tcl` | ⬜ |

### Week 7：模型导入导出

| 编号 | 内容 | 脚本 | 状态 |
|------|------|------|------|
| 3-7 | 导入 HM/CAD 文件，导出 Nastran BDF / Abaqus INP | `12_import_export.tcl` | ⬜ |
| 3-8 | 标记（Mark）机制深入：按条件筛选实体 | `13_mark_filter.tcl` | ⬜ |

**阶段三完成标准：** 能用脚本完成建模、网格、导出全流程

**核心 API 速查：**
```tcl
# 实体查询
hm_entitylist nodes id              ;# 获取所有节点ID
hm_getvalue node id=1 dataname=x    ;# 读取属性
hm_entitylist comps id              ;# 获取所有组件ID

# 标记操作
*createmark nodes 1 "all"           ;# 标记所有节点
*createmark elems 1 1 2 3           ;# 标记指定ID
*clearmark nodes 1                  ;# 清除标记

# 节点操作
*createnode x y z 0 0 0             ;# 创建节点
*nodesmove 1 1 dx dy dz             ;# 移动节点
*deletemark nodes 1                 ;# 删除标记节点

# 组件操作
*createentity comps name="Part1"
*setcurrentcollector comps "Part1"
```

---

## 阶段四：Python 集成开发（Week 8-10）

**目标：** 用 Python 调用 HyperMesh API，结合外部数据处理能力

| 编号 | 内容 | 脚本 | 状态 |
|------|------|------|------|
| 4-1 | Python hm 模块基础：与 TCL API 的对应关系 | `14_python_basics.py` | ⬜ |
| 4-2 | 读取 CSV/Excel 数据，批量创建节点/单元 | `15_python_csv_import.py` | ⬜ |
| 4-3 | 导出模型数据到 CSV/JSON，生成报告 | `16_python_export_report.py` | ⬜ |
| 4-4 | Tkinter GUI：制作简单的工具面板 | `17_python_gui.py` | ⬜ |

**阶段四完成标准：** 能用 Python 读取外部数据驱动建模，并输出结构化报告

**Python vs TCL 对照：**
```python
import hm

# TCL: hm_entitylist nodes id
node_ids = hm.entitylist("nodes", "id")

# TCL: hm_getvalue node id=1 dataname=x
x = hm.getvalue("node", "id=1", "x")

# TCL: *createnode 0 0 0 0 0 0
hm.createnode(0, 0, 0)
```

---

## 阶段五：综合实战项目（Week 11-14）

**目标：** 综合运用所学，完成有实际价值的自动化工具

| 编号 | 项目名称 | 内容 | 脚本 | 状态 |
|------|----------|------|------|------|
| 5-1 | 批量网格质量报告 | 扫描模型所有组件，输出质量检查报告到 TXT | `18_quality_report.tcl` | ⬜ |
| 5-2 | 参数化矩形板建模 | 输入长宽厚和网格尺寸，自动完成建模+网格+导出 | `19_parametric_plate.tcl` | ⬜ |
| 5-3 | 模型信息提取工具 | GUI 工具，一键提取模型统计信息并保存 CSV | `20_model_info_tool.py` | ⬜ |

**阶段五完成标准：** 3 个项目全部跑通，能根据需求修改参数

---

## 学习建议

1. **每个脚本先跑通，再看注释理解原理**
2. **遇到报错先看 Message Log，再查踩坑记录**
3. **每学完一个脚本，在进度表打勾**
4. **有疑问随时问 Fubar，我会同步更新文档**

---

## 进度追踪

| 脚本 | 名称 | 完成日期 | 备注 |
|------|------|----------|------|
| 01_hello_hypermesh.tcl | 模型信息 + 创建节点 | 2026-03-16 | 踩坑：hm_entityinfo、[] |
| 02_tcl_basics.tcl | TCL 基础语法 | | |
| 03_tcl_control_flow.tcl | 条件与循环 | | |
| 04_tcl_proc.tcl | 过程与函数 | | |
| 05_tcl_file_io.tcl | 文件读写 | | |
| 06_nodes.tcl | 节点操作 | | |
| 07_elements.tcl | 单元操作 | | |
| 08_components.tcl | 组件操作 | | |
| 09_material_property.tcl | 材料与属性 | | |
| 10_mesh_2d.tcl | 2D 网格划分 | | |
| 11_mesh_quality.tcl | 网格质量检查 | | |
| 12_import_export.tcl | 导入导出 | | |
| 13_mark_filter.tcl | 标记与筛选 | | |
| 14_python_basics.py | Python 基础 | | |
| 15_python_csv_import.py | CSV 数据导入 | | |
| 16_python_export_report.py | 数据导出报告 | | |
| 17_python_gui.py | Tkinter GUI | | |
| 18_quality_report.tcl | 质量报告项目 | | |
| 19_parametric_plate.tcl | 参数化建模项目 | | |
| 20_model_info_tool.py | 模型信息工具项目 | | |
