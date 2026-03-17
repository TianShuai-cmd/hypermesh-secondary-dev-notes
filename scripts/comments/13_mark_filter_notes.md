# 说明文件: 13_mark_filter_notes.md
# 对应脚本: scripts/13_mark_filter.tcl
# 功能描述: HyperMesh 标记与筛选 - 高级实体选择

## 基本标记操作

```tcl
*createmark nodes 1 "all"              ;# 标记所有节点
*createmark nodes 1 1 2 3             ;# 按ID标记
*createmark nodes 1 "by id" 1 4       ;# 按ID范围（1到4）
*createmark nodes 1 "by sphere" x y z r  ;# 按坐标范围
*clearmark nodes 1                    ;# 清除标记
hm_getmark nodes 1                    ;# 获取标记列表
```

## 按条件标记单元

```tcl
*createmark elems 1 "by config" 104          ;# 按类型（quad4）
*createmark elems 1 "by collector" $comp_id  ;# 按组件
*createmark nodes 1 "by elems" 1             ;# 标记单元关联的节点
```

## 布尔标记操作

```tcl
# 差集：mark1 = mark1 - mark2
*markdifference nodes 1 nodes 2

# 交集：mark1 = mark1 ∩ mark2
*markintersection nodes 1 nodes 2

# 并集：直接向同一 mark 追加（*markunion 不存在）
*createmark nodes 1 1 2 3
*createmark nodes 1 4 5 6   ;# 追加到 mark1
```

## 实际应用：筛选不合格单元

```tcl
*createmark elems 2 "all"
set asp [hm_getelemcheckvalues 2 2 aspect]

set bad_ids {}
foreach {eid val} $asp {
    if {$val > 5.0} { lappend bad_ids $eid }
}

if {[llength $bad_ids] > 0} {
    eval *createmark elems 1 $bad_ids
    puts "Bad elements: [hm_getmark elems 1]"
}
```

## 踩坑记录

| 问题 | 解决方案 |
|------|---------|
| `*markdifference nodes 1 2` 报错 | 需指定类型两次：`*markdifference nodes 1 nodes 2` |
| `*markunion` 不存在 | 直接向同一 mark 集合追加 `*createmark` |
| `*createmark nodes 1 "by id" 1 4` 只返回1和4 | "by id" 是范围端点，不是列表 |
