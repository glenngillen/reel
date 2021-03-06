require 'spec_helper'

describe Reel::Response do
  it "streams enumerables" do
    with_socket_pair do |client, connection|
      client << ExampleRequest.new.to_s
      request = connection.read_request

      connection.respond Reel::Response.new(:ok, ["Hello", "World"])

      response = client.readpartial(4096)
      crlf = "\r\n"
      fixture = "5#{crlf}Hello5#{crlf}World0#{crlf*2}"
      response[(response.length - fixture.length)..-1].should eq fixture
    end
  end

  def with_socket_pair
    host = '127.0.0.1'
    port = 10103

    server = TCPServer.new(host, port)
    client = TCPSocket.new(host, port)
    peer   = server.accept

    begin
      yield client, Reel::Connection.new(peer)
    ensure
      server.close
      client.close
      peer.close
    end
  end
end
