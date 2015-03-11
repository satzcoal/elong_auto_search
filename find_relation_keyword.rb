#encoding: utf-8

# Service Object
# 查找response中的相关关键词
class FindRelationKeyword
  # 类调用方法
  def self.call(res)
    self.new(res).call
  end

  # 构造器
  # 参数：
  #   res response
  #
  def initialize(res)
    @res = res
  end

  # 主逻辑
  # 返回值：
  #   关键词数组
  def call
    # 初始化结果集
    res_arr = []

    # 替换掉换行符
    @res.gsub!("\n", '')

    # 查找锚点
    relation_block = @res.match(/相关搜索<\/div>.*?<table.*?>(.*?)<\/table>/)

    # 没有则返回
    return nil unless relation_block
    # 自锚点处截取
    relation_block = relation_block[1]

    # 循环查找横向<tr>
    while line_block = relation_block.match(/<tr>(.*?)<\/tr>(.*)/)
      # 截取后段内容
      relation_block = line_block[2]
      # 获取本行内容
      line_block = line_block[1]

      # 循环查找纵向cell
      while item_block = line_block.match(/href="(.*?)&.*?">(.*?)<.*?<\/th>(.*)/)
        # 关联词push进结果集
        res_arr.push(item_block[2])
        # 截取后段内容
        line_block = item_block[3]
      end
    end
    # 返回结果集
    res_arr
  end
end