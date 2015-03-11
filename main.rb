#encoding: utf-8
require_relative 'search_by_keyword'
require_relative 'search_by_keyword_mt'
require_relative 'find_relation_keyword'
require_relative 'find_title_url'
require 'set'

THREAD_COUNT = 5

class AutoSearch

  def initialize(keyword)
    @keyword = keyword
  end

  def fill_total_keys(limit)
    @total_keys_arr = Set.new
    first_arr = SearchByKeyword.new(@keyword).get_relation_word
    do_fill_total_keys(first_arr, limit)
  end

  def do_fill_total_keys(unsearch_arr, limit)
    next_arr = Set.new
    unsearch_arr.each do |ins|
      tmp_arr = SearchByKeyword.new(ins).get_relation_word
      tmp_arr.each do |next_ins|
        next_arr.add(next_ins) unless @total_keys_arr.add?(next_ins)
        return if @total_keys_arr.size >= limit
      end
    end
    do_fill_total_keys(next_arr, limit) if next_arr.size != 0
  end

  def fill_total_keys_with_MT(limit)
    @total_keys_arr = Set.new
    first_arr = SearchByKeyword.new(@keyword).get_relation_word
    do_fill_total_keys_with_MT(first_arr, limit)
  end

  def do_fill_total_keys_with_MT(unsearch_arr, limit)
    next_arr = []
    tmp_arr = SearchByKeywordGroup.new(unsearch_arr, THREAD_COUNT).do_multi_works(FindRelationKeyword)
    tmp_arr.each do |ins|
      next_arr.push(ins) if @total_keys_arr.add?(ins)
      return if @total_keys_arr.size >= limit
    end
    do_fill_total_keys_with_MT(next_arr, limit) if next_arr.size != 0
  end

  def fill_title_and_url_by_total_keys(limit)
    @t_u_pairs = []
    @total_keys_arr.each do |key|
      tmp_arr = SearchByKeyword.new(key).get_top_n_title_url(limit)
      tmp_arr.each do |pair|
        @t_u_pairs.push pair
      end
    end
  end

  def fill_title_and_url_by_total_keys_with_MT(limit)
    @t_u_pairs = SearchByKeywordGroup.new(@total_keys_arr.to_a, THREAD_COUNT).do_multi_works(FindTitleUrl, limit)
    t_u_pairs.each do |pair|
      title, url = pair
    end
  end

  def total_keys
    @total_keys_arr
  end

  def t_u_pairs
    @t_u_pairs
  end
end

as = AutoSearch.new('哈弗')
as.fill_total_keys_with_MT(3)
p as.total_keys.size
p as.total_keys
as.fill_title_and_url_by_total_keys_with_MT(5)
p as.t_u_pairs

