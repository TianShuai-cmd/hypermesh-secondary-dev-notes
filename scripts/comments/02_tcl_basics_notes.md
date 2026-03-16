# =============================================================
# 说明文件: 02_tcl_basics_notes.md
# 对应脚本: scripts/02_tcl_basics.tcl
# 功能描述: TCL 基础语法 - 变量、列表、字符串、字典、数学运算
# =============================================================

## 第一部分：变量

```tcl
set name "HyperMesh"    ;# 赋值
set version 2023
puts $name              ;# 取值用 $ 符号

# 字符串拼接：在双引号中直接使用变量
set info "Software: $name, Version: $version"

# 删除变量
unset temp

# 判断变量是否存在
if {![info exists temp]} { puts "not exists" }
```

---

## 第二部分：列表操作

```tcl
set fruits {apple banana orange grape}   ;# 创建列表
set nums [list 10 20 30 40 50]

llength $fruits          ;# 列表长度
lindex $fruits 0         ;# 取第0个元素
lindex $fruits end       ;# 取最后一个元素
lrange $fruits 1 2       ;# 切片，取第1到第2个
lappend fruits "mango"   ;# 追加元素到末尾
linsert $fruits 1 "pear" ;# 在第1位插入元素
lsearch $fruits "orange" ;# 查找，返回索引，找不到返回 -1
lsort $fruits            ;# 排序

# 遍历列表
foreach f $fruits { puts $f }
```

---

## 第三部分：字符串操作

```tcl
set str "HyperMesh_2023_Model"

string length $str           ;# 字符串长度
string toupper $str          ;# 转大写
string tolower $str          ;# 转小写
string index $str 0          ;# 取第0个字符
string range $str 0 8        ;# 截取子字符串
string first "2023" $str     ;# 查找子字符串位置
string map {"2023" "2024"} $str  ;# 替换
split $str "_"               ;# 按分隔符拆分为列表
string match "*2023*" $str   ;# 通配符匹配
string trim "  hello  "      ;# 去除首尾空格
```

---

## 第四部分：字典操作（TCL 8.5 新增）

```tcl
# 创建字典
set config [dict create host "localhost" port 8080]

dict get $config host        ;# 读取值
dict set config port 9090    ;# 设置/更新值
dict exists $config debug    ;# 判断 key 是否存在
dict keys $config            ;# 获取所有 key

# 遍历字典
dict for {k v} $config { puts "$k = $v" }
```

---

## 第五部分：数学运算（expr）

```tcl
# expr 执行数学表达式，建议用 {} 包裹提高性能
expr {$a + $b}       ;# 加
expr {$a - $b}       ;# 减
expr {$a * $b}       ;# 乘
expr {$a / $b}       ;# 整数除法
expr {$a % $b}       ;# 取余
expr {$a ** $b}      ;# 幂运算
expr {$a / double($b)}  ;# 浮点除法

# 数学函数
expr {sqrt(2)}       ;# 平方根
expr {abs(-5)}       ;# 绝对值
expr {round(3.7)}    ;# 四舍五入
expr {floor(3.9)}    ;# 向下取整
expr {ceil(3.1)}     ;# 向上取整

# incr：整数自增，比 expr 更高效
incr counter         ;# +1
incr counter 5       ;# +5
```

---

## 知识点总结

| 语法 | 说明 |
|------|------|
| `set / unset` | 变量赋值/删除 |
| `info exists` | 判断变量是否存在 |
| `lindex / lrange / lappend / lsort` | 列表操作 |
| `string length/range/first/map/split/match/trim` | 字符串操作 |
| `dict create/get/set/exists/keys/for` | 字典操作 |
| `expr {表达式}` | 数学运算，用 `{}` 包裹 |
| `incr` | 整数自增，效率高于 expr |
