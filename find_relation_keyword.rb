#encoding: utf-8

class FindRelationKeyword
  def self.call(res)
    self.new(res).call
  end

  def initialize(res)
    @res = res
  end

  def call
    res_arr = []

    relation_block = @res.match(/相关搜索<\/div>.*?<table.*?>(.*?)<\/table>/)

    return nil unless relation_block
    relation_block = relation_block[1]

    while line_block = relation_block.match(/<tr>(.*?)<\/tr>(.*)/)

      relation_block = line_block[2]
      line_block = line_block[1]

      while item_block = line_block.match(/href="(.*?)&.*?">(.*?)<.*?<\/th>(.*)/)
        res_arr.push(item_block[2])
        line_block = item_block[3]
      end
    end
    res_arr
  end
end