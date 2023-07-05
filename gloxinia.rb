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
# Intrinsic terms whose reference refers its own referent endoglossomatic
# representation.
#
# "Autogeneme" derives from "auto-", "-gen-" and -"eme", which respectively
# conveys self-reference, production and fundamental structural unit.

# Alternatively the term autogennym where -nym conveys the notion of noun could
# work just as well, with more emphasis on the specific type of involved entity.
#
# Or even more accurately, autoendoglossomaticolexicon might fit with the
# meaning of its decomposition as auto-endo-glosso-matico-lex-icon left as an
# exercise.
#
# Anyway it applies to any term that represents its own refent.
Autogenemes = %i[false true nil]

# Syncategoreme refers to words that do not have independent meaning on their
# own but are necessary for the structure and function of a phrase.
# These words are often considered "empty" or devoid of autonomous significant
# content.
#
# In the context of programming languages, categorizing certain terms as
# syncategorematic makes sense due to their role in structuring and controlling
# the flow of the code.
#
# 1. Control flow: Keywords like "if," "else," and "while" modify the execution
#    flow of the program, introducing conditional statements or loops.
#
# 2. Declaration and definition: Terms like "class," "fun," and "var" are used
#    for declaring and defining entities in the program.
#
# 3. Modifiers and operators: Terms like "and," "or," and "super" serve as
#    logical operators or modifiers, affecting the behavior or logic of
#    expressions or statements.
#
# 4. Output and input: Keywords like "print" and "return" impact the output or
#    values produced by the program.
#
# By categorizing these terms as syncategorematic, we highlight their role in
# shaping the interpretation and behavior of the code, providing structural and
# contextual information for program execution.
Syncategoremata = %i[
  and class else fun for if or
  print return super this var while
]

# Componing operators which glue one or more additional terms into a clause whose
# referent derives from all these assimilated components.
#
# Compounding involves the syntactic and semantic merging of expression
# constituent parts to synthesize a coalescent referent.
Compoundors = {
  # binary infix ones
  assignment: %i[= ←],
  articulation: %i[.],
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

# Relational operators whose referent always lead to a veracity conclusion:
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

Taxonomy = [
  # A dyadee is a member of a pair, such as false and true in the accordance dyad
  #
  # An eschatophore, that is "end holder", is a sequence such as
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
    return :numeric if token.match?(Numeric)
    return :dysmorphism if token.match?(/\A\d/)

    [Brackets, Compoundors, Relators].each do |hash|
      hit = hash.keys.find { |key| hash[key].include?(token) }
      return hit unless not hit
      #puts ">info: '#{token}' not in #{hash.values.flatten}"
    end

    return :autogeneme if Autogenemes.include?(token)
    return :syncategoreme if Syncategoremata.include?(token)
    #puts ">info: '#{token}' not in reserved words"

    return :identifier
  end


  def lexies
    return to_enum(__method__) unless block_given?

    until eos?
      start, token, arrival = [pos, sip, pos]
      next if eos? && token.nil?
      type = categorize(token.to_sym)
      referent = type == :autogeneme ? token : nil
      locus = { abscissa: [start, arrival], ordinate: @ordinate }
      yield Lexie.new(type, token, referent, locus)
    end
  end

end

Notification = Struct.new(:method, :context, :code ) do
  def ply = send(method, "error: #{context}: #{code}")
end

# Minimal unit of utterrance fragment relevant for lexical analysis.
#
# In compiler terminology, the same notion is often refered to as "lexeme".
# However "lexeme" is highly polysemic, with radically different meanings
# employed in lexicography, lexicology and morphology in addition to the one
# used in informatics.
#
# On its side "lexie", though less frequent, is an already established term
# that conveys the same meaning unambigously with a close morphology.
Lexie = Struct.new *%i[type lexeme literal locus] do
  def to_s = [type, lexeme, literal, locus].join ': '
end

class Gloxinia
  def initialize
    # Unless some not yet managed error occured, all is in steady state
    @steady = true
  end

  def run_file(filename)
    File.readlines(filename).each.with_index(1) do |line, row|
      run line, row rescue @steady = false
      Notification.new(:abort, "#{filename}:#{row}", line).ply unless @steady
    end
  end

  def run_repl
    puts "Launching REPL...\n"
    while line = Readline.readline('> ', true) do
      run line rescue @steady = false
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
