# =============================================================
# 说明文件: 04_tcl_proc_notes.md
# 对应脚本: scripts/04_tcl_proc.tcl
# 功能描述: TCL 过程（函数）- 定义、参数、返回值、作用域、错误处理
# =============================================================

## 第一部分：基本 proc 定义与调用

```tcl
# proc 语法：proc 名称 {参数列表} {函数体}
proc greet {name} {
    puts "Hello, $name!"
}
greet "HyperMesh"   # 调用

# 有返回值的 proc
proc add {a b} {
    return [expr {$a + $b}]
}
set result [add 10 20]   # 用 [] 捕获返回值
```

---

## 第二部分：默认参数

```tcl
# 用 {参数名 默认值} 设置默认值
# 有默认值的参数必须放在参数列表末尾
proc create_node {x y {z 0.0}} {
    puts "Creating node at ($x, $y, $z)"
}
create_node 100 200        ;# z 使用默认值 0.0
create_node 100 200 50.0   ;# z 指定为 50.0
```

---

## 第三部分：可变参数（args）

```tcl
# args 是特殊参数名，接收所有剩余参数，以列表形式存储
proc sum_all {args} {
    set total 0
    foreach n $args {
        set total [expr {$total + $n}]
    }
    return $total
}
sum_all 1 2 3        ;# 返回 6
sum_all 10 20 30 40  ;# 返回 100

# 混合固定参数和可变参数
proc log_msg {level args} {
    set msg [join $args " "]   ;# join 将列表合并为字符串
    puts "\[$level\] $msg"
}
log_msg "INFO" "Model loaded"
```

---

## 第四部分：变量作用域

```tcl
# proc 内部变量是局部变量，外部无法访问
# 访问全局变量需要用 global 声明
set global_var "I am global"
proc scope_test {} {
    global global_var          ;# 声明后才能访问/修改全局变量
    set global_var "Modified"
}

# upvar：引用传递，修改调用者的变量
# upvar 1 表示上一层作用域
proc double_value {varName} {
    upvar 1 $varName local
    set local [expr {$local * 2}]
}
set myNum 5
double_value myNum   ;# myNum 变为 10
```

---

## 第五部分：错误处理（catch / error）

```tcl
# catch 捕获错误：返回 0 表示成功，1 表示出错
if {[catch {可能出错的命令} errVar]} {
    puts "出错了: $errVar"
} else {
    puts "成功"
}

# error 主动抛出错误
proc safe_divide {a b} {
    if {$b == 0} {
        error "除数不能为零"
    }
    return [expr {$a / double($b)}]
}
```

---

## 第六部分：HyperMesh 工具函数封装

```tcl
# 获取模型统计信息（返回字典）
proc get_model_stats {} {
    set nc [llength [hm_entitylist nodes id]]
    set ec [llength [hm_entitylist elems id]]
    set cc [llength [hm_entitylist comps id]]
    return [dict create nodes $nc elems $ec comps $cc]
}

# 安全创建节点（带错误处理）
proc safe_create_node {x y z} {
    if {[catch {*createnode $x $y $z 0 0 0} err]} {
        return 0   ;# 失败返回 0
    }
    return 1       ;# 成功返回 1
}

# 批量创建节点
proc batch_create_nodes {coords} {
    set count 0
    set clist $coords
    foreach {x y z} $clist {
        if {[safe_create_node $x $y $z]} { incr count }
    }
    return $count
}
```

---

## 知识点总结

| 语法 | 说明 |
|------|------|
| `proc name {args} {body}` | 定义过程 |
| `{param default}` | 带默认值的参数，放在参数列表末尾 |
| `args` | 可变参数，以列表形式接收所有剩余参数 |
| `global varName` | 在 proc 内访问/修改全局变量 |
| `upvar 1 varName local` | 引用传递，修改调用者的变量 |
| `catch {cmd} errVar` | 捕获错误，返回0成功/1失败 |
| `error "message"` | 主动抛出错误 |
| `join $list " "` | 列表转字符串 |

---

## 踩坑记录

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| proc 内读不到参数变量 | 脚本含中文注释，HyperMesh 用 GBK 读取 UTF-8 文件导致花括号配对错乱 | 脚本文件只用英文注释 |
| 重复 source 时旧 proc 残留 | HyperMesh TCL 不会自动覆盖同名 proc | 脚本开头用 `rename proc {}` 清除旧定义 |
