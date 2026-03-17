# 说明文件: 10_mesh_2d_notes.md
# 对应脚本: scripts/10_mesh_2d.tcl
# 功能描述: HyperMesh 2D 网格划分 - 创建曲面、自动网格、质量检查

## 创建曲面

```tcl
# 从节点环创建曲面
*createlist nodes 1 $n1 $n2 $n3 $n4
*surfacesplineonnodesloop 1 0 0
set surf_ids [hm_entitylist surfs id]
```

## 自动网格划分（仅 GUI 模式）

```tcl
# *automesh 参数：标记集合ID 网格尺寸 网格类型
# 网格类型：1=混合 2=仅四边形 3=仅三角形
*createmark surfs 1 "all"
*automesh 1 10 1   ;# 尺寸10，混合网格
```

## 删除网格

```tcl
*createmark elems 1 "all"
*deletemark elems 1
```

## ⚠️ 重要注意事项

`*automesh` 和 `*surfacesplineonnodesloop` 需要 GUI 模式运行，在 hmbatch 中会崩溃。

**必须在 HyperMesh GUI 的 Command Window 中执行此脚本。**
