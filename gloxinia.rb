#!/usr/bin/env ruby
# A early stage stub of a Lox interpreter adapted along the reading of
# Crafting Interpreters by Robert Nystrom
# https://craftinginterpreters.com/contents.html
require 'readline'

module Scanner
  def tokens
    self.scan(/[^\s]+/).lazy
  end
end

Notification = Struct.new(:method, :context, :code ) do
  def ply
    send(method, "error: #{context}: #{code}")
  end
end

class Gloxinia
  def initialize
    @repl_mode = false
    # Unless some not yet managed error occured, all is in steady state
    @steady = true
  end

  def run_file(filename)
    File.readlines(filename).each.with_index do |line, row|
      run line
      Notification.new(:abort, "#{filename}:#{row+1}", line).ply unless @steady
    end
  end

  def run_repl
    @repl_mode = true
    puts "Launching REPL...\n"
    while line = Readline.readline('> ', true) do
      run line
      # Some error occured, we report that and bounce back in steady state
      Notification.new(:puts, 'invalid line of code', line).ply unless @steady
      @steady = true
    end
  end

  def run(code)
    puts code.extend(Scanner).tokens.to_a
  end

  def print_usage
    puts "Usage: gloxinia [filename]"
  end

  def play(args)
    case args.length
    when 0
      run_repl
    when 1
      run_file(args[0])
    else
      print_usage
    end
  end
end

Gloxinia.new.play(ARGV)

