class FindTitleUrl
  def self.call(res, n)
    self.new(res, n).call
  end

  def initialize(res, n)
    @res = res
    @n = n
  end

  def call
    res_arr = []
    @res.gsub!("\n", '')
    body_block = @res.match(/<div id="content_left">(.*)<div id="rs">/)
    return nil unless body_block
    body_block = body_block[1]

    while line_block = body_block.match(/c-container.*?<a.*?href.*?"(.*?)".*?>(.*?)<\/a>(.*)/)
      body_block = line_block[3]
      res_arr.push([line_block[2], line_block[1]])
    end

    res_arr
  end
end