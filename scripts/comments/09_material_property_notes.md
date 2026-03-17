# 说明文件: 09_material_property_notes.md
# 对应脚本: scripts/09_material_property.tcl
# 功能描述: HyperMesh 材料与属性 - 创建、设置参数、赋给组件

## 前提：加载求解器模板

```tcl
# 必须先加载模板，否则无法创建 MAT1/PSHELL 等卡片
set tpl "C:/a/Altair/2023/hwdesktop/templates/feoutput/optistruct/optistruct"
*templatefileset $tpl
```

## 创建材料（MAT1）

```tcl
*createentity mats cardimage=MAT1 name=Steel
set mid [hm_getvalue mats name=Steel dataname=id]

# 用数字字段索引设置参数（不能用属性名）
# MAT1 字段：1=E, 2=G, 3=NU, 4=RHO, 5=A, 6=TREF, 7=GE
*setvalue mats id=$mid STATUS=1 1=210000.0   ;# E（弹性模量）
*setvalue mats id=$mid STATUS=1 3=0.3        ;# NU（泊松比）
*setvalue mats id=$mid STATUS=1 4=7.85e-9    ;# RHO（密度）
```

## 创建属性（PSHELL）

```tcl
*createentity props cardimage=PSHELL name=Shell_2mm
set pid [hm_getvalue props name=Shell_2mm dataname=id]

# PSHELL 字段：1=MID1, 3=T（厚度）, 5=MID2, 7=MID3
*setvalue props id=$pid STATUS=1 3=2.0    ;# 厚度 2mm
*setvalue props id=$pid STATUS=1 1=$mid   ;# 关联材料
```

## 将属性赋给组件

```tcl
set cid [hm_getvalue comp name=Shell_Part dataname=id]
*setvalue comps id=$cid propertyid={props $pid}
```

## 踩坑记录

| 问题 | 解决方案 |
|------|---------|
| `*setvalue mats id=1 E=210000` 报错 | 用数字字段索引：`*setvalue mats id=1 STATUS=1 1=210000` |
| `*createentity mats` 报错"No user profile" | 必须先 `*templatefileset` 加载模板 |
| `hm_getvalue mats id=1 dataname=NU` 报错 | NU 不是有效 dataname，只能用 E 等少数属性名 |
