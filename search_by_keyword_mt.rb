require_relative 'send_http'
require 'set'

class SearchByKeywordMT

  def initialize(keys, thread_count)
    @keys = keys
    @thread_count = thread_count
  end

  def call(handle, *args)
    host = 'www.baidu.com'
    return nil unless key = @keys.pop
    request = "GET /s?wd=#{key} HTTP/1.0\r\n\r\n"

    handle.call(SendHttp.call(host, request).force_encoding(Encoding::UTF_8), *args)
  end

  def do_multi_works(handle, *args)
    threads = []
    res_arr = Set.new
    (@thread_count > @keys.size ? @keys.size : @thread_count).times do
      threads << Thread.new {
        while tmp_arr = self.call(handle, *args)
          tmp_arr.each { |item| res_arr.add item }
        end
      }
    end

    threads.each do |t|
      t.join
    end
    res_arr
  end
end