#encoding: utf-8
require_relative 'search_by_keyword'
require_relative 'search_by_keyword_mt'
require_relative 'find_relation_keyword'
require_relative 'find_title_url'
require_relative 'mysql_helper'
require 'set'

# 业务入口类
class AutoSearch

  # 构造器
  # 参数：
  #   keyword 初始给定的检索词
  #
  def initialize(keyword)
    @keyword = keyword
  end

  # 抓取所有相关关键词（单线程）
  # 参数：
  #   limit 目标数量
  #
  def fill_total_keys(limit)
    # 重置结果容器
    @total_keys_arr = Set.new

    # 进行第一次抓取
    first_arr = SearchByKeyword.new(@keyword).get_relation_word

    # 调用递归方法
    do_fill_total_keys(first_arr, limit)
  end

  # 抓取所有相关关键词（多线程）
  # 参数：
  #   limit 目标数量
  #
  def fill_total_keys_with_MT(limit)
    # 重置结果容器
    @total_keys_arr = Set.new

    # 进行第一次抓取
    first_arr = SearchByKeyword.new(@keyword).get_relation_word

    # 调用递归方法
    do_fill_total_keys_with_MT(first_arr, limit)
  end

  # 抓取所有关键词的标题和Url（单线程）
  # 参数：
  #   limit top N
  #
  def fill_title_and_url_by_total_keys(limit)
    # 重置结果容器
    @t_u_pairs = []
    # 轮询关键词Set
    @total_keys_arr.each do |key|
      # 对每一个key进行数据抓取
      tmp_arr = SearchByKeyword.new(key).get_top_n_title_url(limit)
      # 轮询结果集
      tmp_arr.each do |pair|
        # push结果
        @t_u_pairs.push pair
      end
    end
  end

  # 抓取所有关键词的标题和Url（多线程）
  # 参数：
  # limit top N
  #
  def fill_title_and_url_by_total_keys_with_MT(limit)
    # 获取结果集
    @t_u_pairs = SearchByKeywordMT.new(@total_keys_arr.to_a, THREAD_COUNT).do_multi_works(FindTitleUrl, limit)
  end

  # 全部相关关键字数组 访问器
  def total_keys
    @total_keys_arr
  end

  # 标题地址对数组 访问器
  def t_u_pairs
    @t_u_pairs
  end

  # 持久化相关关键词
  def save_total_keys
    @total_keys_arr.each do |key|
      MysqlHelper.client.query("insert into key_words values(null,'#{key}')")
    end
  end

  # 持久化标题Url对
  def save_t_u_pairs
    @t_u_pairs.each do |pair|
      MysqlHelper.client.query("insert into site_infos values(null,'#{pair[0]}','#{pair[1]}')")
    end
  end

  # 私有方法
  private

  # 递归取得相关关键词（单线程）
  # 参数：
  #   unsearch_arr 尚未检索的词集合
  #   limit 目标数量
  #
  def do_fill_total_keys(unsearch_arr, limit)
    # 初始化下次迭代集合
    next_arr = Set.new

    # 轮询未检索词集合
    unsearch_arr.each do |ins|
      # 调用Service Object执行检索，取得相关关键词
      tmp_arr = SearchByKeyword.new(ins).get_relation_word
      # 轮询结果集
      tmp_arr.each do |next_ins|
        # 将新词计入结果集，并计入下次迭代集合
        next_arr.add(next_ins) if @total_keys_arr.add?(next_ins)
        # 如果够数量则退出迭代
        return if @total_keys_arr.size >= limit
      end
    end
    # 进入下一次迭代
    do_fill_total_keys(next_arr, limit) if next_arr.size != 0
  end

  # 递归取得相关关键词（多线程）
  # 参数：
  #   unsearch_arr 尚未检索的词集合
  #   limit 目标数量
  #
  def do_fill_total_keys_with_MT(unsearch_arr, limit)
    # 初始化下次迭代集合
    next_arr = []
    # 调用Service Object执行检索，传入本次迭代所有未检索词，取得所有相关关键词，传入的FindRelationKeyword为进阶处理Service Object
    tmp_arr = SearchByKeywordMT.new(unsearch_arr, THREAD_COUNT).do_multi_works(FindRelationKeyword)
    # 轮询结果集
    tmp_arr.each do |ins|
      # 将新词计入结果集，并计入下次迭代集合
      next_arr.push(ins) if @total_keys_arr.add?(ins)
      # 如果够数量则退出迭代
      return if @total_keys_arr.size >= limit
    end
    # 进入下一次迭代
    do_fill_total_keys_with_MT(next_arr, limit) if next_arr.size != 0
  end
end

# 全局变量：最大进程数量
THREAD_COUNT = 5
# 初始化mysql连接信息
MysqlHelper.setup('localhost', 'elong_auto_search', 'lijingchao', '123456')

# test
as = AutoSearch.new('哈弗')
as.fill_total_keys_with_MT(3)
p as.total_keys.size
p as.total_keys
as.save_total_keys

as.fill_title_and_url_by_total_keys_with_MT(5)
p as.t_u_pairs
as.save_t_u_pairs

