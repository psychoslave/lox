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
# Intrinsic terms whose denomination immediately gives the term used to refer to them.
#
# "Autogeneme" derives from "auto-", "-gen-" and -"eme", which respectively
# conveys self-reference, production and fundamental structural unit.
#
# So it applies to any term that represents its own value or characteristic.
Autogenemes = %i[false true nil]

# Syncategoreme refers to words that do not have independent meaning on their
# own but are necessary for the structure and function of a phrase.
# These words are often considered "empty" or devoid of autonomous significant
# content.
Syncategoremata = %i[
  and class else fun for if or
  print return super this var while
]
# Componing operators which glue one or more additional terms into a clause whose
# denomination derives from all these assimilated components.
Compoundors = {
  # binary infix ones
  assignment: %i[= ←],
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

# Relational operators whose denomination always lead to a veracity conclusion:
# false, true.
Relators = {
  difference: %i[!= ≠],
  equality: %i[== ≘],
  minimality: %i[<= ⩽],
  maximality: %i[>= ⩾],
  exceedingness: %i[>],
  underness: %i[<],
}

Operators = [Relators.values, Compoundors.values].flatten

Taxnomy = [
  # A dyadee is a member of a pair, such as false and true in the veracity dyad
  #
  # An eschatophore, that is "end holder", is a sequence such as assignment
  # End-of-Transmission character
  %i[identifier string number dyadee eschatophore],
  Brackets.keys, Syncategoremata, Compoundors.keys, Relators.keys
].reduce(&:+).compact

# Holds everything useful for lexical analysis of Lox code
class Disloxator < StringScanner
  Morphemes = /\w+|[[:punct:]]/
  Numeric = /\A\d+(\.\d+)?\z/
  def initialize(code, ordinate)
    super code
    @ordinate = ordinate
  end
  # Ignore leading spaces then capture next valid morphe if any
  def sip = self.scan(/\s+/).then{ self.scan(Numeric) || self.scan(Morphemes) }

  def categorize(token)
    return :numeric if token.match?(Disloxator::Numeric)
    return :dysmorphism if token.match?(/\A\d/)

    [Brackets, Compoundors, Relators].each do |hash|
      hit = hash.keys.find { |key| hash[key].include?(token) }
      return hit unless not hit
      #puts ">info: '#{token}' not in #{hash.values.flatten}"
    end

    return :syncategoreme if Syncategoremata.include?(token)
    return :autogeneme if Autogenemes.include?(token)
    #puts ">info: '#{token}' not in reserved words"

    return :identifier
  end

  def lexies
    lexies = []
    until eos? do
      start, token, arrival = [pos, sip, pos]
      next if eos? && token.nil?
      type = categorize(token.to_sym)
      denomination = token
      locus = {abscissa: [start, arrival], ordinate: @ordinate}
      lexies.push Lexie.new(type, token, denomination, locus)
    end
    lexies
  end
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
    Disloxator.new(code, ordinate).lexies.each{puts _1}
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
