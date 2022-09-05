import csv
import re
import subprocess
import datetime
import sys
import os
from collections import defaultdict
from collections import namedtuple

import openpyxl
from pandas import read_csv
from openpyxl import load_workbook
from openpyxl.chart import LineChart, Reference, Series
from openpyxl.utils import get_column_letter, column_index_from_string
from openpyxl.styles import Alignment, Border, Side, Font, PatternFill
from openpyxl.formatting.rule import CellIsRule, FormulaRule

# 在gem5spec目录下调用
begin_time=str(sys.argv[1])
gem5_ckp_results_csv = "./data/gem5/"+begin_time+"/Each_case_ckp_data.csv"
M1_ckp_results_csv = "./data/M1/each_bm_cpt_m1.csv"


def runcmd(command):
    ret = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8",
                         timeout=None)
    if ret.returncode == 0:
        # print("success:", ret)
        return ret.stdout.split('\n')
    else:
        # print("error:", ret)
        return ret.stderr.split('\n')


# 自动设置列宽
def auto_set_column_width(worksheet):
    dims = {}
    for row in worksheet.rows:
        for cell in row:
            # 跳过公式
            if cell.value:
                if cell.value[0]=="=":
                    # print(cell.value)
                    continue
                # 遍历整个表格，把该列所有的单元格文本进行长度对比，找出最长的单元格
                # 在对比单元格文本时需要将中文字符识别为1.7个长度，英文字符识别为1个，这里只需要将文本长度直接加上中文字符数量即可
                # re.findall('([\u4e00-\u9fa5])', cell.value)能够识别大部分中文字符
                # 大写字母的长度近似多0.45
                cell_len = 0.7 * len(re.findall('([\u4E00-\u9FA5])', str(cell.value))) + \
                           len(str(cell.value)) + 0.45 * len(re.findall('([A-Z])', str(cell.value)))
                # print(float(str(cell.font.size)))
                # print(cell.column)
                if cell.font.size:
                    if float(cell.font.size) > 11:
                        cell_len += float(cell.font.size) - 11
                if cell.font.bold:
                    cell_len += 1
                dims[cell.column] = max((dims.setdefault(cell.column, 0), cell_len))
    for col, value in dims.items():
        # 设置列宽，get_column_letter用于获取数字列号对应的字母列号，最后值+2是用来调整最终效果的
        worksheet.column_dimensions[get_column_letter(col)].width = value + 1
        # print(col,value)


# 改变字体的样式,大小,粗体,斜体;wss表示[sheet..]
def pyCellFontStyle(wss, onlyRow=False, rowNumStart: int = 1, onlyCol=False,
                    colNumStart: int = 1, rowAndCol=False, fontName="Times New Roman", fontSize=11, isbold=False,
                    italic=False,set_align=False,horizontal='center',vertical='center',set_border=False,border_style="thin",border_color="000000",
                    border_bottom=False):
    # border_style {'hair', 'mediumDashed', 'thin', 'medium', 'double', 'dashDot', 'mediumDashDotDot', 'mediumDashDot', 'dashDotDot', 'dashed', 'dotted', 'thick', 'slantDashDot'}
    side = Side(border_style=border_style, color=border_color)
    if onlyRow:
        for ws in wss:
            nrows = ws.max_row  # 获得行数
            ncols = ws.max_column
            for j in range(ncols):
                if j + 1 > ncols:
                    return
                # name代表样式，size代表大小，bold代表粗体，italic代表斜体
                ws.cell(rowNumStart, j + 1).font = Font(name=fontName, size=fontSize, bold=isbold, italic=italic)
                if set_align:
                    ws.cell(rowNumStart,j + 1).alignment=Alignment(horizontal=horizontal, vertical=vertical)
                if set_border:
                    ws.cell(rowNumStart,j + 1).border = Border(top=side,bottom=side,left=side,right=side)
                    if border_bottom:
                        ws.cell(rowNumStart,j + 1).border = Border(bottom=side)
    if onlyCol:
        for ws in wss:
            nrows = ws.max_row  # 获得行数
            ncols = ws.max_column
            for i in range(nrows):
                if i + 1> nrows:
                    return
                # name代表样式，size代表大小，bold代表粗体，italic代表斜体
                ws.cell(i + 1, colNumStart).font = Font(name=fontName, size=fontSize, bold=isbold, italic=italic)
                if set_align:
                    ws.cell(i + 1, colNumStart).alignment=Alignment(horizontal=horizontal, vertical=vertical)
                if set_border:
                    ws.cell(i + 1, colNumStart).border = Border(top=side,bottom=side,left=side,right=side)
                    if border_bottom:
                        ws.cell(i + 1, colNumStart).border = Border(bottom=side)
    if rowAndCol:
            for ws in wss:
                nrows = ws.max_row  # 获得行数
                ncols = ws.max_column
                for i in range(nrows):
                    if rowNumStart + i>nrows:
                        continue
                    for j in range(ncols):
                        # name代表样式，size代表大小，bold代表粗体，italic代表斜体
                        if colNumStart + j>ncols:
                            continue
                        ws.cell(rowNumStart + i, colNumStart + j).font = Font(name=fontName, size=fontSize,bold=isbold, italic=italic)
                        if set_align:
                            ws.cell(rowNumStart + i, colNumStart + j).alignment=Alignment(horizontal=horizontal, vertical=vertical)
                        if set_border:
                            ws.cell(rowNumStart + i, colNumStart + j).border = Border(top=side,bottom=side,left=side,right=side)
                            if border_bottom:
                                ws.cell(rowNumStart + i, colNumStart + j).border = Border(bottom=side)
                        # print(rowNumStart + i,colNumStart + j,ws.cell(rowNumStart + i, colNumStart + j).value)


def gen_cmp_results(M1_source_csv_file=M1_ckp_results_csv, gem5_source_csv_file=gem5_ckp_results_csv, write_path="",write_name=""):
    runcmd("mkdir -p ./data/gem5/"+begin_time)
    runcmd("paste -d ',' "+M1_source_csv_file+" "+gem5_source_csv_file+" >./data/gem5/M1_gem5_paste.csv")
    # datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    gen_file="./data/gem5/"+begin_time+"_M1_gem5_SPEC2017_sampling_results" + ".xlsx"
    with open("./data/gem5/M1_gem5_paste.csv", "r", encoding='utf-8') as fr_M1_gem5:
        read_csv(fr_M1_gem5).to_excel(gen_file)
    M1_gem5_ckp_class = namedtuple('M1_gem5_ckp_class',
                                   [
                                       "Benchmark","Checkpoint","Simpts","Weights","CPI_M1","CPI_gem5","WeightedCPI_M1","WeightedCPI_gem5",
                                   ])
    workbook = load_workbook(filename=gen_file)
    workbook._active_sheet_index=1
    sheet1=workbook.create_sheet("summary",0)
    sheet2=workbook.active
    sheet2.title="eachCkp"
    sheet2.delete_cols(1)
    sheet2.insert_cols(2)
    sheet2.insert_cols(6)
    sheet2.insert_cols(8)
    # print(sheet2.max_row)
    sheet2.move_range("J1:"+"J"+str(sheet2.max_row),rows=0,cols=-8)
    sheet2.move_range("M1:"+"M"+str(sheet2.max_row),rows=0,cols=-7)
    sheet2.move_range("N1:"+"N"+str(sheet2.max_row),rows=0,cols=-6)
    sheet2.delete_cols(9,4)
    # 处理sheet1-summary
    initial_data=[["","Benchmark","Sum WeightedCPI(Ckp M1)","Sum WeightedCPI(Ckp gem5)","Total WeightedCPI(Ckp gem5)","Sum WeightedCPI Err(Ckp gem5/M1)","Credibility(Ckp M1)"],
                  ["int","500.perlbench_r"],["int","502.gcc_r"],["int","505.mcf_r"],["int","520.omnetpp_r"],["int","523.xalancbmk_r"],["int","525.x264_r"],["int","531.deepsjeng_r"],["int","541.leela_r"],["int","548.exchange2_r"],["int","557.xz_r"],
                  ["fp","503.bwaves_r"],["fp","507.cactuBSSN_r"],["fp","508.namd_r"],["fp","510.parest_r"],["fp","511.povray_r"],["fp","519.lbm_r"],
                  ["fp","521.wrf_r"],["fp","526.blender_r"],["fp","527.cam4_r"],["fp","538.imagick_r"],["fp","544.nab_r"],["fp","549.fotonik3d_r"],["fp","554.roms_r"],["fp","999.specrand_ir"]]
    for info in initial_data:
        sheet1.append(info)
    sheet1.merge_cells("A2:A11")
    sheet1.merge_cells("A12:A25")

    # 处理shee2-each ckp
    bm_begin_row=0
    bm_end_row=0
    bm=""
    # print(sheet2.max_row)
    sheet2.insert_cols(9)
    sheet2.cell(1,9).value="WeightedCPI Err(Ckp gem5/M1)"
    merge_cols=[]
    delete_rows=[]
    row_num=1
    # 数据清洗
    for row_num,row_cells in enumerate(sheet2["2:"+str(sheet2.max_row)],start=2):
        if row_cells[0].value == "Benchmark" or row_cells[0].value == None:
            # print(row_num)
            delete_rows.append(row_num)
    for row_num in delete_rows[::-1]:
        sheet2.delete_rows(row_num)
    workbook.save("new0.xlsx")
    # 数据处理
    bm_begin_row=2
    sheet2.append(["","","","","","","","",""]) # 最后一行特殊处理，用于识别
    side = Side(border_style="thin", color="000000")
    while bm_end_row<sheet2.max_row:
        bm=sheet2.cell(bm_begin_row,1).value
        for next_row_idx,next_row_cells in enumerate(sheet2[str(bm_begin_row)+":"+str(sheet2.max_row)],start=0):
            if next_row_cells[0].value==bm:
                # print("Y",next_row_idx,next_row_cells[0].value)
                bm_end_row=bm_begin_row+next_row_idx
                for col,cell in enumerate(next_row_cells,start=1):
                    if col >2 :
                        cell.data_type='float'
                    if col == 9:
                        cell.number_format='0.000%'
                        # =IFS(E2=0,"",F2=0,"",G2<>0,(H2-G2)/G2)
                sheet2.cell(bm_end_row,9).value="=IFS(E"+str(bm_end_row)+"=0,\"\",F"+str(bm_end_row)+"=0,\"\",G"+str(bm_end_row)+"<>0,(H"+str(bm_end_row)+"-G"+str(bm_end_row)+")/G"+str(bm_end_row)+")"
            else:
                # print("N",next_row_idx,next_row_cells[0].value,"A"+str(bm_begin_row)+":"+"A"+str(bm_end_row))
                # print(bm_end_row,sheet2.max_row)
                # merge
                for cell in next_row_cells:
                    # print(cell)
                    cell.border = Border(top=Side(border_style="thin", color="999999"))
                area="A"+str(bm_begin_row)+":"+"A"+str(bm_end_row)
                sheet2.merge_cells(area)
                for sheet1row_num,sheet1row_cells in enumerate(sheet1.rows,start=1):
                    if sheet1row_cells[1].value == bm:
                        sheet1row_cells[2].value="=SUMIFS(" \
                                                "eachCkp!G"+str(bm_begin_row)+":G"+str(bm_end_row)+","+ \
                                                "eachCkp!E"+str(bm_begin_row)+":E"+str(bm_end_row)+","+"\"<>0\""+"," \
                                                "eachCkp!F"+str(bm_begin_row)+":F"+str(bm_end_row)+","+"\"<>0\""+\
                                                ")"
                        sheet1row_cells[3].value="=SUMIFS(" \
                                                "eachCkp!H"+str(bm_begin_row)+":H"+str(bm_end_row)+","+\
                                                "eachCkp!E"+str(bm_begin_row)+":E"+str(bm_end_row)+","+"\"<>0\""+","+\
                                                "eachCkp!F"+str(bm_begin_row)+":F"+str(bm_end_row)+","+"\"<>0\""+\
                                                ")"
                        sheet1row_cells[4].value="=SUM(eachCkp!H"+str(bm_begin_row)+":H"+str(bm_end_row)+")"
                        sheet1row_cells[5].value=\
                            "=(D"+str(sheet1row_num)+"-C"+str(sheet1row_num)+")"+"/C"+str(sheet1row_num)
                        sheet1row_cells[6].value="=SUMIFS(" \
                                                "'eachCkp'!D"+str(bm_begin_row)+":D"+str(bm_end_row)+","+ \
                                                "'eachCkp'!E"+str(bm_begin_row)+":E"+str(bm_end_row)+","+"\"<>0\""+")"
                        sheet1row_cells[5].number_format='0.000%'
                        sheet1row_cells[6].number_format='0.000%'
                bm_begin_row=bm_begin_row+next_row_idx
                bm_end_row=bm_begin_row
                # print(bm_begin_row)
                break


    # results_compare.writerow(["Benchmark#","Checkpoint#","Simpts","Weights","M1_CPI","gem5_CPI","M1_WeightedCPI","gem5_WeightedCPI"])

    # 样式处理

    # 过滤非0
    sheet2.auto_filter.ref = "A1:I"+str(sheet2.max_row)
    filter_data=[]
    for cells in sheet2["E1"+":"+"E"+str(sheet2.max_row)]:
        if cells[0].value!='0':
            filter_data.append(cells[0].value)
    sheet2.auto_filter.add_filter_column(column_index_from_string("E")-1, filter_data)
    # 修改标题
    sheet2.cell(1,column_index_from_string("E")).value="CPI(Ckp M1)"
    sheet2.cell(1,column_index_from_string("F")).value="CPI(Ckp gem5)"
    sheet2.cell(1,column_index_from_string("G")).value="WeightedCPI(Ckp M1)"
    sheet2.cell(1,column_index_from_string("H")).value="WeightedCPI(Ckp gem5)"

    # 条件格式
    rule2=CellIsRule(operator='between',formula=[-0.25,0.25],fill=PatternFill(end_color='33cc33'))#筛选25%以内的绿色显示
    sheet2.conditional_formatting.add("I1:"+"I"+str(sheet2.max_row),rule2)
    rule3 = FormulaRule(formula=['AND(I2>-0.25,I2<0.25)'], fill=PatternFill(end_color='33cc33'))
    sheet2.conditional_formatting.add("B2:"+"B"+str(sheet2.max_row-1),rule3)
    rule3 = FormulaRule(formula=['AND(F2>-0.25,F2<0.25)'], fill=PatternFill(end_color='33cc33'))
    sheet1.conditional_formatting.add("B2:"+"B"+str(sheet1.max_row-1),rule3)
    sheet1.conditional_formatting.add("F2:"+"F"+str(sheet1.max_row-1),rule3)

    # 设置边框、对齐、字体
    pyCellFontStyle([sheet1,sheet2],onlyRow=True,set_border=True)
    pyCellFontStyle([sheet1,sheet2],rowAndCol=True,set_align=True,horizontal='center',vertical='center')
    pyCellFontStyle([sheet1,sheet2],rowAndCol=True,set_align=True,rowNumStart=2,colNumStart=2,horizontal='justify')
    pyCellFontStyle([sheet2],rowAndCol=True,rowNumStart=2,colNumStart=column_index_from_string("I"),set_align=True,horizontal='right',vertical='justify')
    pyCellFontStyle([sheet1],rowAndCol=True,rowNumStart=2,colNumStart=column_index_from_string("F"),set_align=True,horizontal='right',vertical='justify')
    pyCellFontStyle([sheet1],onlyRow=True,rowNumStart=11,set_border=True,border_bottom=True)
    pyCellFontStyle([sheet1,sheet2],onlyRow=True,isbold=True)
    for col in sheet1.columns:
        col[10].border = Border(bottom= Side(border_style="medium", color="999999"))
        col[sheet1.max_row-1].border = Border(bottom = Side(border_style="medium", color="999999"))
    # 调整宽度
    auto_set_column_width(sheet1)
    auto_set_column_width(sheet2)
    sheet2.column_dimensions["B"].width = sheet2.column_dimensions["B"].width + 2
    sheet2.column_dimensions["C"].width = sheet2.column_dimensions["C"].width + 2
    sheet2.column_dimensions["D"].width = sheet2.column_dimensions["D"].width + 2
    sheet2.column_dimensions["E"].width = sheet2.column_dimensions["E"].width + 2
    sheet2.column_dimensions["F"].width = sheet2.column_dimensions["F"].width + 2
    sheet2.column_dimensions["G"].width = sheet2.column_dimensions["G"].width + 2
    sheet2.column_dimensions["H"].width = sheet2.column_dimensions["H"].width + 2
    sheet2.column_dimensions["I"].width = sheet2.column_dimensions["I"].width + 2
    # 冻结首行, A2是因为会冻结选定单元格左边的所有列和上面的所有行
    sheet1.freeze_panes = 'A2'
    sheet2.freeze_panes = 'A2'
    workbook.active=sheet1
    workbook.save(gen_file)

    print("result Excel: ",os.getcwd()+"/data/gem5/"+begin_time+"_M1_gem5_SPEC2017_sampling_results" + ".xlsx")
    # print(sheet1.max_column)
gen_cmp_results()