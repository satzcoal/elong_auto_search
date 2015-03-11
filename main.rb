#encoding: utf-8
require_relative 'search_by_keyword'
require 'set'

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
    if @total_keys_arr.size < limit
      unsearch_arr.each do |ins|
        tmp_arr = SearchByKeyword.new(ins).get_relation_word
        tmp_arr.each do |next_ins|
          next_arr.add(next_ins) unless @total_keys_arr.add?(next_ins)
          return if @total_keys_arr.size >= limit
        end
      end
    end
    do_fill_total_keys(next_arr, limit) if next_arr.size != 0
  end

  def fill_title_and_url_by_total_keys(limit)
    @total_keys_arr.each do |key|
      t_u_pairs = SearchByKeyword.new(key).get_top_n_title_url(limit)
      t_u_pairs.each do |pair|
        title, url = pair
      end
    end
  end

  def total_keys
    @total_keys_arr
  end
end

#as = AutoSearch.new('哈弗')
#as.fill_total_keys(15)
#as.fill_title_and_url_by_total_keys(10)
SearchByKeyword.new('哈弗').get_top_n_title_url(5)