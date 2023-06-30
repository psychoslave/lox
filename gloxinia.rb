#!/usr/bin/env ruby
require 'readline'

module Scanner
  def tokens
    self.scan(/[^\s]+/).lazy
  end
end

class Gloxinia
  def initialize
    @repl_mode = false
    @steady = true
  end

  def run_file(filename)
    File.readlines(filename).each.with_index do |line, row|
      run line
      abort("invalid code: #{filename}:#{row}: #{line}") unless @steady
    end
  end

  def run_repl
    @repl_mode = true
    puts "Launching REPL...\n"
    while line = Readline.readline('> ', true) do
      run line
      puts('invalid code') unless @steady
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

