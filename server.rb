require 'pry'
require 'socket'

class Server

  attr_reader :request_lines

  def initialize
    @request_lines = []
    @counter = 0
    @total_requests = 0
    @shutdown = false
  end


  def run_server
    tcp_server = TCPServer.new(9292)
    
    while @shutdown == false
      client = tcp_server.accept
        while line = client.gets and !line.chomp.empty?
          @request_lines << line.chomp
        end

      response = "<pre>" + "#{user_path}" + "</pre>" 

      output = "<html><head><link rel='shortcut icon' href='about:blank'></head><body>#{response}</body></html>"
      headers = ["http/1.1 200 ok",
                "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
                "server: ruby",
                "content-type: text/html; charset=iso-8859-1",
                "content-length: #{output.length}\r\n\r\n"].join("\r\n")
      client.puts headers
      client.puts output
      client.close
      @request_lines = []
    end
  end

  def user_path
    @total_requests +=1
    path = @request_lines[0].split(" ")[1]
    if path == "/"
      "#{output_diagnostics(@request_lines)}"
    elsif path == "/hello"
      output_hello_world
    elsif path == "/date_time"
      output_date_time
    elsif path == "/shutdown"
      output_shutdown
    elsif path.include? "word_search"
      word_lookup(path)
    end
  end

  def output_diagnostics(request_lines)
      "\n
       VERB: #{request_lines[0].split(" ")[0]}\n
       PATH: #{request_lines[0].split(" ")[1]}\n
       PROTOCOL: #{request_lines[0].split(" ")[2]}\n
       HOST: #{request_lines[1].split(" ")[1].split(":")[0]}\n
       PORT: #{request_lines[1].split(" ")[1].split(":")[1]}\n
       ORIGIN: #{request_lines[1].split(" ")[1].split(":")[0]}\n
       ACCEPT: #{request_lines[3].split(" ")[1]}\n" 
  end

  def output_hello_world
    @counter += 1
    "Hello World #{@counter}"
  end

  def output_date_time
    "<h1>It is #{Time.now.strftime('%a, %e %b %Y %H:%M:%S')}</h1>"
  end

  def output_shutdown
    shutdown_server
    "Total requests: #{@total_requests}"
  end

  def shutdown_server
    @shutdown = true
  end

  def word_lookup(path)
    word = path.split("=")[1]
    dictionary = File.open("/usr/share/dict/words", "r").read.split("\n")
    if dictionary.include?(word)
      "#{word} is a word"
    else
      "#{word} is not a word"
    end
  end

end

server = Server.new
server.run_server