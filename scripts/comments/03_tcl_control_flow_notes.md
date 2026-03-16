# =============================================================
# 说明文件: 03_tcl_control_flow_notes.md
# 对应脚本: scripts/03_tcl_control_flow.tcl
# 功能描述: TCL 流程控制 - 条件判断、循环、跳出控制
# =============================================================

## 第一部分：if / elseif / else

```tcl
# 注意：条件必须用 {} 包裹，花括号必须和 if 在同一行
if {$score >= 90} {
    puts "Grade: A"
} elseif {$score >= 80} {
    puts "Grade: B"
} else {
    puts "Grade: F"
}

# 比较运算符
# ==  等于    !=  不等于
# >   大于    <   小于
# >=  大于等于  <=  小于等于

# 字符串比较用 eq / ne，不要用 == 比较字符串
if {$lang eq "TCL"} { puts "is TCL" }
if {$lang ne "Python"} { puts "not Python" }

# 逻辑运算符：&& 与、|| 或、! 非
if {$x > 10 && $x < 20} { puts "between 10 and 20" }
```

---

## 第二部分：switch

```tcl
# 精确匹配
switch $day {
    "Monday"   { puts "Start of week" }
    "Saturday" -
    "Sunday"   { puts "Weekend" }   ;# 多个值共用同一分支用 -
    default    { puts "Midweek" }
}

# -glob 通配符匹配
switch -glob $filename {
    "*.hm"  { puts "HyperMesh file" }
    "*.bdf" { puts "Nastran file" }
    default { puts "Unknown" }
}
```

---

## 第三部分：for 循环

```tcl
# 基本 for：初始化; 条件; 步进
for {set i 1} {$i <= 5} {incr i} { puts $i }

# 步进为2
for {set i 0} {$i <= 10} {incr i 2} { puts $i }

# 倒序
for {set i 5} {$i >= 1} {incr i -1} { puts $i }

# puts -nonewline：输出不换行
puts -nonewline "hello "
puts ""   ;# 手动换行
```

---

## 第四部分：foreach 循环

```tcl
# 遍历列表
foreach item $list { puts $item }

# 同时遍历多个变量（每次取两个元素）
set pairs {node1 100 node2 200}
foreach {name val} $pairs { puts "$name = $val" }

# 嵌套 foreach
foreach r {1 2 3} {
    foreach c {A B C} { puts -nonewline "$r$c " }
    puts ""
}
```

---

## 第五部分：while 循环

```tcl
set n 1
set sum 0
while {$n <= 10} {
    incr sum $n
    incr n
}
puts "sum = $sum"
```

---

## 第六部分：break / continue

```tcl
# break：立即退出循环
for {set i 1} {$i <= 10} {incr i} {
    if {$i == 5} { break }
    puts $i
}

# continue：跳过本次循环，继续下一次
for {set i 1} {$i <= 10} {incr i} {
    if {$i % 2 == 0} { continue }   ;# 跳过偶数
    puts $i
}
```

---

## 第七部分：实际应用 - 按名称前缀分类组件

```tcl
set comp_names {Shell_Top Shell_Bottom Rib_Left Bolt_01}
set shell_list {}
set rib_list   {}
set other_list {}

foreach cname $comp_names {
    if {[string match "Shell*" $cname]} {
        lappend shell_list $cname
    } elseif {[string match "Rib*" $cname]} {
        lappend rib_list $cname
    } else {
        lappend other_list $cname
    }
}
```

---

## 知识点总结

| 语法 | 说明 |
|------|------|
| `if {} {} elseif {} {} else {}` | 条件判断，条件用 `{}` 包裹 |
| `eq / ne` | 字符串比较，不要用 `==` |
| `switch / switch -glob` | 多分支，支持通配符 |
| `for {init} {cond} {step} {}` | 计数循环 |
| `foreach var $list {}` | 列表遍历 |
| `foreach {a b} $list {}` | 多变量同时遍历 |
| `while {cond} {}` | 条件循环 |
| `break` | 跳出循环 |
| `continue` | 跳过本次循环 |
| `puts -nonewline` | 输出不换行 |
