# =============================================================
# 说明文件: 01_hello_hypermesh_notes.md
# 对应脚本: scripts/01_hello_hypermesh.tcl
# 功能描述: 第一个HyperMesh脚本 - 读取模型信息并创建节点
# =============================================================

## 运行方式

```tcl
source {C:/Users/13378/Desktop/HyperMesh-Dev/scripts/01_hello_hypermesh.tcl}
```

---

## 第一部分：读取模型基本信息

```tcl
# hm_entitylist 获取所有实体的 ID 列表
# llength 统计列表元素数量
set node_ids  [hm_entitylist nodes id]
set elem_ids  [hm_entitylist elems id]
set comp_ids  [hm_entitylist comps id]

set node_count [llength $node_ids]   ;# 节点数量
set elem_count [llength $elem_ids]   ;# 单元数量
set comp_count [llength $comp_ids]   ;# 组件数量
```

---

## 第二部分：列出所有组件名称

```tcl
# 遍历组件 ID 列表，用 hm_getvalue 读取每个组件的 name 属性
foreach cid $comp_ids {
    set cname [hm_getvalue comp id=$cid dataname=name]
    puts "ID=$cid  Name=$cname"
}
```

---

## 第三部分：创建测试节点

```tcl
# *createnode 参数：x y z 坐标系ID 输出ID 配置ID
# 坐标系ID=0 表示全局坐标系，后两个参数通常填 0
*createnode 0.0   0.0   0.0  0 0 0   ;# 节点1：原点
*createnode 100.0 0.0   0.0  0 0 0   ;# 节点2：X轴方向
*createnode 100.0 100.0 0.0  0 0 0   ;# 节点3：对角
*createnode 0.0   100.0 0.0  0 0 0   ;# 节点4：Y轴方向
                                      ;# 四点构成 100x100 正方形
```

---

## 第四部分：验证节点坐标

```tcl
# lrange 取列表最后4个元素（刚创建的节点）
# lrange <列表> end-3 end
set last4 [lrange $all_ids end-3 end]
foreach nid $last4 {
    set x [hm_getvalue node id=$nid dataname=x]
    set y [hm_getvalue node id=$nid dataname=y]
    set z [hm_getvalue node id=$nid dataname=z]
}
```

---

## 知识点总结

| 语法 | 说明 |
|------|------|
| `hm_entitylist nodes id` | 获取所有节点 ID 列表 |
| `llength $list` | 统计列表元素数量 |
| `hm_getvalue node id=N dataname=x` | 读取节点 x 坐标 |
| `hm_getvalue comp id=N dataname=name` | 读取组件名称 |
| `*createnode x y z 0 0 0` | 在指定坐标创建节点 |
| `lrange $list end-3 end` | 取列表最后4个元素 |

---

## 踩坑记录

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `hm_entityinfo count nodes 0` 报错 | TCL 8.5.9 不支持此语法 | 改用 `llength [hm_entitylist nodes id]` |
| `puts "[ title ]"` 报错 | `[]` 在 TCL 中是命令替换符 | 改用 `puts "--- title ---"` |
| 脚本中文注释导致 proc 异常 | HyperMesh 用 GBK 读取 UTF-8 文件 | 脚本文件只用英文注释 |
