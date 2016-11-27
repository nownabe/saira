module Saira
  class VirtualMachine
    attr_reader :iseq, :stack, :main, :ep

    def initialize(iseq)
      @iseq = iseq
      @stack = []
      @main = generate_main
      iseq.to_a[4][:local_size].times { push nil }
      @ep = stack.size
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
      when :setlocal
        stack[ep - operand[0]] = pop
      when :getlocal
        push stack[ep - operand[0]]
      when :putnil
        push nil
      when :newarray
        push Array.new(operand[0]) { pop }.reverse
      when :getconstant
        klass = pop
        if klass.nil?
          push Module.const_get(operand[0])
        else
          push klass.const_get(operand[0])
        end
      when :tostring
        push pop.to_s
      when :concatstrings
        push Array.new(operand[0]) { pop }.reverse.join
      end
      print_stack
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

    def print_stack
      $stderr.print "======== Stack: "
      $stderr.print stack[0...ep]
      $stderr.print " | "
      $stderr.puts stack[ep..-1].inspect
    end
  end
end
