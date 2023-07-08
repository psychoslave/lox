require_relative '../lib/gloxinia'

RSpec.describe Disloxator do
  let(:lexer) { Disloxator }

  describe 'Hello World' do
    it 'returns the lexies for the Hello World code' do
      code = 'print "Hello, World!";'
      expected_lexies = [
        { emblem: 'print', type: :syncategoreme },
        { emblem: '"Hello, World!"', type: :string },
        { emblem: ';', type: :termination },
      ]

      expect(lexer.new(code, nil).lexies.to_a.map(&:to_h)).to eq(expected_lexies)
    end
  end

  describe 'Variable Assignment and Printing' do
    it 'returns the lexies for the variable assignment and printing code' do
      code = <<~LOX
        var number = 1;
        print number;
      LOX

      expected_lexies = [
        { emblem: 'var', type: :syncategoreme },
        { emblem: 'number', type: :identifier },
        { emblem: '=', type: :assignment },
        { emblem: '1', type: :numeric },
        { emblem: ';', type: :termination },
        { emblem: 'print', type: :syncategoreme },
        { emblem: 'number', type: :identifier },
        { emblem: ';', type: :termination },
      ]

      expect(lexer.new(code, nil).lexies.to_a.map(&:to_h)).to eq(expected_lexies)
    end
  end

  describe 'Lonely-line and end-line comments' do
    it 'returns single comment lexie for rest of line after // or †' do
      code = <<~LOX
        var number = 1; // some comment
        print number; † Also with obelus
        // lonely comment on its own line
      LOX

      expected_lexies = [
        { emblem: 'var', type: :syncategoreme },
        { emblem: 'number', type: :identifier },
        { emblem: '=', type: :assignment },
        { emblem: '1', type: :numeric },
        { emblem: ';', type: :termination },
        { emblem: '// some comment', type: :comment },
        { emblem: 'print', type: :syncategoreme },
        { emblem: 'number', type: :identifier },
        { emblem: ';', type: :termination },
        { emblem: '† Also with obelus', type: :comment },
        { emblem: '// lonely comment on its own line', type: :comment },
      ]

      expect(lexer.new(code, nil).lexies.to_a.map(&:to_h)).to eq(expected_lexies)
    end
  end

  describe 'Arithmetic Operations' do
    it 'returns the lexies for the arithmetic operations code' do
      code = <<~LOX
        var x = 5;
        var y = 2;
        var sum = x + y;
        var product = x * y;
        print sum;
        print product;
      LOX

      expected_lexies = [
        { emblem: 'var', type: :syncategoreme },
        { emblem: 'x', type: :identifier },
        { emblem: '=', type: :assignment },
        { emblem: '5', type: :numeric },
        { emblem: ';', type: :termination },
        { emblem: 'var', type: :syncategoreme },
        { emblem: 'y', type: :identifier },
        { emblem: '=', type: :assignment },
        { emblem: '2', type: :numeric },
        { emblem: ';', type: :termination },
        { emblem: 'var', type: :syncategoreme },
        { emblem: 'sum', type: :identifier },
        { emblem: '=', type: :assignment },
        { emblem: 'x', type: :identifier },
        { emblem: '+', type: :addition },
        { emblem: 'y', type: :identifier },
        { emblem: ';', type: :termination },
        { emblem: 'var', type: :syncategoreme },
        { emblem: 'product', type: :identifier },
        { emblem: '=', type: :assignment },
        { emblem: 'x', type: :identifier },
        { emblem: '*', type: :multiplication },
        { emblem: 'y', type: :identifier },
        { emblem: ';', type: :termination },
        { emblem: 'print', type: :syncategoreme },
        { emblem: 'sum', type: :identifier },
        { emblem: ';', type: :termination },
        { emblem: 'print', type: :syncategoreme },
        { emblem: 'product', type: :identifier },
        { emblem: ';', type: :termination },
      ]

      expect(lexer.new(code, nil).lexies.to_a.map(&:to_h)).to eq(expected_lexies)
    end
  end

  describe 'Conditional Statements' do
    it 'returns the lexies for the conditional statements code' do
      code = <<~LOX
        var temperature = 25;
        if (temperature < 0) {
          print "It's freezing!";
        } else if (temperature >= 0 && temperature < 20) {
          print "It's cold.";
        } else {
          print "It's warm outside!";
        }
      LOX

      expected_lexies = [
        { emblem: 'var', type: :syncategoreme },
        { emblem: 'temperature', type: :identifier },
        { emblem: '=', type: :assignment },
        { emblem: '25', type: :numeric },
        { emblem: ';', type: :termination },
        { emblem: 'if', type: :syncategoreme },
        { emblem: '(', type: :opening·parenthese },
        { emblem: 'temperature', type: :identifier },
        { emblem: '<', type: :infrapotency },
        { emblem: '0', type: :numeric },
        { emblem: ')', type: :closing·parenthese },
        { emblem: '{', type: :opening·brace },
        { emblem: 'print', type: :syncategoreme },
        { emblem: '"It\'s freezing!"', type: :string },
        { emblem: ';', type: :termination },
        { emblem: '}', type: :closing·brace },
        { emblem: 'else', type: :syncategoreme },
        { emblem: 'if', type: :syncategoreme },
        { emblem: '(', type: :opening·parenthese },
        { emblem: 'temperature', type: :identifier },
        { emblem: '>=', type: :epipropotency },
        { emblem: '0', type: :numeric },
        { emblem: '&&', type: :conjunction },
        { emblem: 'temperature', type: :identifier },
        { emblem: '<', type: :infrapotency },
        { emblem: '20', type: :numeric },
        { emblem: ')', type: :closing·parenthese },
        { emblem: '{', type: :opening·brace },
        { emblem: 'print', type: :syncategoreme },
        { emblem: '"It\'s cold."', type: :string },
        { emblem: ';', type: :termination },
        { emblem: '}', type: :closing·brace },
        { emblem: 'else', type: :syncategoreme },
        { emblem: '{', type: :opening·brace },
        { emblem: 'print', type: :syncategoreme },
        { emblem: '"It\'s warm outside!"', type: :string },
        { emblem: ';', type: :termination },
        { emblem: '}', type: :closing·brace },
      ]

      expect(lexer.new(code, nil).lexies.to_a.map(&:to_h)).to eq(expected_lexies)
    end
  end
end
