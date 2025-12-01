cd "D:\Stata17\did"
sysdir set PLUS "D:\Stata17\ado\plus"
*ssc install reghdfe
*ssc install ftools
*ssc install coefplot, replace
*ssc install e
import excel "季度.xlsx", firstrow clear

* 处理policy_time变量
gen policy_group = policy_season
replace policy_group = 0 if missing(policy_group)

* 生成处理变量
gen post = (season >= policy_group & !missing(policy_group))
replace post = 0 if missing(policy_group)

* 生成DID交乘项
gen did = degree * post

* 定义因变量
gen y1 = 电力行业碳排
gen y2 = 工业过程碳排
gen y3 = 建筑物能源碳排
gen y4 = 工业燃烧碳排
gen y5 = 浪费碳排
gen y6 = 农业碳排
gen y7 = 燃烧能源碳排
gen y8 = 运输碳排
gen y = 总碳排

*分组指标
gen intensity = 总碳排

* 分位数分组
sum intensity, detail
gen intensity_high1 = (intensity <= r(p100) & intensity > r(p75)) if !missing(intensity)
gen intensity_high2 = (intensity <= r(p75) & intensity > r(p50)) if !missing(intensity)
gen intensity_high3 = (intensity <= r(p50) & intensity > r(p25)) if !missing(intensity)
gen intensity_high4 = (intensity <= r(p25)) if !missing(intensity)
gen intensity_high5 = (intensity > r(p50)) if !missing(intensity)
gen intensity_high6 = (intensity <= r(p50)) if !missing(intensity)

* 创建结果存储矩阵
matrix results = J(10, 7, .)  // 增加一行用于样本量
matrix rownames results = "总碳排" "电力行业碳排" "工业过程碳排" "建筑物能源碳排" "工业燃烧碳排" "浪费碳排" "农业碳排" "燃烧能源碳排" "运输碳排" "样本数"
matrix colnames results = "全样本" "100-75分位数" "75-50分位数" "50-25分位数" "25-0分位数" "100-50分位数" "50-0分位数"

* 创建标准误存储矩阵
matrix se_results = J(9, 7, .)
matrix rownames se_results = "总碳排" "电力行业碳排" "工业过程碳排" "建筑物能源碳排" "工业燃烧碳排" "浪费碳排" "农业碳排" "燃烧能源碳排" "运输碳排"
matrix colnames se_results = "全样本" "100-75分位数" "75-50分位数" "50-25分位数" "25-0分位数" "100-50分位数" "50-0分位数"
* 创建样本量存储矩阵
matrix N_results = J(7, 1, .)  // 存储每个分位数组的样本量
matrix rownames N_results = "全样本" "100-75分位数" "75-50分位数" "50-25分位数" "25-0分位数" "100-50分位数" "50-0分位数"

* 计算各分组的样本量
quietly count if !missing(y, did, 工业结构, 城市化水平, 人口密度, 技术进步, 财政自给率)
matrix N_results[1, 1] = r(N)
quietly count if intensity_high1 == 1 & !missing(y, did, 工业结构, 城市化水平, 人口密度, 技术进步, 财政自给率)
matrix N_results[2, 1] = r(N)
quietly count if intensity_high2 == 1 & !missing(y, did, 工业结构, 城市化水平, 人口密度, 技术进步, 财政自给率)
matrix N_results[3, 1] = r(N)
quietly count if intensity_high3 == 1 & !missing(y, did, 工业结构, 城市化水平, 人口密度, 技术进步, 财政自给率)
matrix N_results[4, 1] = r(N)
quietly count if intensity_high4 == 1 & !missing(y, did, 工业结构, 城市化水平, 人口密度, 技术进步, 财政自给率)
matrix N_results[5, 1] = r(N)
quietly count if intensity_high5 == 1 & !missing(y, did, 工业结构, 城市化水平, 人口密度, 技术进步, 财政自给率)
matrix N_results[6, 1] = r(N)
quietly count if intensity_high6 == 1 & !missing(y, did, 工业结构, 城市化水平, 人口密度, 技术进步, 财政自给率)
matrix N_results[7, 1] = r(N)

* 循环运行所有回归并存储结果
forval i = 0/8 {
    local row = `i' + 1
    
    forval j = 1/7 {
        if `j' == 1 {
            // 全样本回归
            if `i' == 0 {
                capture reghdfe y did 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id season) vce(cluster id)
            }
            else {
                capture reghdfe y`i' did 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id season) vce(cluster id)
            }
        }
        else if `j' == 2 {
            // 100-75分位数
            if `i' == 0 {
                capture reghdfe y did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high1 == 1, absorb(id season) vce(cluster id)
            }
            else {
                capture reghdfe y`i' did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high1 == 1, absorb(id season) vce(cluster id)
            }
        }
        else if `j' == 3 {
            // 75-50分位数
            if `i' == 0 {
                capture reghdfe y did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high2 == 1, absorb(id season) vce(cluster id)
            }
            else {
                capture reghdfe y`i' did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high2 == 1, absorb(id season) vce(cluster id)
            }
        }
        else if `j' == 4 {
            // 50-25分位数
            if `i' == 0 {
                capture reghdfe y did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high3 == 1, absorb(id season) vce(cluster id)
            }
            else {
                capture reghdfe y`i' did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high3 == 1, absorb(id season) vce(cluster id)
            }
        }
        else if `j' == 5 {
            // 25-0分位数
            if `i' == 0 {
                capture reghdfe y did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high4 == 1, absorb(id season) vce(cluster id)
            }
            else {
                capture reghdfe y`i' did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high4 == 1, absorb(id season) vce(cluster id)
            }
        }
        else if `j' == 6 {
            // 100-50分位数
            if `i' == 0 {
                capture reghdfe y did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high5 == 1, absorb(id season) vce(cluster id)
            }
            else {
                capture reghdfe y`i' did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high5 == 1, absorb(id season) vce(cluster id)
            }
        }
        else if `j' == 7 {
            // 50-0分位数
            if `i' == 0 {
                capture reghdfe y did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high6 == 1, absorb(id season) vce(cluster id)
            }
            else {
                capture reghdfe y`i' did 工业结构 城市化水平 人口密度 技术进步 财政自给率 if intensity_high6 == 1, absorb(id season) vce(cluster id)
            }
        }
        
        // 存储系数和标准误
        if _rc == 0 {
            matrix results[`row', `j'] = _b[did]
            matrix se_results[`row', `j'] = _se[did]
        }
        else {
            matrix results[`row', `j'] = .
            matrix se_results[`row', `j'] = .
        }
    }
}

* 将样本量添加到结果矩阵的最后一行
forval j = 1/7 {
    matrix results[10, `j'] = N_results[`j', 1]
}

* 显示矩阵检查
matrix list results

* 创建输出表格
preserve
clear
set obs 10

* 创建变量名
gen 碳排放类型 = ""
forval i = 1/10 {
    local name : word `i' of "总碳排" "电力行业碳排" "工业过程碳排" "建筑物能源碳排" "工业燃烧碳排" "浪费碳排" "农业碳排" "燃烧能源碳排" "运输碳排" "样本数"
    replace 碳排放类型 = "`name'" in `i'
}

* 添加系数显示（带星号）
gen 全样本 = ""
gen 分位数100_75 = ""
gen 分位数75_50 = ""
gen 分位数50_25 = ""
gen 分位数25_0 = ""
gen 分位数100_50 = ""
gen 分位数50_0 = ""

forval i = 1/10 {
    forval j = 1/7 {
        local coef = results[`i', `j']
        
        if `coef' != . {
            // 对于样本数行，直接显示数字
            if `i' == 10 {
                local display_value = string(`coef', "%9.0f")
            }
            // 对于系数行，显示系数和星号
            else {
                local se = se_results[`i', `j']
                if `se' != . {
                    local t = abs(`coef'/`se')
                    local star = ""
                    if `t' > 2.58 local star = "***"
                    else if `t' > 1.96 local star = "**" 
                    else if `t' > 1.65 local star = "*"
                    
                    local display_value = string(`coef', "%9.3f") + "`star'"
                }
                else {
                    local display_value = ""
                }
            }
        }
        else {
            local display_value = ""
        }
        
        if `j' == 1 {
            replace 全样本 = "`display_value'" in `i'
        }
        else if `j' == 2 {
            replace 分位数100_75 = "`display_value'" in `i'
        }
        else if `j' == 3 {
            replace 分位数75_50 = "`display_value'" in `i'
        }
        else if `j' == 4 {
            replace 分位数50_25 = "`display_value'" in `i'
        }
        else if `j' == 5 {
            replace 分位数25_0 = "`display_value'" in `i'
        }
        else if `j' == 6 {
            replace 分位数100_50 = "`display_value'" in `i'
        }
        else if `j' == 7 {
            replace 分位数50_0 = "`display_value'" in `i'
        }
    }
}

* 导出到Excel
export excel using "分组回归结果.xlsx", firstrow(variables) replace

* 显示结果
list
restore