require 'mysql2'

# 工具类
class MysqlHelper

  def self.setup(host, database, username, password)
    @@client = Mysql2::Client.new(:host => host, :username => username, :password => password, :database => database)
  end

  def self.client
    @@client
  end
end