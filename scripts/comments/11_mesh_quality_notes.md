# 说明文件: 11_mesh_quality_notes.md
# 对应脚本: scripts/11_mesh_quality.tcl
# 功能描述: HyperMesh 网格质量检查 - 长宽比、偏斜、雅可比、翘曲

## 质量检查命令

```tcl
# 语法：hm_getelemcheckvalues <mark_id> <维度> <检查项>
# mark_id：标记集合编号（建议用2）
# 维度：2=2D单元，3=3D单元
# 返回：id1 val1 id2 val2 ...（字符串，用 foreach {id val} 解析）

*createmark elems 2 "all"
set asp [hm_getelemcheckvalues 2 2 aspect]    ;# 长宽比（理想=1，阈值<5）
set skw [hm_getelemcheckvalues 2 2 skew]      ;# 偏斜角（理想=0，阈值<60°）
set wrp [hm_getelemcheckvalues 2 2 warpage]   ;# 翘曲度（理想=0，阈值<15°）
set jac [hm_getelemcheckvalues 2 2 jacobian]  ;# 雅可比（理想=1，阈值>0.6）
set tap [hm_getelemcheckvalues 2 2 taper]     ;# 锥度（理想=0，阈值<0.5）
```

## 解析结果并筛选不合格单元

```tcl
set bad_elems {}
foreach {eid val} $asp {
    if {$val > 5.0} {
        lappend bad_elems $eid
        puts "FAIL: Elem $eid aspect=$val"
    }
}
```

## 输出质量报告到文件

```tcl
set fid [open "quality_report.txt" w]
puts $fid "Mesh Quality Report"
foreach {eid val} $asp {
    set status [expr {$val > 5.0 ? "FAIL" : "PASS"}]
    puts $fid "Elem $eid: $val ($status)"
}
close $fid
```

## 常用质量阈值

| 检查项 | 理想值 | 典型阈值 |
|--------|--------|---------|
| aspect | 1.0 | < 5 |
| skew | 0° | < 60° |
| warpage | 0° | < 15° |
| jacobian | 1.0 | > 0.6 |
| taper | 0 | < 0.5 |
