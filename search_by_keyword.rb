require_relative 'send_http'
require_relative 'find_relation_keyword'
require_relative 'find_title_url'

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

    SendHttp.call(host, request).force_encoding(Encoding::UTF_8)
  end

  def get_relation_word
    FindRelationKeyword.call(self.call)
  end

  def get_top_n_title_url(n)
    FindTitleUrl.call(self.call, n)
  end
end