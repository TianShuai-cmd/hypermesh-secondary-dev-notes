# =============================================================
# 说明文件: 05_tcl_file_io_notes.md
# 对应脚本: scripts/05_tcl_file_io.tcl
# 功能描述: TCL 文件读写 - 打开、读取、写入、追加、文件操作
# =============================================================

## 第一部分：写入文件

```tcl
# open 语法：open <路径> <模式>
# 模式：w=写入（覆盖）、r=读取、a=追加
set fid [open "output.txt" w]
puts $fid "写入内容"    ;# 向文件写入一行
close $fid              ;# 必须关闭，否则内容可能未刷新到磁盘
```

---

## 第二部分：整体读取文件

```tcl
set fid [open "output.txt" r]
set content [read $fid]   ;# 一次性读取全部内容为字符串
close $fid
puts $content
```

---

## 第三部分：逐行读取

```tcl
set fid [open "output.txt" r]
# gets 返回读取的字符数，到达文件末尾时返回 -1
while {[gets $fid line] >= 0} {
    puts "行内容: $line"
}
close $fid
```

---

## 第四部分：追加写入

```tcl
# 模式 "a" 追加，不覆盖原有内容
set fid [open "output.txt" a]
puts $fid "追加的内容"
close $fid
```

---

## 第五部分：文件与目录操作

```tcl
file exists $path          ;# 判断文件/目录是否存在
file isfile $path          ;# 是否是文件
file isdirectory $path     ;# 是否是目录
file size $path            ;# 文件大小（字节）
file tail $path            ;# 获取文件名（去掉目录部分）
file dirname $path         ;# 获取目录部分
file extension $path       ;# 获取扩展名（如 .txt）
file rename $old $new      ;# 重命名/移动文件
file delete $path          ;# 删除文件
```

---

## 第六部分：实战 - 导出节点坐标到 CSV

```tcl
set node_ids [hm_entitylist nodes id]
set fid [open "node_coords.csv" w]
puts $fid "ID,X,Y,Z"   ;# 写入表头

foreach nid $node_ids {
    set x [hm_getvalue node id=$nid dataname=x]
    set y [hm_getvalue node id=$nid dataname=y]
    set z [hm_getvalue node id=$nid dataname=z]
    puts $fid "$nid,$x,$y,$z"
}
close $fid
```

---

## 第七部分：实战 - 从 CSV 导入节点

```tcl
set fid [open "import_nodes.csv" r]
gets $fid   ;# 跳过表头行

while {[gets $fid line] >= 0} {
    if {[string trim $line] eq ""} { continue }   ;# 跳过空行
    set parts [split $line ","]                    ;# 按逗号拆分
    set x [lindex $parts 1]
    set y [lindex $parts 2]
    set z [lindex $parts 3]
    *createnode $x $y $z 0 0 0
}
close $fid
```

---

## 知识点总结

| 语法 | 说明 |
|------|------|
| `open <path> w/r/a` | 打开文件（写/读/追加） |
| `close $fid` | 关闭文件，必须执行 |
| `puts $fid "text"` | 向文件写入一行 |
| `read $fid` | 一次性读取全部内容 |
| `gets $fid line` | 逐行读取，返回字符数，EOF返回-1 |
| `split $str ","` | 按分隔符拆分字符串为列表 |
| `file exists/isfile/size/tail/dirname` | 文件信息查询 |
| `file rename / delete` | 文件管理 |
| `info script` | 获取当前脚本的完整路径 |
| `file dirname [info script]` | 获取当前脚本所在目录 |

---

## 踩坑记录

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 写入文件后内容为空 | 没有执行 `close $fid` | 写完必须 close |
| CSV 读取最后一行为空 | 文件末尾有换行符 | 用 `string trim` 判断空行并跳过 |
