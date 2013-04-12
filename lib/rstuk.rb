require 'open3'
require 'socket'
require 'timeout'

class SSHFail < RuntimeError
  def initialize server, port
    super "Couldn't get connection to #{server}:#{port}"
  end
end

class Shell

  def self.remote server, port, cmd, opts = {}
    defaults = {exit_code: 0, timeout: 90}
    opts = defaults.merge opts
    self.wait_for server, port, opts[:timeout]
    puts "ssh: #{cmd}"
    self.do \
      "ssh root@#{server}  #{self.ssh_options} -p #{port} \"#{cmd}\"",
      opts[:exit_code]
  end

  def self.local cmd, expected_exit_status = 0
    puts "local: #{cmd}"
    self.do cmd, expected_exit_status
  end

  def self.scp source, server, port, dest
    puts "scp: #{source} root@#{server}:#{dest}"
    self.do "scp #{self.ssh_options} -r -P #{port} #{source} root@#{server}:#{dest}", 0
  end

private

  def self.do cmd, expected_exit_status
    # We want to avoid test failures due to non English Locale
    self.verify \
      expected_exit_status,
      *(Open3.capture3 "LANG=C; #{cmd}")
  end

  def self.verify expected_exit_status, stdout, stderr, status
    unless status.exitstatus == expected_exit_status
      fail "Exit status: %d Stdout: %s Stderr: %s" % [
        status.exitstatus,
        stdout,
        stderr
      ]
    end
    stdout
  end

  def self.ssh_options
    # We want to avoid host key interactive accept question
    "-o 'UserKnownHostsFile /dev/null' -o StrictHostKeyChecking=no"
  end

  def self.wait_for server, port, seconds
    puts "Waiting for ssh."
    Timeout::timeout(seconds) do
      tcp_banner = nil
      until tcp_banner =~ /^SSH-2.0-OpenSSH.*/
        begin
          socket = TCPSocket.new server, port
          tcp_banner = socket.readline.strip
          socket.close
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, EOFError, Errno::ETIMEDOUT
          # Go through the loop again
        end
      end
    end
  rescue Timeout::Error
    raise SSHFail.new server, port
  end

end
