# =============================================================
# 脚本名称: 03_tcl_control_flow.tcl
# 功能描述: TCL 流程控制 - 条件判断、循环、跳出控制
# 创建日期: 2026-03-16
# 适用版本: HyperMesh 2023 (TCL 8.5.9)
# 使用方法: source {C:/Users/13378/Desktop/HyperMesh-Dev/scripts/03_tcl_control_flow.tcl}
# =============================================================

puts "=============================="
puts " TCL Control Flow"
puts "=============================="


# ============================================================
# 第一部分：if / elseif / else
# ============================================================
puts ""
puts "--- 1. if / elseif / else ---"

set score 85

# 基本 if 结构
# 注意：条件必须用 {} 包裹，花括号必须和 if 在同一行
if {$score >= 90} {
    puts "  Grade: A"
} elseif {$score >= 80} {
    puts "  Grade: B"
} elseif {$score >= 70} {
    puts "  Grade: C"
} else {
    puts "  Grade: F"
}

# 常用比较运算符
# ==  等于       !=  不等于
# >   大于        <   小于
# >=  大于等于   <=  小于等于

# 字符串比较（用 eq / ne，不要用 == 比较字符串）
set lang "TCL"
if {$lang eq "TCL"} {
    puts "  Language is TCL"
}
if {$lang ne "Python"} {
    puts "  Language is not Python"
}

# 逻辑运算符：&& 与、|| 或、! 非
set x 15
if {$x > 10 && $x < 20} {
    puts "  x is between 10 and 20"
}


# ============================================================
# 第二部分：switch
# ============================================================
puts ""
puts "--- 2. switch ---"

set day "Monday"

# switch 精确匹配
switch $day {
    "Monday"    { puts "  Start of work week" }
    "Friday"    { puts "  End of work week" }
    "Saturday"  -
    "Sunday"    { puts "  Weekend" }
    default     { puts "  Midweek: $day" }
}

# switch -glob 通配符匹配
set filename "model_v2.hm"
switch -glob $filename {
    "*.hm"   { puts "  HyperMesh file" }
    "*.bdf"  { puts "  Nastran file" }
    "*.inp"  { puts "  Abaqus file" }
    default  { puts "  Unknown file type" }
}


# ============================================================
# 第三部分：for 循环
# ============================================================
puts ""
puts "--- 3. for loop ---"

# 基本 for 循环：初始化; 条件; 步进
puts "  counting 1 to 5:"
for {set i 1} {$i <= 5} {incr i} {
    puts "    i = $i"
}

# 步进为2
puts "  even numbers 0-10:"
for {set i 0} {$i <= 10} {incr i 2} {
    puts -nonewline "    $i "   ;# -nonewline 不换行
}
puts ""   ;# 手动换行

# 倒序循环
puts "  countdown:"
for {set i 5} {$i >= 1} {incr i -1} {
    puts -nonewline "    $i"
}
puts "  Go!"


# ============================================================
# 第四部分：foreach 循环
# ============================================================
puts ""
puts "--- 4. foreach loop ---"

# 遍历列表
set components {Shell_Top Shell_Bottom Rib_Left Rib_Right}
puts "  components:"
foreach comp $components {
    puts "    - $comp"
}

# 同时遍历多个变量（每次取两个元素）
set pairs {node1 100 node2 200 node3 300}
puts "  node-value pairs:"
foreach {name val} $pairs {
    puts "    $name = $val"
}

# 嵌套 foreach
set rows {1 2 3}
set cols {A B C}
puts "  nested loop:"
foreach r $rows {
    foreach c $cols {
        puts -nonewline "    $r$c"
    }
    puts ""
}


# ============================================================
# 第五部分：while 循环
# ============================================================
puts ""
puts "--- 5. while loop ---"

# 基本 while
set n 1
set sum 0
while {$n <= 10} {
    incr sum $n   ;# sum += n
    incr n
}
puts "  sum of 1-10 = $sum"

# 模拟"读取直到结束"场景
set items {a b c STOP d e}
set idx 0
puts "  read until STOP:"
while {$idx < [llength $items]} {
    set item [lindex $items $idx]
    if {$item eq "STOP"} {
        puts "    found STOP, breaking"
        break   ;# 跳出循环
    }
    puts "    item: $item"
    incr idx
}


# ============================================================
# 第六部分：break 和 continue
# ============================================================
puts ""
puts "--- 6. break / continue ---"

# break：立即退出循环
puts "  break at 5:"
for {set i 1} {$i <= 10} {incr i} {
    if {$i == 5} { break }
    puts -nonewline "    $i"
}
puts ""

# continue：跳过本次循环，继续下一次
puts "  skip even numbers:"
for {set i 1} {$i <= 10} {incr i} {
    if {$i % 2 == 0} { continue }   ;# 偶数跳过
    puts -nonewline "    $i"
}
puts ""


# ============================================================
# 第七部分：实际应用 - 遍历模型组件并分类
# ============================================================
puts ""
puts "--- 7. Practical Example ---"

# 模拟一组组件名称（实际使用时替换为 hm_entitylist comps id）
set comp_names {Shell_Top Shell_Bottom Rib_Left Rib_Right Bolt_01 Bolt_02 Weld_A}

set shell_list {}
set rib_list   {}
set other_list {}

# 按名称前缀分类
foreach cname $comp_names {
    if {[string match "Shell*" $cname]} {
        lappend shell_list $cname
    } elseif {[string match "Rib*" $cname]} {
        lappend rib_list $cname
    } else {
        lappend other_list $cname
    }
}

puts "  Shell components : $shell_list"
puts "  Rib components   : $rib_list"
puts "  Other components : $other_list"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# 本脚本知识点总结：
# 1. if/elseif/else  -> 条件判断，条件用 {} 包裹
# 2. eq/ne           -> 字符串比较，不要用 == 比较字符串
# 3. switch          -> 多分支，支持 -glob 通配符
# 4. for             -> 计数循环，incr 控制步进
# 5. foreach         -> 列表遍历，支持多变量同时遍历
# 6. while           -> 条件循环
# 7. break/continue  -> 跳出/跳过循环
# 8. puts -nonewline -> 输出不换行
# =============================================================
