# 说明文件: 07_elements_notes.md
# 对应脚本: scripts/07_elements.tcl
# 功能描述: HyperMesh 单元操作 - 创建、查询、标记、质量检查、删除

## 创建单元（两步法）

```tcl
# 第一步：把节点ID放入列表
*createlist nodes 1 $n1 $n2 $n3 $n4

# 第二步：创建单元（不直接传节点ID）
*createelement 104 1 1 1   ;# quad4
*createelement 103 1 1 1   ;# tria3
```

**单元 config 编号（HyperMesh 2023 实测）：**

| config | 类型 | 节点数 |
|--------|------|--------|
| 103 | tria3 | 3 |
| 104 | quad4 | 4 |
| 108 | tetra4 | 4 |
| 110 | hexa8 | 8 |

## 查询单元属性

```tcl
set cfg    [hm_getvalue elem id=1 dataname=config]   ;# 类型编号
set enodes [hm_getvalue elem id=1 dataname=nodes]    ;# 连接节点列表
set size   [hm_getelementsize 1]                     ;# 单元尺寸
```

## 标记单元

```tcl
*createmark elems 1 "all"              ;# 标记所有
*createmark elems 1 1 2 3             ;# 按ID
*createmark elems 1 "by config" 104   ;# 按类型（quad4）
*clearmark elems 1
```

## 质量检查

```tcl
# hm_getelemcheckvalues <mark_id> <维度> <检查项>
# 维度：2=2D单元，3=3D单元
# 返回：id1 val1 id2 val2 ...
*createmark elems 2 "all"
set asp [hm_getelemcheckvalues 2 2 aspect]   ;# 长宽比
set skw [hm_getelemcheckvalues 2 2 skew]     ;# 偏斜角
set jac [hm_getelemcheckvalues 2 2 jacobian] ;# 雅可比
set wrp [hm_getelemcheckvalues 2 2 warpage]  ;# 翘曲度
set tap [hm_getelemcheckvalues 2 2 taper]    ;# 锥度
```

## 删除单元

```tcl
# 单元删除用 *deletemark（与节点不同！）
*createmark elems 1 3
*deletemark elems 1
```

## 踩坑记录

| 问题 | 解决方案 |
|------|---------|
| `*createelement 103 1 n1 n2 n3` 报错 | 先 `*createlist nodes 1 n1 n2 n3`，再 `*createelement 103 1 1 1` |
| `*deleteidrange elems 1` 无效 | 单元删除用 `*deletemark elems 1` |
| `hm_getelemcheckvalues elems 1 aspect` 报错 | 用 mark_id=2，语法：`hm_getelemcheckvalues 2 2 aspect` |
