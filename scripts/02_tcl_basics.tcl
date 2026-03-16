# =============================================================
# 脚本名称: 02_tcl_basics.tcl
# 功能描述: TCL 基础语法练习 - 变量、列表、字符串、字典、数学运算
# 创建日期: 2026-03-16
# 适用版本: HyperMesh 2023 (TCL 8.5.9)
# 使用方法: source {C:/Users/13378/Desktop/HyperMesh-Dev/scripts/02_tcl_basics.tcl}
# =============================================================

puts "=============================="
puts " TCL Basics"
puts "=============================="


# ============================================================
# 第一部分：变量
# ============================================================
puts ""
puts "--- 1. Variables ---"

# set 命令赋值，$ 符号取值
set name "HyperMesh"
set version 2023
set pi 3.14159

puts "  name    = $name"
puts "  version = $version"
puts "  pi      = $pi"

# 字符串拼接：直接在双引号中使用变量
set info "Software: $name, Version: $version"
puts "  info    = $info"

# unset 删除变量
set temp "delete me"
unset temp
# 判断变量是否存在
if {![info exists temp]} {
    puts "  temp has been deleted"
}


# ============================================================
# 第二部分：列表操作
# ============================================================
puts ""
puts "--- 2. List Operations ---"

# 创建列表（用 {} 或 list 命令）
set fruits {apple banana orange grape}
set nums [list 10 20 30 40 50]

# llength：获取列表长度
puts "  fruits count : [llength $fruits]"

# lindex：按索引取元素（从0开始，end表示最后一个）
puts "  first fruit  : [lindex $fruits 0]"
puts "  last fruit   : [lindex $fruits end]"

# lrange：切片，取第1到第2个元素
puts "  fruits 1-2   : [lrange $fruits 1 2]"

# lappend：追加元素到列表末尾
lappend fruits "mango"
puts "  after append : $fruits"

# linsert：在指定位置插入元素
set fruits [linsert $fruits 1 "pear"]
puts "  after insert : $fruits"

# lsearch：查找元素，返回索引，找不到返回 -1
set idx [lsearch $fruits "orange"]
puts "  orange index : $idx"

# lsort：排序
set sorted [lsort $fruits]
puts "  sorted       : $sorted"

# foreach：遍历列表
puts "  all fruits:"
foreach f $fruits {
    puts "    - $f"
}


# ============================================================
# 第三部分：字符串操作
# ============================================================
puts ""
puts "--- 3. String Operations ---"

set str "HyperMesh_2023_Model"

# string length：字符串长度
puts "  length       : [string length $str]"

# string toupper / tolower：大小写转换
puts "  upper        : [string toupper $str]"
puts "  lower        : [string tolower $str]"

# string index：取第N个字符（从0开始）
puts "  char at 0    : [string index $str 0]"

# string range：截取子字符串
puts "  range 0-8    : [string range $str 0 8]"

# string first：查找子字符串位置，找不到返回 -1
puts "  pos of 2023  : [string first "2023" $str]"

# string map：替换字符串
set new_str [string map {"2023" "2024"} $str]
puts "  after replace: $new_str"

# split：按分隔符拆分为列表
set parts [split $str "_"]
puts "  split by _   : $parts"
puts "  part 0       : [lindex $parts 0]"

# string match：通配符匹配（* 匹配任意，? 匹配单个字符）
if {[string match "*2023*" $str]} {
    puts "  match *2023* : yes"
}

# string trim：去除首尾空格
set padded "  hello world  "
puts "  trimmed      : '[string trim $padded]'"


# ============================================================
# 第四部分：字典操作（TCL 8.5 新增）
# ============================================================
puts ""
puts "--- 4. Dictionary Operations ---"

# 创建字典
set config [dict create host "localhost" port 8080 debug 1]

# dict get：读取值
puts "  host  : [dict get $config host]"
puts "  port  : [dict get $config port]"

# dict set：设置/更新值
dict set config port 9090
puts "  new port : [dict get $config port]"

# dict exists：判断 key 是否存在
if {[dict exists $config debug]} {
    puts "  debug key exists"
}

# dict keys：获取所有 key
puts "  all keys : [dict keys $config]"

# dict for：遍历字典
puts "  all entries:"
dict for {k v} $config {
    puts "    $k = $v"
}


# ============================================================
# 第五部分：数学运算（expr）
# ============================================================
puts ""
puts "--- 5. Math Operations ---"

# expr 执行数学表达式，结果赋给变量
set a 10
set b 3

# 基本运算
puts "  a + b = [expr {$a + $b}]"
puts "  a - b = [expr {$a - $b}]"
puts "  a * b = [expr {$a * $b}]"
puts "  a / b = [expr {$a / $b}]"       ;# 整数除法
puts "  a % b = [expr {$a % $b}]"       ;# 取余
puts "  a ** b = [expr {$a ** $b}]"     ;# 幂运算（10的3次方）

# 浮点运算（加小数点变为浮点）
puts "  a / b (float) = [expr {$a / double($b)}]"

# 数学函数
puts "  sqrt(2)  = [expr {sqrt(2)}]"
puts "  abs(-5)  = [expr {abs(-5)}]"
puts "  round(3.7) = [expr {round(3.7)}]"
puts "  floor(3.9) = [expr {floor(3.9)}]"
puts "  ceil(3.1)  = [expr {ceil(3.1)}]"

# incr：整数变量自增（比 expr 更高效）
set counter 0
incr counter        ;# +1
incr counter 5      ;# +5
puts "  counter = $counter"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# 本脚本知识点总结：
# 1. set/unset/info exists  -> 变量管理
# 2. lindex/lrange/lappend/lsort/lsearch -> 列表操作
# 3. string length/range/first/map/split/match -> 字符串操作
# 4. dict create/get/set/exists/keys/for -> 字典操作
# 5. expr {表达式} -> 数学运算（注意用 {} 包裹提高性能）
# 6. incr -> 整数自增，比 set x [expr {$x+1}] 更高效
# =============================================================
