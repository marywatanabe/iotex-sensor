#!/usr/bin/env ruby
# coding: utf-8
#
# 課題3 by 藤原実里
#
require 'csv'
require 'date'
require 'fileutils'
require 'numo/gnuplot'

# 欠損値
miss = 999.9

(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday == 0}.each do |time_from|
###
### データの取得とグラフの作成
### 

  # 公開ディレクトリ
  pubdir = "/iotex/compare_1week/iot-06_iot-07_iot-08_iot-09_iot-10" 
  
  # 公開ディレクトリの作成
  pubdir_temp = "#{pubdir}/temp/#{time_from.strftime("%Y")}"
  FileUtils.mkdir_p(pubdir_temp) until FileTest.exists?(pubdir_temp)
  pubdir_humi = "#{pubdir}/humi/#{time_from.strftime("%Y")}"
  FileUtils.mkdir_p(pubdir_humi)until FileTest.exists?(pubdir_humi)
  pubdir_didx = "#{pubdir}/didx/#{time_from.strftime("%Y")}"
  FileUtils.mkdir_p(pubdir_didx) until FileTest.exists?(pubdir_didx)

  
  # ハッシュと配列の初期化
  time_list = Hash.new #時刻
  temp_list = Hash.new #温度
  humi_list = Hash.new #湿度
  didx_list = Hash.new #不快係数
  
  # csv ファイルから指定された時刻を読み込み. 配列化
  ["iot-06", "iot-07", "iot-08", "iot-09", "iot-10"].each do |myid|
    srcdir = "/iotex/data_csv_10min/#{myid}/"
    time_list[myid] = Array.new #時刻
    temp_list[myid] = Array.new #温度
    humi_list[myid] = Array.new #湿度
    didx_list[myid] = Array.new #不快係数
    Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
      CSV.foreach( csvfile ) do |item|
        
        # 時刻. DateTime オブジェクト化.
        time = DateTime.parse( "#{item[0]} JST" )
        
        # 指定された時刻より後のデータを取得.
        if time >= time_from && time <= time_from + 7 && time.min == 0 
          time_list[myid].push( time )          # 時刻        
          temp_list[myid].push( item[1].to_f )  # 温度
          humi_list[myid].push( item[4].to_f )  # 湿度
          didx_list[myid].push( item[15].to_f ) # 不快係数
        end
      end
    end
  end
  p "plot from #{time_list["iot-07"][0]} to #{time_list["iot-07"][-1]}"
  
  # 温度グラフ作成
  Numo.gnuplot do
    #    debug_on
    set ylabel:   "temperature (C)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_temp}/iot-06_iot-07_iot-08_iot-09_iot-10_temp_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし

    plot [time_list["iot-06"], temp_list["iot-06"], using:'1:($2)', with:"lines", lc_rgb:"red", lw:2, title:"221講義室"],
    [time_list["iot-07"], temp_list["iot-07"], using:'1:($2)', with:"lines", lc_rgb:"blue", lw:2, title:"222講義室"],
    [time_list["iot-08"], temp_list["iot-08"], using:'1:($2)', with:"lines", lc_rgb:"green", lw:2, title:"223講義室"],
    [time_list["iot-09"], temp_list["iot-09"], using:'1:($2)', with:"lines", lc_rgb:"yellow", lw:2, title:"224講義室"],
    [time_list["iot-10"], temp_list["iot-10"], using:'1:($2)', with:"lines", lc_rgb:"black", lw:2, title:"225講義室"]
  end

  # 湿度グラフ作成
  Numo.gnuplot do
    #    debug_on
    set ylabel:   "humidity (%)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_humi}/iot-06_iot-07_iot-08_iot-09_iot-10_temp_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし

    plot [time_list["iot-06"], humi_list["iot-06"], using:'1:($2)', with:"lines", lc_rgb:"red", lw:2, title:"221講義室"],
    [time_list["iot-07"], humi_list["iot-07"], using:'1:($2)', with:"lines", lc_rgb:"blue", lw:2, title:"222講義室"],
    [time_list["iot-08"], humi_list["iot-08"], using:'1:($2)', with:"lines", lc_rgb:"green", lw:2, title:"223講義室"],
    [time_list["iot-09"], humi_list["iot-09"], using:'1:($2)', with:"lines", lc_rgb:"yellow", lw:2, title:"224講義室"],
    [time_list["iot-10"], humi_list["iot-10"], using:'1:($2)', with:"lines", lc_rgb:"black", lw:2, title:"225講義室"]
  end

  # 不快指数グラフ作成 
  Numo.gnuplot do
    #    debug_on
    set ylabel:   "discomfort index"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_didx}/iot-06_iot-07_iot-08_iot-09_iot-10_temp_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし

    plot [time_list["iot-06"], humi_list["iot-06"], using:'1:($2)', with:"lines", lc_rgb:"red", lw:2, title:"221講義室"],
    [time_list["iot-07"], didx_list["iot-07"], using:'1:($2)', with:"lines", lc_rgb:"blue", lw:2, title:"222講義室"],
    [time_list["iot-08"], didx_list["iot-08"], using:'1:($2)', with:"lines", lc_rgb:"green", lw:2, title:"223講義室"],
    [time_list["iot-09"], didx_list["iot-09"], using:'1:($2)', with:"lines", lc_rgb:"yellow", lw:2, title:"224講義室"],
    [time_list["iot-10"], didx_list["iot-10"], using:'1:($2)', with:"lines", lc_rgb:"black", lw:2, title:"225講義室"]
  end
  
end
