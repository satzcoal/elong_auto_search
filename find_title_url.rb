# Service Object
# 查找response中的标题、地址对
class FindTitleUrl
  # 类调用方法
  def self.call(res, n)
    self.new(res, n).call
  end

  # 构造器
  # 参数：
  #   res response
  #   n top N
  def initialize(res, n)
    @res = res
    @n = n
  end

  # 主逻辑
  # 返回值：
  #   title、url对数组 [[title1, url1], [title2, url2], ......]
  def call
    # 初始化结果集
    res_arr = []

    # 替换掉换行符
    @res.gsub!("\n", '')

    # 查找锚点
    body_block = @res.match(/<div id="content_left">(.*)<div id="rs">/)
    # 没有则返回
    return nil unless body_block
    # 自锚点处截取
    body_block = body_block[1]

    # 循环查找cell
    while line_block = body_block.match(/c-container.*?<a.*?href.*?"(.*?)".*?>(.*?)<\/a>(.*)/)
      # 截取后段内容
      body_block = line_block[3]
      # push到结果集
      res_arr.push([line_block[2], line_block[1]])
    end
    # 返回结果集
    res_arr
  end
end