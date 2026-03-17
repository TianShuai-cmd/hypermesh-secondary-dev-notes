# =============================================================
# 说明文件: 06_nodes_notes.md
# 对应脚本: scripts/06_nodes.tcl
# 功能描述: HyperMesh 节点操作 - 创建、查询、标记、移动、合并、删除
# =============================================================

## 第一部分：创建节点

```tcl
# *createnode 参数：x y z 坐标系ID 输出ID 配置ID
# 坐标系ID=0 表示全局坐标系
*createnode 0.0   0.0   0.0  0 0 0
*createnode 100.0 0.0   0.0  0 0 0
```

---

## 第二部分：查询节点属性

```tcl
# hm_getvalue 读取实体的单个属性
set x [hm_getvalue node id=1 dataname=x]
set y [hm_getvalue node id=1 dataname=y]
set z [hm_getvalue node id=1 dataname=z]

# 遍历所有节点
foreach nid [hm_entitylist nodes id] {
    set x [hm_getvalue node id=$nid dataname=x]
    puts "Node $nid: ($x, ...)"
}
```

---

## 第三部分：标记节点（Mark 机制）

Mark 是 HyperMesh 的核心选择机制，类似"选中"操作。
所有批量操作（移动、删除等）都需要先标记再执行。

```tcl
*createmark nodes 1 "all"          ;# 标记所有节点到集合1
*createmark nodes 1 1 2 3          ;# 标记指定ID节点
*createmark nodes 1 "by id" 1 3    ;# 标记ID范围 1~3
*clearmark nodes 1                 ;# 清除标记集合1

hm_getmark nodes 1                 ;# 获取标记集合1中的ID列表
```

> **注意：** 标记集合有1和2两个，通常用1，需要临时保存时用2

---

## 第四部分：移动节点

```tcl
# *nodesmove 参数：标记集合ID 坐标系ID dx dy dz
# 将标记集合中的所有节点平移 (dx, dy, dz)
*createmark nodes 1 5
*nodesmove 1 0 0.0 0.0 10.0   ;# 将节点5沿Z轴移动10
```

---

## 第五部分：按坐标范围查找节点

```tcl
# 查找距离某点半径范围内的节点
# *createmark nodes 1 "by sphere" 中心x 中心y 中心z 半径
*createmark nodes 1 "by sphere" 0.0 0.0 0.0 10.0
set near_nodes [hm_getmark nodes 1]
```

---

## 第六部分：合并重复节点

```tcl
# *mergenodes 参数：标记集合ID 容差
# 将距离小于容差的节点合并为一个
*createmark nodes 1 "all"
*mergenodes 1 0.01   ;# 容差 0.01，距离小于此值的节点合并
```

---

## 第七部分：删除节点

```tcl
# 先标记，再删除
*createmark nodes 1 5
*deletemark nodes 1
```

---

## 知识点总结

| 命令 | 说明 |
|------|------|
| `*createnode x y z 0 0 0` | 创建节点 |
| `hm_getvalue node id=N dataname=x` | 读取节点坐标 |
| `*createmark nodes 1 "all"` | 标记所有节点 |
| `*createmark nodes 1 1 2 3` | 按ID标记节点 |
| `*createmark nodes 1 "by id" 1 3` | 按ID范围标记 |
| `*createmark nodes 1 "by sphere" cx cy cz r` | 按坐标范围标记 |
| `hm_getmark nodes 1` | 获取标记列表 |
| `*clearmark nodes 1` | 清除标记 |
| `*nodesmove 1 0 dx dy dz` | 平移标记节点 |
| `*mergenodes 1 tolerance` | 合并重复节点 |
| `*deletemark nodes 1` | 删除标记节点 |

---

## Mark 机制说明

HyperMesh 的操作流程通常是：
```
1. *createmark 选中目标实体
2. 执行操作命令（移动、删除、网格等）
3. *clearmark 清除标记（可选）
```

这和手动操作时"先选中再操作"的逻辑完全一致。
