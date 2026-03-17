# 说明文件: 12_import_export_notes.md
# 对应脚本: scripts/12_import_export.tcl
# 功能描述: HyperMesh 导入导出 - HM文件、OptiStruct FEM

## 保存和读取 HM 文件（batch 和 GUI 均可）

```tcl
# 保存
*writefile "C:/path/to/model.hm" 1

# 读取
*readfile "C:/path/to/model.hm" 0 0 0
```

## 导出到求解器格式（仅 GUI 模式）

```tcl
# 获取模板路径
set tpl_dir [hm_info -appinfo SPECIFIEDPATH TEMPLATES_DIR]
set os_tpl  [file join $tpl_dir "feoutput" "optistruct" "optistruct"]

# 加载模板
*templatefileset $os_tpl

# 导出
*feoutputwithdata $os_tpl "output.fem" 0 0 1 1 0
```

## 从求解器文件导入（仅 GUI 模式）

```tcl
*feinputwithdata2 $os_tpl "input.fem" 0 0 0 0 0 0 0
```

## 常用模板路径

```
C:/a/Altair/2023/hwdesktop/templates/feoutput/
├── optistruct/optistruct   ← OptiStruct (.fem)
├── nastran/nastran         ← Nastran (.bdf/.dat)
├── abaqus/abaqus           ← Abaqus (.inp)
├── ls-dyna/ls-dyna         ← LS-DYNA (.k)
└── radioss/radioss         ← Radioss
```

## ⚠️ 踩坑记录

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| `*templatefileset` FatalError | batch 模式不支持 | 只在 GUI 中使用 |
| `*feoutputwithdata` FatalError | batch 模式不支持 | 只在 GUI 中使用 |
| `*writefile` 报 File operation error | 路径含中文（如桌面路径） | 使用纯英文路径 |
| `hm_info -appinfo SPECIFIEDPATH` FatalError | batch 模式不支持 | 直接写绝对路径 |
