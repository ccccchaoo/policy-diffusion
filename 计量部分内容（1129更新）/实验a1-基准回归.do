cd "D:\GitHub\policy-diffusion\计量部分内容（1129更新）"
sysdir set PLUS "D:\Stata17\ado\plus"
*ssc install reghdfe
*ssc install ftools
*ssc install coefplot, replace
*ssc install estout
*ssc install qregpd, replace
*ssc install moremata, replace
*ssc install outreg2
clear

import excel "年度.xlsx", firstrow clear
xtset id year
gen post = (year >= 2022)

*========================================================
* 基准回归结果输出（不含增长率部分）
* (1)单位GDP能耗,2017-2022 - 有控制变量
reghdfe 单位GDP能耗 post##treated 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id year) vce(cluster id)
estimates store did_能耗_控制变量

* (2)单位GDP能耗,2017-2022 - 无控制变量
reghdfe 单位GDP能耗 post##treated, absorb(id year) vce(cluster id)
estimates store did_能耗_无控制变量

* (3)非化石能源占比,2017-2022 - 有控制变量
reghdfe 非化石能源占比 post##treated 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id year) vce(cluster id)
estimates store did_非化石_控制变量

* (4)非化石能源占比,2017-2022 - 无控制变量
reghdfe 非化石能源占比 post##treated, absorb(id year) vce(cluster id)
estimates store did_非化石_无控制变量

* (5)单位GDP碳排放量,2017-2022 - 有控制变量
reghdfe 单位GDP碳排放量 post##treated 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id year) vce(cluster id)
estimates store did_碳排_控制变量

* (6)单位GDP碳排放量,2017-2022 - 无控制变量
reghdfe 单位GDP碳排放量 post##treated, absorb(id year) vce(cluster id)
estimates store did_碳排_无控制变量

*========================================================
* 创建输出表格
clear
set obs 14
gen 变量 = ""
gen 能耗强度_控制变量 = ""
gen 能耗强度_无控制变量 = ""
gen 非化石能源占比_控制变量 = ""
gen 非化石能源占比_无控制变量 = ""
gen 碳排强度_控制变量 = ""
gen 碳排强度_无控制变量 = ""

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

* 函数：提取系数和t值（包含显著性星号）
cap program drop extract_results
program define extract_results
    args model col
    
    * 获取系数矩阵
    matrix b = e(b)
    matrix V = e(V)
    
    * 获取变量名
    local varnames: colnames b
    
    * post×treated
    local pos = 0
    foreach var of local varnames {
        local pos = `pos' + 1
        if "`var'" == "1.post#1.treated" {
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
    if inlist("`model'", "did_能耗_控制变量", "did_非化石_控制变量", "did_碳排_控制变量") {
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
    local r2 = e(r2)
    replace `col' = string(`N') in 13
    replace `col' = string(`r2', "%9.4f") in 14
end

* 提取各模型结果
local models "did_能耗_控制变量 did_能耗_无控制变量 did_非化石_控制变量 did_非化石_无控制变量 did_碳排_控制变量 did_碳排_无控制变量"
local cols "能耗强度_控制变量 能耗强度_无控制变量 非化石能源占比_控制变量 非化石能源占比_无控制变量 碳排强度_控制变量 碳排强度_无控制变量"

local i = 1
foreach model of local models {
    local col: word `i' of `cols'
    estimates restore `model'
    extract_results "`model'" "`col'"
    local i = `i' + 1
}

* 输出到Excel
export excel using "基准回归结果.xlsx", firstrow(variables) replace

* 显示结果
list 变量 能耗强度_控制变量 能耗强度_无控制变量 非化石能源占比_控制变量 非化石能源占比_无控制变量 碳排强度_控制变量 碳排强度_无控制变量, clean noobs

* 添加显著性说明
display "注：*、**、*** 分别表示在 10%、5%、1% 的水平上显著"

display "基准回归结果已输出到 Excel 文件：基准回归结果.xlsx"