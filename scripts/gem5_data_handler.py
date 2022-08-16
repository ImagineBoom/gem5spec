import csv
import re
import subprocess
from collections import defaultdict
from pandas import read_csv
from openpyxl import load_workbook
from openpyxl.chart import LineChart, Reference
from openpyxl.utils import get_column_letter, column_index_from_string

# # 根据列的数字返回字母
# print(get_column_letter(2))  # B
# # 根据字母返回列的数字
# print(column_index_from_string('D'))  # 4


import time


# pip3 install openpyxl

#
# 抓取gem5 Ruby Cache l2size 不同变化的数据，汇总成表格
#

def runcmd(command):
    ret = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8",
                         timeout=None)
    if ret.returncode == 0:
        # print("success:", ret)
        return ret.stdout.split('\n')
    else:
        # print("error:", ret)
        return ret.stderr.split('\n')


def grep_data(grep_keys_list, gem5_stats_path_list):
    results_dict = defaultdict(defaultdict)
    for f in gem5_stats_path_list:
        print(f)
        with open(f, 'r', encoding='utf-8') as fr:
            for line in fr.readlines():
                for index, k in enumerate(grep_keys_list):
                    group = re.search(
                        r'(?P<itemName>' + k[
                            0] + r')\s+' + r'(?P<itemValue>(\-|\+)?\d+(\.\d+)?)\s+(?P<itemComments>#.*)',
                        line
                    )
                    if group:
                        results_dict[f][k[1]] = group["itemValue"]
    return results_dict


def set_gem5_stats_path_list_with_ruby_l2_change():
    gem5_stats_path_list = []
    gem5_stats_path_list.extend(
        runcmd(["find /home/lizongping/Desktop/gem5spec/verification24/*/*r/ -name 'gem5_stats.log'"]))
    gem5_stats_path_list.extend(
        runcmd(["find /home/lizongping/Desktop/gem5spec/verification21/*/*r/ -name 'gem5_stats.log'"]))
    gem5_stats_path_list.extend(
        runcmd(["find /home/lizongping/Desktop/gem5spec/verification20/*/*r/ -name 'gem5_stats.log'"]))
    gem5_stats_path_list.extend(
        runcmd(["find /home/lizongping/Desktop/gem5spec/verification25/*/*r/ -name 'gem5_stats.log'"]))

    # gem5_stats_path_list.extend(
    #     runcmd(["find ../data/home/lizongping/Desktop/gem5spec/verification21/*/*r/ -name 'gem5_stats.log'"]))

    gem5_stats_path_list.remove('')
    return gem5_stats_path_list


def set_grep_keys_with_ruby_l2_change():
    # "data,alias"
    return [
        ["system.cpu.ipc", "IPC"],
        ["system.cpu.committedInsts", "Insts"],
        ["system.cpu.numCycles", "Cycles"],
        ["system.ruby.l1_cntrl0.L1Icache.m_demand_hits", "I Cache Hits"],
        ["system.ruby.l1_cntrl0.L1Icache.m_demand_misses", "I Cache Misses"],
        ["system.ruby.l1_cntrl0.L1Icache.m_demand_accesses", "I Cache Accesses"],
        ["system.ruby.l1_cntrl0.L1Dcache.m_demand_hits", "D Cache Hits"],
        ["system.ruby.l1_cntrl0.L1Dcache.m_demand_misses", "D Cache Misses"],
        ["system.ruby.l1_cntrl0.L1Dcache.m_demand_accesses", "D Cache Accesses"],
        ["system.ruby.network.ext_links1.ext_node.L2cache.m_demand_hits", "L2 Cache Hits"],
        ["system.ruby.network.ext_links1.ext_node.L2cache.m_demand_misses", "L2 Cache Misses"],
        ["system.ruby.network.ext_links1.ext_node.L2cache.m_demand_accesses", "L2 Cache Accesses"],
        ["system.ruby.l3_cntrl0.L3cache.m_demand_hits", "L3 Cache Hits"],
        ["system.ruby.l3_cntrl0.L3cache.m_demand_misses", "L3 Cache Misses"],
        ["system.ruby.l3_cntrl0.L3cache.m_demand_accesses", "L3 Cache Accesses"],
        ["system.cpu.commit.loads", "system.cpu.commit.loads"]
    ]


# 生成csv
def gen_csv_with_ruby_l2_change():
    localtime = time.strftime("%Y%m%d", time.localtime())
    # print(str(localtime))
    results_dict = grep_data(set_grep_keys_with_ruby_l2_change(), set_gem5_stats_path_list_with_ruby_l2_change())
    bm_metric_dict: dict[str, dict[str, list[str]]] = {}
    l2_switch_case = {"128k": 0, "256k": 1, "512k": 2, "1M": 3, "2M": 4, "4M": 5}
    gen_file = localtime + "_P8_Ruby_L2_Cache"
    with open("../data/" + gen_file + ".csv", "w+", encoding="utf-8") as fw:
        p8_ruby_l2_cache_writer = csv.writer(fw)
        header = ["Benchmark", "Metrics", "L2=128k", "L2=256k", "L2=512k", "L2=1M", "L2=2M", "L2=4M"]
        p8_ruby_l2_cache_writer.writerow(header)
        for f, v1 in results_dict.items():
            group = re.search(
                r'/ppc_MI_Three_Level_L2_(?P<L2Size>\d+[k|M])/(?P<BM>[\w.]+)/', f
            )
            l2size = group["L2Size"]
            bm = group["BM"]
            for metric, v2 in v1.items():
                bm_metric_dict.setdefault(bm, {}).setdefault(metric, [None] * 6)[l2_switch_case[l2size]] = v2
                # print(metric,v2)
        for bm, v1 in bm_metric_dict.items():
            # for metric, v2 in v1.items():
            for metric in set_grep_keys_with_ruby_l2_change():  # 保持原顺序
                v2 = v1[metric[1]]
                v2.insert(0, metric[1])
                v2.insert(0, bm)
                p8_ruby_l2_cache_writer.writerow(v2)
    # csv->excel
    with open("../data/" + gen_file + ".csv", "r", encoding="utf-8") as fr:
        read_csv(fr).to_excel("../data/" + gen_file + ".xlsx")

    # excel plot
    workbook = load_workbook(filename="../data/" + gen_file + ".xlsx")
    sheet = workbook["Sheet1"]
    sheet.delete_cols(1)  # 删除原默认行号

    # print(sheet.max_row)

    # 计算 cache miss rate
    start_row = 2
    while start_row < sheet.max_row:
        sheet.insert_rows(start_row + 12)
        sheet.insert_rows(start_row + 12)
        sheet.insert_rows(start_row + 9)
        sheet.insert_rows(start_row + 9)
        sheet.insert_rows(start_row + 6)
        sheet.insert_rows(start_row + 6)
        sheet.insert_rows(start_row + 3)
        sheet.insert_rows(start_row + 3)
        # insert metrics
        sheet['B' + str(start_row + 3)] = "I Cache Miss Rate"
        sheet['B' + str(start_row + 4)] = "I Cache Miss / 1000 Insts"
        sheet['B' + str(start_row + 8)] = "D Cache Miss Rate"
        sheet['B' + str(start_row + 9)] = "D Cache Miss / 1000 Insts"
        sheet['B' + str(start_row + 13)] = "L2 Cache Miss Rate"
        sheet['B' + str(start_row + 14)] = "L2 Cache Miss / 1000 Insts"
        sheet['B' + str(start_row + 18)] = "L3 Cache Miss Rate"
        sheet['B' + str(start_row + 19)] = "L3 Cache Miss / 1000 Insts"

        for c in range(column_index_from_string('C'), column_index_from_string('H') + 1):
            column = get_column_letter(c)
            # I Cache Miss Rate  &  I Cache Miss / 1000 Insts
            sheet[column + str(start_row + 3)] = "=" + column + str(start_row + 6) + "/" + column + str(start_row + 7)
            sheet[column + str(start_row + 4)] = "=1000*" + column + str(start_row + 6) + "/" + column + str(start_row + 1)

            sheet[column + str(start_row + 8)] = "=" + column + str(start_row + 11) + "/" + column + str(start_row + 12)
            sheet[column + str(start_row + 9)] = "=1000*" + column + str(start_row + 11) + "/" + column + str(start_row + 1)

            sheet[column + str(start_row + 13)] = "=" + column + str(start_row + 16) + "/" + column + str(start_row + 17)
            sheet[column + str(start_row + 14)] = "=1000*" + column + str(start_row + 16) + "/" + column + str(start_row + 1)

            sheet[column + str(start_row + 18)] = "=" + column + str(start_row + 21) + "/" + column + str(start_row + 22)
            sheet[column + str(start_row + 19)] = "=1000*" + column + str(start_row + 21) + "/" + column + str(start_row + 1)

        chart = LineChart()
        # set x-axis values

        chart.add_data(
            Reference(sheet,
                      min_col=column_index_from_string('B'), max_col=column_index_from_string('H'),
                      min_row=start_row + 4, max_row=start_row + 4),
            from_rows=True,
            titles_from_data=True)

        chart.add_data(
            Reference(sheet,
                      min_col=column_index_from_string('B'), max_col=column_index_from_string('H'),
                      min_row=start_row + 9, max_row=start_row + 9),
            from_rows=True,
            titles_from_data=True)

        chart.add_data(
            Reference(sheet,
                      min_col=column_index_from_string('B'), max_col=column_index_from_string('H'),
                      min_row=start_row + 14, max_row=start_row + 14),
            from_rows=True,
            titles_from_data=True)

        chart.add_data(
            Reference(sheet,
                      min_col=column_index_from_string('B'), max_col=column_index_from_string('H'),
                      min_row=start_row + 19, max_row=start_row + 19),
            from_rows=True,
            titles_from_data=True)

        chart.set_categories(
            Reference(sheet,
                      min_row=1, max_row=1, min_col=column_index_from_string('C'), max_col=column_index_from_string('H'))
        )
        sheet.add_chart(chart, "J" + str(start_row))  # 在工作表上添加图表，并指定图表左上角锚定的单元格。
        workbook.save("../data/" + gen_file + ".xlsx")
        start_row += 24


gen_csv_with_ruby_l2_change()
