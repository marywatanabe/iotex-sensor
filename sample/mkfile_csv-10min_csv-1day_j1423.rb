#!/usr/bin/env ruby
# coding: utf-8
#
# 表題: データ解析スクリプト. 10 分平均から 1 日平均を作る.
#

require 'csv'
require 'narray'
require 'date'
require 'fileutils'

###
### デバイス毎の設定
###

# デバイス名
myid = ARGV[0]  

# 公開ディレクトリ
pubdir = "/iotex/graph_1month/#{myid}"


###
### 初期化
###

# データ置き場
srcdir = "/iotex/graph_1month/#{myid}"

# 公開ディレクトリの作成
pubdir_temp = "#{pubdir}/temp/#{time_from.strtime("%Y-%m")}"
pubdir_humi = "#{pubdir}/humi/#{time_from.strtime("%Y-%m")}"
pubdir_didx = "#{pubdir}/didx/#{time_from.strtime("%Y-%m")}"
FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?( pubdir_temp )
FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?( pubdir_humi )
FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?( pubdir_didx )

# 欠損値
miss = 999.9

# csv ファイルに含まれる変数の一覧
vars = [
  "time","temp","temp2","temp3","humi","humi2","humi3",
  "dp","dp2","dp3","pres","bmptemp","dietemp","objtemp","lux",
  "didx","didx2","didx3"
]


###
### データの取得とグラフの作成
### 
  
# 配列の初期化
time_list = Array.new
vars_list = Array.new
num = vars.size - 1 # 時刻分を除く
num.times do |i|
  vars_list[i] = Array.new
end

# csv ファイルの読み込み. 配列化
Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
  CSV.foreach( csvfile ) do |item|
#    p item
    
    # 時刻. DateTime オブジェクト化.
    time = DateTime.parse( "#{item[0]} JST" )
    
    # 1ヶ月毎に抽出
    if time >= time_from && time <= (time_from >> 1) && time.min == 0
      time_list.push( time )  # 時刻
      num.times do |i|
        vars_list[i].push( item[i+1].to_f ) #各データ
      end
    end
  end 
end

# NArray オブジェクトへ変換. 解析が容易になる. 
vars_list_narray = Array.new
num.times do |i|
  vars_list_narray[i] = NArray.to_na(vars_list[i])
end

###
### 統計処理
###

# 初期化
count = 24 # 24 時間

# 平均を取る開始時刻の添字. 時刻が 00:00:00 となるよう調整. 
time0= DateTime.new(
  time_list[0].year, time_list[0].month, time_list[0].day + 1,
  0, 0, 0, "JST"
)
idx0 = time_list.index( time0 )

# 平均を取る終了時刻の添字
idx1 = idx0 + count

# 時刻をずらしながら 1 日の統計量を作成する. 
while (time_list[idx0] + 1 < time_list[-1]) do 

  # 配列初期化
  time0  = time_list[idx0]
  mean   = Array.new( num, miss )  # 欠損値
  min    = Array.new( num, miss )  # 欠損値
  max    = Array.new( num, miss )  # 欠損値
  stddev = Array.new( num, miss )  # 欠損値
  median = Array.new( num, miss )  # 欠損値
  
  puts "#{time0} : #{time_list[idx0+1]}..#{time_list[idx1]}"
  
  # 1 つでも欠損値が含まれていたら日平均は欠損値扱いに.
  # 欠損値が含まれていない場合は idx2 は nil になる. 
  idx2 = ( vars_list_narray[0][idx0+1..idx1] ).to_a.index( miss )    
  unless ( idx2 )
    num.times do |i|
      mean[i]  = vars_list_narray[i][idx0+1..idx1].mean(0)
      min[i]   = # ... 自分で書く ...
      max[i]   = # ... 自分で書く ...
      stddev[i]= # ... 自分で書く ...
      median[i]= # ... 自分で書く ...
    end
  end      

  # ファイルの書き出し (平均値)
  csv = open("#{pubdir}/#{myid}_mean.csv", "a")
  csv.puts "#{time0.strftime("%Y/%m/%d")},#{mean.join(',')},\n"
  csv.close
  # 最小・最大・標準偏差・中央値のファイル出力
  # ... 自分で書く ...

  # 添字の更新
  idx0 = idx1 
  idx1 = idx0 + count  # 24時間分進める
end

