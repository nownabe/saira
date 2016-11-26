module Saira
  class VirtualMachine
    attr_reader :iseq, :stack, :main

    def initialize(iseq)
      @iseq = iseq
      @stack = []
      @main = generate_main
    end

    def run
      iseq.to_a.last.each do |instruction|
        next unless instruction.is_a?(Array)
        execute(instruction)
      end
    end

    def execute(instruction)
      opecode = instruction.first
      operand = instruction[1..-1]
      $stderr.puts "==== #{opecode}(#{operand.map(&:inspect).join(', ')})"
      case opecode
      when :putself
        push main
      when :putstring, :putobject, :duparray
        push operand[0]
      when :send
        call_info = operand[0]
        args = Array.new(call_info[:orig_argc]) { pop }.reverse
        receiver = pop
        push receiver.send(call_info[:mid], *args)
      when :leave
      when :pop
        pop
      end
      $stderr.puts "======== Stack: #{stack}"
    end

    def pop
      stack.pop
    end

    def push(val)
      stack.push(val)
    end

    private

    def generate_main
      main = Object.new
      class << main
        def to_s
          "main"
        end
        alias inspect to_s
      end
      main
    end
  end
end
