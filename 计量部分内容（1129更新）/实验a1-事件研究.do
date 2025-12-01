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

*========================================================
* (1)单位GDP能耗,2017-2022
import excel "年度.xlsx", firstrow clear
keep if year >= 2017 & year <= 2023
xtset id year
gen rel_year = year - 2022

* 创建事件研究虚拟变量（避免多重共线性，省略前一期）
forvalues i = 5(-1)1 {
    local j = -`i'
    gen pre_`i' = (rel_year == `j') * treated
}

forvalues i = 0/1 {
    gen post_`i' = (rel_year == `i') * treated
}

reghdfe 单位GDP能耗 pre_5 pre_4 pre_3 pre_2 post_0 post_1 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id year) vce(cluster id)
estimates store event_能耗

* 保存事件研究系数和置信区间用于绘图
parmest, saving(能耗_event.dta, replace) idstr(能耗)



*========================================================
* (2)单位GDP能耗增长率,2017-2022
import excel "年度.xlsx", firstrow clear
keep if year >= 2017 & year <= 2023
xtset id year
gen rel_year = year - 2022

* 创建事件研究虚拟变量（避免多重共线性，省略前一期）
forvalues i = 5(-1)1 {
    local j = -`i'
    gen pre_`i' = (rel_year == `j') * treated
}

forvalues i = 0/1 {
    gen post_`i' = (rel_year == `i') * treated
}

reghdfe 单位GDP能耗增长率 pre_5 pre_4 pre_3 pre_2 post_0 post_1 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id year) vce(cluster id)
estimates store event_能耗增长率

* 保存事件研究系数和置信区间用于绘图
parmest, saving(能耗增长率_event.dta, replace) idstr(能耗增长率)

*========================================================
* (3)非化石能源占比,2017-2022
import excel "年度.xlsx", firstrow clear
keep if year >= 2017 & year <= 2023
xtset id year
gen rel_year = year - 2022

* 创建事件研究虚拟变量（避免多重共线性，省略前一期）
forvalues i = 5(-1)1 {
    local j = -`i'
    gen pre_`i' = (rel_year == `j') * treated
}

forvalues i = 0/1 {
    gen post_`i' = (rel_year == `i') * treated
}

reghdfe 非化石能源占比 pre_5 pre_4 pre_3 pre_2 post_0 post_1 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id year) vce(cluster id)
estimates store event_非化石能源占比

* 保存事件研究系数和置信区间用于绘图
parmest, saving(非化石能源占比_event.dta, replace) idstr(非化石能源占比)

*========================================================
* (4)非化石能源占比增长率,2017-2022
import excel "年度.xlsx", firstrow clear
keep if year >= 2017 & year <= 2023
xtset id year
gen rel_year = year - 2022

* 创建事件研究虚拟变量（避免多重共线性，省略前一期）
forvalues i = 5(-1)1 {
    local j = -`i'
    gen pre_`i' = (rel_year == `j') * treated
}

forvalues i = 0/1 {
    gen post_`i' = (rel_year == `i') * treated
}

reghdfe 非化石能源占比增长率 pre_5 pre_4 pre_3 pre_2 post_0 post_1 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id year) vce(cluster id)
estimates store event_非化石能源占比增长率

* 保存事件研究系数和置信区间用于绘图
parmest, saving(非化石能源占比增长率_event.dta, replace) idstr(非化石能源占比增长率)

*========================================================
* (5)单位GDP碳排放量,2017-2022
import excel "年度.xlsx", firstrow clear
keep if year >= 2017 & year <= 2023
xtset id year
gen rel_year = year - 2022

* 创建事件研究虚拟变量（避免多重共线性，省略前一期）
forvalues i = 5(-1)1 {
    local j = -`i'
    gen pre_`i' = (rel_year == `j') * treated
}

forvalues i = 0/1 {
    gen post_`i' = (rel_year == `i') * treated
}

reghdfe 单位GDP碳排放量 pre_5 pre_4 pre_3 pre_2 post_0 post_1 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id year) vce(cluster id)
estimates store event_碳排强度

* 保存事件研究系数和置信区间用于绘图
parmest, saving(碳排强度_event.dta, replace) idstr(碳排强度)

*========================================================
* (6)单位GDP碳排放量增长率,2017-2022
import excel "年度.xlsx", firstrow clear
keep if year >= 2017 & year <= 2023
xtset id year
gen rel_year = year - 2022

* 创建事件研究虚拟变量（避免多重共线性，省略前一期）
forvalues i = 5(-1)1 {
    local j = -`i'
    gen pre_`i' = (rel_year == `j') * treated
}

forvalues i = 0/1 {
    gen post_`i' = (rel_year == `i') * treated
}

reghdfe 单位GDP碳排放量增长率 pre_5 pre_4 pre_3 pre_2 post_0 post_1 工业结构 城市化水平 人口密度 技术进步 财政自给率, absorb(id year) vce(cluster id)
estimates store event_碳排强度增长率

* 保存事件研究系数和置信区间用于绘图
parmest, saving(碳排强度增长率_event.dta, replace) idstr(碳排强度增长率)

*========================================================
* 输出结果
esttab event_能耗 event_能耗增长率 event_非化石能源占比 event_非化石能源占比增长率 event_碳排强度 event_碳排强度增长率, ///
    b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    keep(pre_5 pre_4 pre_3 pre_2 post_0 post_1) ///
    mtitles("能耗" "能耗增长" "非化石" "非化石增长" "碳排放" "碳排放增长") ///
    title("事件研究法结果")
	
*========================================================
* 绘制事件研究图
* 首先合并所有事件研究数据
clear
use 能耗_event.dta
append using 能耗增长率_event.dta
append using 非化石能源占比_event.dta
append using 非化石能源占比增长率_event.dta
append using 碳排强度_event.dta
append using 碳排强度增长率_event.dta

* 生成时间变量
gen time = .
replace time = -5 if regexm(parm, "pre_5")
replace time = -4 if regexm(parm, "pre_4")
replace time = -3 if regexm(parm, "pre_3")
replace time = -2 if regexm(parm, "pre_2")
replace time = 0 if regexm(parm, "post_0")
replace time = 1 if regexm(parm, "post_1")

* 添加-1期数据（系数为0）
expand 2 if time == -2, gen(newobs)
replace time = -1 if newobs == 1
replace estimate = 0 if time == -1
replace min95 = 0 if time == -1
replace max95 = 0 if time == -1
drop newobs

* 设置变量标签
label define var_label 1 "能耗" 2 "能耗增长率" 3 "非化石能源占比" 4 "非化石能源占比增长率" 5 "碳排强度" 6 "碳排强度增长率"
encode idstr, gen(varnum) label(var_label)

* 排序
sort varnum time

forvalues i = 1/6 {
    preserve
    keep if varnum == `i'
    
    local varlabel: label (varnum) `i'
    
    // 手动设定每个变量的 y 轴范围
    if "`varlabel'" == "能耗" {
        local ymin = -0.2
        local ymax = 0.2
    }
    else if "`varlabel'" == "能耗增长率" {
        local ymin = -0.2
        local ymax = 0.2
    }
    else if "`varlabel'" == "非化石能源占比" {
        local ymin = -0.1
        local ymax = 0.2
    }
    else if "`varlabel'" == "非化石能源占比增长率" {
        local ymin = -0.2
        local ymax = 0.4
    }
    else if "`varlabel'" == "碳排强度" {
        local ymin = -0.1
        local ymax = 0.3
    }
    else if "`varlabel'" == "碳排强度增长率" {
        local ymin = -0.2
        local ymax = 0.2
    }

    // 创建绘图用变量副本
    gen double estimate_plot = estimate
    gen double min95_plot    = min95
    gen double max95_plot    = max95

    // 将 estimate 超出 [ymin, ymax] 的观测设为缺失（不显示点和线）
    replace estimate_plot = . if estimate_plot < `ymin' | estimate_plot > `ymax'
    replace min95_plot    = . if estimate < `ymin' | estimate > `ymax'
    replace max95_plot    = . if estimate < `ymin' | estimate > `ymax'

    // 可选：将置信区间裁剪到 [ymin, ymax] 内部（防止 rarea 绘图溢出）
    replace min95_plot = max(`ymin', min(`ymax', min95_plot))
    replace max95_plot = max(`ymin', min(`ymax', max95_plot))

    // 设置 ylabel 刻度（根据范围自动设置合适间隔）
    if "`varlabel'" == "能耗" {
        local ylabel_args `ymin'(0.1)`ymax'
    }
    else if inlist("`varlabel'", "能耗增长率", "非化石能源占比", "碳排强度增长率") {
        local ylabel_args `ymin'(0.05)`ymax'
    }
    else if "`varlabel'" == "非化石能源占比增长率" {
        local ylabel_args `ymin'(0.1)`ymax'
    }
    else if "`varlabel'" == "碳排强度" {
        local ylabel_args `ymin'(0.2)`ymax'
    }

    // 绘图命令
    twoway ///
        (rarea min95_plot max95_plot time, color(gray%40) fintensity(40)) ///
        (scatter estimate_plot time, mcolor(blue) msymbol(O) msize(medium)) ///
        (line estimate_plot time, lcolor(blue) lpattern(solid) lwidth(medium)), ///
        xline(-1, lpattern(dash) lcolor(red) lwidth(medium)) ///
        xlabel(-5(1)1, labsize(small)) ///
        yline(0, lpattern(solid) lcolor(black)) ///
        xtitle("相对时间（年）", size(small)) ///
        ytitle("系数估计值", size(small)) ///
        title("`varlabel'", size(medium)) ///
        legend(off) ///
        yscale(range(`ymin' `ymax')) ///
        ylabel(`ylabel_args', angle(horizontal) labsize(small)) ///
        graphregion(color(white)) ///
        plotregion(color(white)) ///
        xsize(4) ysize(3)

    // 保存图形
    graph save "事件研究图_`varlabel'.gph", replace
    graph export "事件研究图_`varlabel'.png", as(png) replace width(2000)

    restore
}

* 合并所有图形 - 创建窄长的大图
graph combine "事件研究图_能耗.gph" "事件研究图_能耗增长率.gph" ///
              "事件研究图_非化石能源占比.gph" "事件研究图_非化石能源占比增长率.gph" ///
              "事件研究图_碳排强度.gph" "事件研究图_碳排强度增长率.gph", ///
              rows(3) cols(2) ///
              title("政策发布冲击事件研究图", size(medium)) ///
              graphregion(color(white)) ///
              plotregion(color(white)) ///
              iscale(*0.8) ///  // 稍微缩小图形元素
              xsize(8) ysize(12)  // 设置窄长的大图比例

graph save "综合事件研究图.gph", replace
graph export "综合事件研究图.png", as(png) replace width(3000)

* 清理临时文件
erase 能耗_event.dta
erase 能耗增长率_event.dta
erase 非化石能源占比_event.dta
erase 非化石能源占比增长率_event.dta
erase 碳排强度_event.dta
erase 碳排强度增长率_event.dta

display "分析完成！所有事件研究图已保存。"