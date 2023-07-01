#!/usr/bin/env ruby
# A early stage stub of a Lox interpreter adapted along the reading of
# Crafting Interpreters by Robert Nystrom
# https://craftinginterpreters.com/contents.html
require 'readline'
require 'strscan'

Brackets = {
   openening·parenthese: %i[(],
   closing·parenthese: %i[)],
   openening·brace: %i[{],
   closing·brace: %i[}],
}
Syncategoremata = %i[
  and class else false fun for if nil or
  print return super this true var while
]
Componing·operators = {
  # binary infix ones
  subordination: %i[.],
  seriation: %i[,],
  subtraction: %i[-],
  addition: %i[+],
  division: %i[/ ÷],
  multiplication: %i[* ×],
  # unary prefixed ones
  opposition: %i[-],
  negation: %i[~ ! ¬],
  equapositivization: %i[+],
  # unary suffixed one
  termination: %i[;],
}

Relational·operators = {
  assignment: %i[= ←],
  difference: %i[!= ≠],
  equality: %i[== ≘],
  minimality: %i[<= ⩽],
  maximality: %i[>= ⩾],
  exceedingness: %i[>],
  underness: %i[<],
}

Operators = [Relational·operators.values, Componing·operators.values].flatten

Taxnomy = [
  %i[identifier string number dyadee eschatophore],
  Brackets.keys, Syncategoremata, Componing·operators.keys, Relational·operators.keys
].reduce(&:+).compact

class Scanner < StringScanner
  Morphemes = /\w+|[[:punct:]]/
  Numeric = /\d+\.?\d*/
  # Ignore leading spaces then capture next valid morphe if any
  def sip = self.scan(/\s+/).then{ self.scan(Numeric) || self.scan(Morphemes) }
end

Notification = Struct.new(:method, :context, :code ) do
  def ply = send(method, "error: #{context}: #{code}")
end

Lexie = Struct.new *%i[type lexeme literal locus] do
  def to_s = [type, lexeme, literal, locus].join ': '
end

class Gloxinia
  def initialize
    @repl_mode = false
    # Unless some not yet managed error occured, all is in steady state
    @steady = true
  end

  def run_file(filename)
    File.readlines(filename).each.with_index(1) do |line, row|
      run line, row
      Notification.new(:abort, "#{filename}:#{row}", line).ply unless @steady
    end
  end

  def categorize(token)
    return :numeric if token.match?(Scanner::Numeric)

    [Brackets, Componing·operators, Relational·operators].each do |hash|
      hit = hash.keys.find { |key| hash[key].include?(token) }
      return hit unless not hit
      #puts ">info: '#{token}' not in #{hash.values.flatten}"
    end

    return :syncategoreme if Syncategoremata.include?(token)
    #puts ">info: '#{token}' not in reserved words"

    return :identifier
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

  def run(code, ordinate)
    lexies = []
    stream = Scanner.new(code)
    until stream.eos? do
      start, token, arrival = [stream.pos, stream.sip, stream.pos]
      next if stream.eos? && token.nil?
      type = categorize(token.to_sym)
      denomination = token
      locus = {abscissa: [start, arrival], ordinate:}
      lexies.push Lexie.new(type, token, denomination, locus)
    end
    lexies.each{puts _1}
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
