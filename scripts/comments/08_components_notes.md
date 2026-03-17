# 说明文件: 08_components_notes.md
# 对应脚本: scripts/08_components.tcl
# 功能描述: HyperMesh 组件操作 - 创建、查询、重命名、移动单元、删除

## 创建和设置组件

```tcl
*collectorcreate comps Shell_Top {}    ;# 创建组件
*currentcollector comps Shell_Top      ;# 设为当前组件（新建实体归属此组件）
```

## 查询组件

```tcl
set comp_ids [hm_entitylist comps id]                    ;# 所有组件ID
set cname [hm_getvalue comp id=1 dataname=name]          ;# 按ID查名称
set cid   [hm_getvalue comp name=Shell_Top dataname=id]  ;# 按名称查ID
```

## 重命名组件

```tcl
*renamecollector comps Rib_Left Rib_Left_Renamed
```

## 移动单元到其他组件

```tcl
# *movemark：将标记的单元移动到指定组件
*createmark elems 1 $eid
set target_id [hm_getvalue comp name=Shell_Bottom dataname=id]
*movemark elems 1 comps $target_id
```

## 删除组件

```tcl
*createmark comps 1 $cid
*deletemark comps 1
```

## 踩坑记录

| 问题 | 解决方案 |
|------|---------|
| `*collectormarkmove elems 1 comps id` 报错 | 改用 `*movemark elems 1 comps id` |
