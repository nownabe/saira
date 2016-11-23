module Saira
  class VirtualMachine
    attr_reader :iseq

    def initialize(iseq)
      @iseq = iseq
    end

    def run
      puts iseq.disasm
    end
  end
end
