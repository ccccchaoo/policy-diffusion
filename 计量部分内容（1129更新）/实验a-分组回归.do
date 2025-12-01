cd "D:\GitHub\policy-diffusion\计量部分内容（1129更新）"
sysdir set PLUS "D:\Stata17\ado\plus"
*需要设置本地的路径
*ssc install reghdfe
*ssc install ftools
*ssc install coefplot, replace
*ssc install estout
*ssc install qregpd, replace
*ssc install moremata, replace
clear

import excel "年度.xlsx", firstrow clear
gen post = (year >= 2022)
gen intensity = avg_direct_degree * treated
gen did = post*intensity

*========================================================
* 基于intensity指标的分组回归
*========================================================

* 创建分组变量（按intensity中位数分组）
sum intensity, detail
local median_intensity = r(p50)
gen intensity_group = (intensity > `median_intensity')
label define intensity_lab 0 "低政策强度组" 1 "高政策强度组"
label values intensity_group intensity_lab

display "=============================================="
display "政策强度分组信息："
display "中位数：`median_intensity'"
tab intensity_group
sum intensity if intensity_group == 0, detail
sum intensity if intensity_group == 1, detail

*========================================================
* (1) 单位GDP能耗的分组回归
*========================================================

* 低政策强度组
reg 单位GDP能耗 did 工业结构 城市化水平 人口密度 技术进步 财政自给率 i.id i.year if intensity_group == 0, vce(robust)
estimates store reg_能耗_低强度_控制变量

reg 单位GDP能耗 did i.id i.year if intensity_group == 0, vce(robust)
estimates store reg_能耗_低强度_无控制变量

* 高政策强度组
reg 单位GDP能耗 did 工业结构 城市化水平 人口密度 技术进步 财政自给率 i.id i.year if intensity_group == 1, vce(robust)
estimates store reg_能耗_高强度_控制变量

reg 单位GDP能耗 did i.id i.year if intensity_group == 1, vce(robust)
estimates store reg_能耗_高强度_无控制变量

*========================================================
* (2) 非化石能源占比的分组回归
*========================================================

* 低政策强度组
reg 非化石能源占比 did 工业结构 城市化水平 人口密度 技术进步 财政自给率 i.id i.year if intensity_group == 0, vce(robust)
estimates store reg_非化石_低强度_控制变量

reg 非化石能源占比 did i.id i.year if intensity_group == 0, vce(robust)
estimates store reg_非化石_低强度_无控制变量

* 高政策强度组
reg 非化石能源占比 did 工业结构 城市化水平 人口密度 技术进步 财政自给率 i.id i.year if intensity_group == 1, vce(robust)
estimates store reg_非化石_高强度_控制变量

reg 非化石能源占比 did i.id i.year if intensity_group == 1, vce(robust)
estimates store reg_非化石_高强度_无控制变量

*========================================================
* (3) 单位GDP碳排放量的分组回归
*========================================================

* 低政策强度组
reg 单位GDP碳排放量 did 工业结构 城市化水平 人口密度 技术进步 财政自给率 i.id i.year if intensity_group == 0, vce(robust)
estimates store reg_碳排_低强度_控制变量

reg 单位GDP碳排放量 did i.id i.year if intensity_group == 0, vce(robust)
estimates store reg_碳排_低强度_无控制变量

* 高政策强度组
reg 单位GDP碳排放量 did 工业结构 城市化水平 人口密度 技术进步 财政自给率 i.id i.year if intensity_group == 1, vce(robust)
estimates store reg_碳排_高强度_控制变量

reg 单位GDP碳排放量 did i.id i.year if intensity_group == 1, vce(robust)
estimates store reg_碳排_高强度_无控制变量

*========================================================
* 创建分组回归结果表格
*========================================================
clear
set obs 14
gen 变量 = ""
gen 能耗强度_低强度_控制变量 = ""
gen 能耗强度_低强度_无控制变量 = ""
gen 能耗强度_高强度_控制变量 = ""
gen 能耗强度_高强度_无控制变量 = ""
gen 非化石能源占比_低强度_控制变量 = ""
gen 非化石能源占比_低强度_无控制变量 = ""
gen 非化石能源占比_高强度_控制变量 = ""
gen 非化石能源占比_高强度_无控制变量 = ""
gen 碳排强度_低强度_控制变量 = ""
gen 碳排强度_低强度_无控制变量 = ""
gen 碳排强度_高强度_控制变量 = ""
gen 碳排强度_高强度_无控制变量 = ""

* 填充变量名称
local row = 1
replace 变量 = "post×treated" in `row'
local row = `row' + 1
replace 变量 = "t值" in `row'
local row = `row' + 1
replace 变量 = "工业结构" in `row'
local row = `row' + 1
replace 变量 = "t值" in `row'
local row = `row' + 1
replace 变量 = "城市化水平" in `row'
local row = `row' + 1
replace 变量 = "t值" in `row'
local row = `row' + 1
replace 变量 = "人口密度" in `row'
local row = `row' + 1
replace 变量 = "t值" in `row'
local row = `row' + 1
replace 变量 = "技术进步" in `row'
local row = `row' + 1
replace 变量 = "t值" in `row'
local row = `row' + 1
replace 变量 = "财政自给率" in `row'
local row = `row' + 1
replace 变量 = "t值" in `row'
local row = `row' + 1
replace 变量 = "样本量" in `row'
local row = `row' + 1
replace 变量 = "R-squared" in `row'

* 函数：提取回归系数和t值（包含显著性星号）
cap program drop extract_reg_results
program define extract_reg_results
    args model col
    
    * 获取系数矩阵
    matrix b = e(b)
    matrix V = e(V)
    
    * 获取变量名
    local varnames: colnames b
    
    * did (post×treated)
    local pos = 0
    foreach var of local varnames {
        local pos = `pos' + 1
        if "`var'" == "did" {
            local coef = b[1, `pos']
            local se = sqrt(V[`pos', `pos'])
            local tval = `coef'/`se'
            
            * 添加显著性星号
            local star = ""
            if abs(`tval') >= 2.58 {
                local star "***"
            }
            else if abs(`tval') >= 1.96 {
                local star "**"
            }
            else if abs(`tval') >= 1.65 {
                local star "*"
            }
            
            replace `col' = string(`coef', "%9.4f") + "`star'" in 1
            replace `col' = string(`tval', "%9.4f") in 2
        }
    }
    
    * 控制变量（仅对有控制变量的模型）
    if inlist("`model'", "reg_能耗_低强度_控制变量", "reg_能耗_高强度_控制变量", ///
              "reg_非化石_低强度_控制变量", "reg_非化石_高强度_控制变量", ///
              "reg_碳排_低强度_控制变量", "reg_碳排_高强度_控制变量") {
        * 工业结构
        local pos = 0
        foreach var of local varnames {
            local pos = `pos' + 1
            if "`var'" == "工业结构" {
                local coef = b[1, `pos']
                local se = sqrt(V[`pos', `pos'])
                local tval = `coef'/`se'
                
                local star = ""
                if abs(`tval') >= 2.58 {
                    local star "***"
                }
                else if abs(`tval') >= 1.96 {
                    local star "**"
                }
                else if abs(`tval') >= 1.65 {
                    local star "*"
                }
                
                replace `col' = string(`coef', "%9.4f") + "`star'" in 3
                replace `col' = string(`tval', "%9.4f") in 4
            }
        }
        
        * 城市化水平
        local pos = 0
        foreach var of local varnames {
            local pos = `pos' + 1
            if "`var'" == "城市化水平" {
                local coef = b[1, `pos']
                local se = sqrt(V[`pos', `pos'])
                local tval = `coef'/`se'
                
                local star = ""
                if abs(`tval') >= 2.58 {
                    local star "***"
                }
                else if abs(`tval') >= 1.96 {
                    local star "**"
                }
                else if abs(`tval') >= 1.65 {
                    local star "*"
                }
                
                replace `col' = string(`coef', "%9.4f") + "`star'" in 5
                replace `col' = string(`tval', "%9.4f") in 6
            }
        }
        
        * 人口密度
        local pos = 0
        foreach var of local varnames {
            local pos = `pos' + 1
            if "`var'" == "人口密度" {
                local coef = b[1, `pos']
                local se = sqrt(V[`pos', `pos'])
                local tval = `coef'/`se'
                
                local star = ""
                if abs(`tval') >= 2.58 {
                    local star "***"
                }
                else if abs(`tval') >= 1.96 {
                    local star "**"
                }
                else if abs(`tval') >= 1.65 {
                    local star "*"
                }
                
                replace `col' = string(`coef', "%9.4f") + "`star'" in 7
                replace `col' = string(`tval', "%9.4f") in 8
            }
        }
        
        * 技术进步
        local pos = 0
        foreach var of local varnames {
            local pos = `pos' + 1
            if "`var'" == "技术进步" {
                local coef = b[1, `pos']
                local se = sqrt(V[`pos', `pos'])
                local tval = `coef'/`se'
                
                local star = ""
                if abs(`tval') >= 2.58 {
                    local star "***"
                }
                else if abs(`tval') >= 1.96 {
                    local star "**"
                }
                else if abs(`tval') >= 1.65 {
                    local star "*"
                }
                
                replace `col' = string(`coef', "%9.4f") + "`star'" in 9
                replace `col' = string(`tval', "%9.4f") in 10
            }
        }
        
        * 财政自给率
        local pos = 0
        foreach var of local varnames {
            local pos = `pos' + 1
            if "`var'" == "财政自给率" {
                local coef = b[1, `pos']
                local se = sqrt(V[`pos', `pos'])
                local tval = `coef'/`se'
                
                local star = ""
                if abs(`tval') >= 2.58 {
                    local star "***"
                }
                else if abs(`tval') >= 1.96 {
                    local star "**"
                }
                else if abs(`tval') >= 1.65 {
                    local star "*"
                }
                
                replace `col' = string(`coef', "%9.4f") + "`star'" in 11
                replace `col' = string(`tval', "%9.4f") in 12
            }
        }
    }
    
    * 样本量和R-squared
    local N = e(N)
    local r2 = e(r2)  // 普通回归的R-squared
    replace `col' = string(`N') in 13
    replace `col' = string(`r2', "%9.4f") in 14
end

* 提取各分组回归模型结果
local models "reg_能耗_低强度_控制变量 reg_能耗_低强度_无控制变量 reg_能耗_高强度_控制变量 reg_能耗_高强度_无控制变量"
local models "`models' reg_非化石_低强度_控制变量 reg_非化石_低强度_无控制变量 reg_非化石_高强度_控制变量 reg_非化石_高强度_无控制变量"
local models "`models' reg_碳排_低强度_控制变量 reg_碳排_低强度_无控制变量 reg_碳排_高强度_控制变量 reg_碳排_高强度_无控制变量"

local cols "能耗强度_低强度_控制变量 能耗强度_低强度_无控制变量 能耗强度_高强度_控制变量 能耗强度_高强度_无控制变量"
local cols "`cols' 非化石能源占比_低强度_控制变量 非化石能源占比_低强度_无控制变量 非化石能源占比_高强度_控制变量 非化石能源占比_高强度_无控制变量"
local cols "`cols' 碳排强度_低强度_控制变量 碳排强度_低强度_无控制变量 碳排强度_高强度_控制变量 碳排强度_高强度_无控制变量"

local i = 1
foreach model of local models {
    local col: word `i' of `cols'
    estimates restore `model'
    extract_reg_results "`model'" "`col'"
    local i = `i' + 1
}

* 输出分组回归结果到Excel
export excel using "分组回归结果_按政策强度.xlsx", firstrow(variables) replace

* 显示结果
display "=============================================="
display "分组回归结果（按政策强度分组）"
display "=============================================="
display "注：*、**、*** 分别表示在 10%、5%、1% 的水平上显著"
display "分组回归结果已输出到 Excel 文件：分组回归结果_按政策强度.xlsx"

* 显示主要结果
list 变量 能耗强度_低强度_控制变量 能耗强度_高强度_控制变量 非化石能源占比_低强度_控制变量 非化石能源占比_高强度_控制变量 碳排强度_低强度_控制变量 碳排强度_高强度_控制变量, clean noobs

*========================================================
* 组间系数差异检验
*========================================================
display ""
display "=============================================="
display "组间系数差异检验"
display "=============================================="

* 重新加载数据
preserve
import excel "年度.xlsx", firstrow clear
gen post = (year >= 2021)
gen intensity = avg_direct_degree * treated
gen did = post*intensity

* 创建交互项进行检验
sum intensity, detail
local median_intensity = r(p50)
gen intensity_group = (intensity > `median_intensity')
gen did_low = did * (intensity_group == 0)
gen did_high = did * (intensity_group == 1)

* 单位GDP能耗的组间差异检验
display "单位GDP能耗 - 组间差异检验："
reg 单位GDP能耗 did_low did_high 工业结构 城市化水平 人口密度 技术进步 财政自给率 i.id i.year, vce(robust)
test did_low = did_high
display "F统计量 = " %6.4f r(F) ", p值 = " %6.4f r(p)

* 非化石能源占比的组间差异检验
display ""
display "非化石能源占比 - 组间差异检验："
reg 非化石能源占比 did_low did_high 工业结构 城市化水平 人口密度 技术进步 财政自给率 i.id i.year, vce(robust)
test did_low = did_high
display "F统计量 = " %6.4f r(F) ", p值 = " %6.4f r(p)

* 单位GDP碳排放量的组间差异检验
display ""
display "单位GDP碳排放量 - 组间差异检验："
reg 单位GDP碳排放量 did_low did_high 工业结构 城市化水平 人口密度 技术进步 财政自给率 i.id i.year, vce(robust)
test did_low = did_high
display "F统计量 = " %6.4f r(F) ", p值 = " %6.4f r(p)

restore