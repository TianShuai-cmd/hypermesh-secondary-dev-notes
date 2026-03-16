# =============================================================
# 脚本名称: 01_hello_hypermesh.tcl
# 功能描述: 第一个HyperMesh脚本 - 读取模型信息并创建节点
# 创建日期: 2026-03-16
# 适用版本: HyperMesh 2023 (TCL 8.5.9)
# 使用方法: Command Window 输入 source {脚本完整路径}
# =============================================================

# --- TCL 字符串规则（HyperMesh 中非常重要）---
# " "  -> 会解析 $变量 和 [] 命令替换，慎用方括号
# { }  -> 原样输出，不解析任何内容，最安全
# 注意：puts "[ title ]" 会报错，因为 [] 会被当作命令执行

# --- HyperMesh TCL API 说明（TCL 8.5.9 实测）---
# hm_entitylist <实体类型> id       -> 返回该类型所有实体的 ID 列表
# llength <列表>                    -> 统计列表元素数量
# hm_getvalue <类型> id=N dataname=<属性名>  -> 读取实体属性值
# *createnode x y z 0 0 0           -> 在指定坐标创建节点

puts "=============================="
puts " HyperMesh - Hello World"
puts "=============================="

# ------ 1. 读取模型基本信息 ------
# 分别获取节点、单元、组件的 ID 列表，再用 llength 统计数量
set node_ids  [hm_entitylist nodes id]
set elem_ids  [hm_entitylist elems id]
set comp_ids  [hm_entitylist comps id]

set node_count [llength $node_ids]
set elem_count [llength $elem_ids]
set comp_count [llength $comp_ids]

puts ""
puts "--- Model Info ---"
puts "  Nodes      : $node_count"
puts "  Elements   : $elem_count"
puts "  Components : $comp_count"

# ------ 2. 列出所有组件名称 ------
# 遍历组件 ID 列表，用 hm_getvalue 读取每个组件的 name 属性
puts ""
puts "--- Component List ---"
if {$comp_count == 0} {
    puts "  (no components in current model)"
} else {
    foreach cid $comp_ids {
        # hm_getvalue 参数：实体类型、ID选择器、属性名
        set cname [hm_getvalue comp id=$cid dataname=name]
        puts "  ID=$cid  Name=$cname"
    }
}

# ------ 3. 创建测试节点 ------
# *createnode 参数说明：x y z 坐标系ID 输出ID 配置ID
# 坐标系ID=0 表示全局坐标系，后两个参数通常填 0
puts ""
puts "--- Create Test Nodes ---"
*createnode 0.0   0.0   0.0  0 0 0   ;# 节点1：原点
*createnode 100.0 0.0   0.0  0 0 0   ;# 节点2：X轴方向
*createnode 100.0 100.0 0.0  0 0 0   ;# 节点3：对角
*createnode 0.0   100.0 0.0  0 0 0   ;# 节点4：Y轴方向
                                      ;# 四点构成 100x100 正方形

# 重新获取节点列表，统计创建后的总数
set all_ids   [hm_entitylist nodes id]
set new_count [llength $all_ids]
puts "  4 nodes created. Total nodes: $new_count"

# ------ 4. 验证节点坐标 ------
# lrange 用法：lrange <列表> <起始> <结束>
# end-3 表示倒数第4个，end 表示最后一个
# 即取列表最后4个元素（刚创建的节点）
puts ""
puts "--- Verify Last 4 Nodes ---"
set last4 [lrange $all_ids end-3 end]
foreach nid $last4 {
    # 分别读取 x、y、z 坐标属性
    set x [hm_getvalue node id=$nid dataname=x]
    set y [hm_getvalue node id=$nid dataname=y]
    set z [hm_getvalue node id=$nid dataname=z]
    puts "  Node $nid : ($x, $y, $z)"
}

puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# 踩坑记录：
# 1. hm_entityinfo count nodes 0  -> TCL 8.5.9 中语法无效
#    正确写法：llength [hm_entitylist nodes id]
# 2. puts "[ title ]"  -> [] 是命令替换符，会报错！
#    正确写法：puts {title} 或 puts "--- title ---"
# =============================================================
