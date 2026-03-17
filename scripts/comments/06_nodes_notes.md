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

HyperMesh 2023 TCL 没有直接的节点移动命令，需要删除后重建：

```tcl
# 读取原坐标
set x [hm_getvalue node id=5 dataname=x]
set y [hm_getvalue node id=5 dataname=y]
set z [hm_getvalue node id=5 dataname=z]

# 删除原节点
*clearmark nodes 1
*createmark nodes 1 5
*deleteidrange nodes 1

# 在新坐标重建（注意：ID会变）
set new_z [expr {$z + 10.0}]
*createnode $x $y $new_z 0 0 0
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
# *equivalence nodes：合并距离小于容差的节点
# 语法：*equivalence nodes <标记集合ID> <容差>
*createmark nodes 1 "all"
*equivalence nodes 1 0.01   ;# 容差 0.01，距离小于此值的节点合并
```

---

## 第七部分：删除节点

```tcl
# *deleteidrange：HyperMesh 2023 中正确的节点删除命令
# 先标记，再删除
*clearmark nodes 1
*createmark nodes 1 5
*deleteidrange nodes 1
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
| `*deleteidrange nodes 1` | 删除标记节点（正确命令）|
| `*equivalence nodes 1 tolerance` | 合并重复节点（正确命令）|
| `*collectorcreate comps name {}` | 创建组件 |
| `*currentcollector comps name` | 设置当前组件 |

---

## 踩坑记录

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `*deletemark nodes 1` 报错 | HyperMesh 2023 不支持此命令删除节点 | 改用 `*deleteidrange nodes 1` |
| `*modent_deletebymark nodes 1` 报错 | 同上 | 改用 `*deleteidrange nodes 1` |
| `*nodesmove` 不存在 | HyperMesh 2023 无此命令 | 删除节点后在新坐标重建（ID会变）|
| `*mergenodes` 不存在 | HyperMesh 2023 无此命令 | 改用 `*equivalence nodes 1 tol` |
| `*createentity comps name="x"` 报错 | 语法不对 | 改用 `*collectorcreate comps name {}` |
| `*setcurrentcollector` 不存在 | HyperMesh 2023 无此命令 | 改用 `*currentcollector comps name` |
