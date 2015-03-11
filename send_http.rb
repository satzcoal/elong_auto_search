require 'socket'
class SendHttp
  def self.call(host, request, port=80)
    self.new(host, request, port).call
  end

  def initialize(host, request, port=80)
    @host = host
    @request = request
    @port = port
  end

  def call
    puts @host
    puts @request
    puts @port
    socket = TCPSocket.open(@host, @port)
    socket.print(@request)
    socket.read
  end
end