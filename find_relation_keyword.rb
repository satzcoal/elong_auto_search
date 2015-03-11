#encoding: utf-8
class FindRelationKeyword
  def self.call(res)
    self.new(res).call
  end

  def initialize(res)
    @res = res
  end

  def call
    @res = @res.match(/相关搜索<\/div>.*?<tbody>(.*?)<\/tbody>/u)[1]
  end
end