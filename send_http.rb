require 'socket'
# Service Object
# 发送Http请求
class SendHttp
  # 类调用方法
  def self.call(host, request, port=80)
    self.new(host, request, port).call
  end

  # 构造器
  # 参数：
  #   host
  #   request
  #   port
  def initialize(host, request, port=80)
    @host = host
    @request = request
    @port = port
  end

  # 主逻辑
  def call
    # 打开Socket连接
    socket = TCPSocket.open(@host, @port)
    # 写入request
    socket.print(@request)
    # 获取response并返回
    socket.read
  end
end