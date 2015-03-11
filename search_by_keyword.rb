require './send_http'
require_relative 'find_relation_keyword'

class SearchByKeyword
  def self.call(keyword)
    self.new(keyword).call
  end

  def initialize(keyword)
    @keyword = keyword
  end

  def call
    host = 'www.baidu.com'
    request = "GET /s?wd=#{@keyword} HTTP/1.0\r\n\r\n"

    res = SendHttp.call(host, request)
    puts FindRelationKeyword.call(res)


  end
end