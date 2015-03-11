require_relative 'send_http'
require 'set'

# Service Object
# 关键词内容查找（多线程）
class SearchByKeywordMT

  # 构造器
  # 参数：
  #   keys 待处理关键词数组
  #   thread_count 最大线程数
  def initialize(keys, thread_count)
    @keys = keys
    @thread_count = thread_count
  end

  # Service Object调用辅助方法
  # 参数：
  #   handle 进阶处理的Service Object
  #   *args 进阶处理的参数
  def call(handle, *args)
    # 若实例内无待处理关键词了则返回
    return nil unless key = @keys.pop
    # 初始化host
    host = 'www.baidu.com'
    # 初始化request
    request = "GET /s?wd=#{key} HTTP/1.0\r\n\r\n"

    # 发送HTTP请求，结果转码后传入进阶处理Service Object，完成后返回结果
    handle.call(SendHttp.call(host, request).force_encoding(Encoding::UTF_8), *args)
  end

  # 多线程主逻辑
  # 参数：
  #   handle 进阶处理的Service Object
  #   *args 进阶处理的参数
  def do_multi_works(handle, *args)
    # 初始化线程池
    threads = []
    # 初始化结果集
    res_arr = Set.new
    # 根据最大线程数量和数据总量确定初始线程数，循环开启初始线程
    (@thread_count > @keys.size ? @keys.size : @thread_count).times do
      # 创建线程，保存到线程池
      threads << Thread.new {
        # 循环处理未处理数据
        while tmp_arr = self.call(handle, *args)
          # add至结果集
          tmp_arr.each { |item| res_arr.add item }
        end
      }
    end

    # 线程同步
    threads.each do |t|
      t.join
    end
    # 返回结果集
    res_arr
  end
end