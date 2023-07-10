#!/usr/bin/env ruby
# A early stage stub of a Lox interpreter adapted along the reading of
# Crafting Interpreters by Robert Nystrom
# https://craftinginterpreters.com/contents.html
require 'readline'
require 'strscan'
require 'English'

Brackets = {
   opening·parenthese: %i[(],
   closing·parenthese: %i[)],
   opening·brace: %i[{],
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
  " //
  and class else fun for if or
  print return super this var while
  †
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
  conjunction: %i[&&],
  disjunction: %i[||],
  # unary prefixed ones
  opposition: %i[-],
  negation: %i[~ ! ¬],
  equapositivization: %i[+],
  # unary suffixed one
  termination: %i[;],
}

# Relational operators whose referent always lead to a binary judgment between
# two referents: predicate of the former over the latter is either false or true.
Relators = {
  # Qualifying a distinct power
  alterpotency: %i[!= ≠],
  # Qualifying an identical power
  equipotency: %i[== ≡],
  # Qualifying a power that is under what surpass the latter referent
  subsurpotency: %i[<= ⩽],
  # Qualifying a power that is above what fall behind the latter referent
  epipropotency: %i[>= ⩾],
  # Qualifying a power that is above the latter referent
  ultrapotency: %i[>],
  # Qualifying a power that is under the latter referent
  infrapotency: %i[<],
}

# List of signs that open an interpretation ambiguity that can only be solved
# by looking at the next one, the combination of both being replaceable by
# the univocal sign provided as latter value.
Ambiguators = {
  '=': %w[= ≡],
  '!': %w[= ≠],
  '<': %w[= ⩽],
  '>': %w[= ⩾],
# The dagger usually indicates a footnote if an asterisk has already been used.
# Asterisk is already heavily used in programming languages with various semantic
# meanings including multiplication, exponentiation, pointer dereferencing,
# unpacking argument lists, and wildcard matching.
# That make obelus a suiter choice of comment introduction.
  '/': %w[/ †],
}

Operators = [Relators.values, Compoundors.values].flatten!
Delemitors = Operators.push(Brackets.values).flatten!.map do |op|
  Regexp.escape(op.to_s)
end
Sclereme = [Operators, Syncategoremata, Autogenemes].flatten

Taxonomy = [
  # A dyadee is a member of a pair, such as false and true in the accordance dyad
  #
  # An eschatophore, that is "end holder", is a sequence such as
  # End-of-Transmission character
  %i[identifier string number dyadee eschatophore],
  Brackets.keys, Syncategoremata, Compoundors.keys, Relators.keys
].reduce(&:+).compact

# Minimal unit of utterrance fragment relevant for lexical analysis.
#
# In compiler terminology, the same notion is often refered to as "lexeme".
# However "lexeme" is highly polysemic, with radically different meanings
# employed in lexicography, lexicology and morphology in addition to the one
# used in informatics.
#
# On its side "lexie", though less frequent, is an already established ter
# that conveys the same meaning unambigously with a close morphology.
#
# For similar reasons hereafter we use "emblem" in place of the more populars
# "token" or symbol and "referent" rather than "literal".
Lexie = Struct.new *%i[type emblem referent lemma locus] do
  def to_s = %{#{emblem}: \t#{type}\t flexion of "#{lemma}", standing for "#{referent}"\t at #{locus}}
  def to_h = {emblem:, type:}
end

# Holds everything useful for lexical analysis of Lox code
class Disloxator < StringScanner
  Modulators = %q{// "}.split(' ')
  Morphemes = /\w+|[[:punct:]]+/
  Numeric = /\A\d+(\.\d+)?\z/
  def initialize(code, ordinate)
    super code
    @ordinate = ordinate
    # Modulator of code interpretation, that allows to apply a contextually
    # pertaining construction.
    #
    # Exegesis is a specific approach within hermeneutics, the theory
    # of interpretation, that focuses on extracting or drawing out the meaning
    # from a particular utterance.
    #
    # The main interpretation is *allusive*, as it is chiefly a game of indirect
    # references. Then *quotational* is only "almost" verbatim since both backslash
    # and quotation mark have a special meaning in it. Finally, *commentarial*
    # might have been a third explicited case, but within this implementation
    # it proved more practical to treat it as an adjacent case of ambiguities.
    @exegesis = :allusive
    # Storage to pile referents along their construction, such as multiline strings
    @protolexie = ''
  end
  # Retrieve a single grapheme at a time
  def sip = self.scan /./

  def categorize(emblem)
    return :numeric if emblem.match?(Numeric)
    return :comment if emblem.match?(/\A\/\/|\A†/)
    return :dysmorphism if emblem.match?(/\A\d/)
    return :string if emblem.match /"(?:\\"|[^"])*"/

    [Brackets, Relators, Compoundors,].each do |hash|
      hit = hash.keys.find { |key| hash[key].include?(emblem) }
      return hit unless not hit
    end

    return :autogeneme if Autogenemes.include?(emblem)
    return :syncategoreme if Syncategoremata.include?(emblem)

    return :identifier
  end

  # Returns which exegesis modality should be applied thereupon considering the
  # given token, also taking implicitely @exegesis into consideration.
  def accommodate(emblem)
    if @exegesis == :allusive && emblem == '"'
      return :quotational
    end

    return @exegesis
  end

  def lexize(emblem, start, arrival)
    type = categorize(emblem.to_sym)
    referent = type == :autogeneme ? emblem : nil
    # Simple lemmatisation, replacing ambiguous digraphs with univocal allomorph
    lemma =
      Ambiguators.keys.any?{emblem.start_with?(_1.to_s)} ?
        emblem.sub(/\A../, Ambiguators[emblem[0].to_sym].last) :
        emblem
    locus = { abscissa: [start, arrival], ordinate: @ordinate }
    return Lexie.new(type, emblem, referent, lemma, locus)
  end

  # Return true if the current position is on the last grapheme of a lexie
  def boundary?
    delimitations = /#{Delemitors.join('|')}|\s|\n/
    [@protolexie[-1], rest[0]].any?{_1.to_s.match?(delimitations)} || eos?
  end

  def lexies
    return to_enum(__method__) unless block_given?

    start = pos
    @protolexie = ''
    while @protolexie.concat sip.to_s
      @exegesis = accommodate(@protolexie[-1])
      case @exegesis
      when :allusive
        next unless boundary?

        symbol = @protolexie.to_sym
        # if an ambiguator appears elsewhere than before an end of line
        if Ambiguators.keys.include? symbol
          complementary = Ambiguators[symbol].first
          sequent, digraphic = (->(sign) {[sign, sign == complementary]})[sip]
          @protolexie.concat(sequent.to_s) unless sequent&.match?(/\s/)
        end
        # This is a comment, it will absorb the rest of the line
        @protolexie.concat(scan(/.*/)) if @protolexie.match? /\A\/\/|†/

        term, @protolexie = @protolexie, ''
        skip /\s*/
        yield lexize term, start, pos

      # Within a quote, when didn’t reach a quotation mark yet, take all but that
      when :quotational
        @protolexie.concat(scan(/[^"]*/))
        # note that exegesis is unchanged and nothin is yield
        @protolexie.concat sip
        # quotation mark without odd number of backslash escape characters?
        if @protolexie[-1] == '"' && @protolexie.chomp.match(/\\*$/).to_s.size.even?
          @exegesis, term, @protolexie = :allusive, @protolexie, ''
          yield lexize term, start, pos
        end
      end

      break if eos?
    end
  end

end

Notification = Struct.new(:method, :context, :code ) do
  def ply = send(method, "error: #{context}: #{code}")
end

class Gloxinia
  def initialize
    # Unless some not yet managed error occured, all is in steady state
    @steady = true
  end

  def run_file(filename)
    File.readlines(filename).each.with_index(1) do |line, row|
      run line, row rescue begin @steady = false; ado = $ERROR_INFO.message end
      Notification.new(:abort, "#{filename}:#{row}", line).ply unless @steady
    end
  end

  def run_repl
    puts "Launching REPL...\n"
    ordinate = 0
    while line = Readline.readline("#{ordinate.to_s.rjust(4, "0")}> ", true) do
      run line, ordinate rescue begin @steady = false; ado = $ERROR_INFO.message end
      # Some error occured, we report that and bounce back in steady state
      Notification.new(:puts, "invalid line of code\n#{ado}", line).ply unless @steady
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

# Check if the library is being called as a script
if $PROGRAM_NAME == __FILE__
  Gloxinia.new.play(ARGV)
end
