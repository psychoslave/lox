#!/usr/bin/env ruby

class Gloxinia
  def initialize
    @repl_mode = false
  end

  def run_file(filename)
    # TODO: Implement file execution logic
    puts "Running file: #{filename}"
  end

  def run_repl
    @repl_mode = true
    puts "Launching REPL..."
    # TODO: Implement REPL logic
  end

  def print_usage
    puts "Usage: gloxinia [filename]"
  end

  def run(args)
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

Gloxinia.new.run(ARGV)

