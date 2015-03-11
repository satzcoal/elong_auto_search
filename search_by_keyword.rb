require_relative 'send_http'
require_relative 'find_relation_keyword'
require_relative 'find_title_url'

# Service Object
# 关键词内容查找（单线程）
class SearchByKeyword
  # 类调用方法
  def self.call(keyword)
    self.new(keyword).call
  end

  # 构造器
  # 参数：
  #   keyword 要检索的词
  #
  def initialize(keyword)
    @keyword = keyword
  end

  # 检索方法
  # 返回值：
  #   Http response
  #
  def call
    # 初始化host
    host = 'www.baidu.com'
    # 初始化request
    request = "GET /s?wd=#{@keyword} HTTP/1.0\r\n\r\n"
    # 调用Service Object方法，结果编码转成UTF-8并返回
    SendHttp.call(host, request).force_encoding(Encoding::UTF_8)
  end

  # 查询相关检索词方法
  # 返回值：
  #   关键词数组
  #
  def get_relation_word
    # 首先进行检索，将结果传入Service Object，处理后返回关键词数组
    FindRelationKeyword.call(self.call)
  end

  # 查询标题、地址对方法
  # 参数：
  #   n top N
  # 返回值：
  #   标题、地址对的数组
  #
  def get_top_n_title_url(n)
    # 首先进行检索，将结果传入Service Object，处理后返回标题、地址对数组
    FindTitleUrl.call(self.call, n)
  end
end