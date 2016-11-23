#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "saira/virtual_machine"

iseq = RubyVM::InstructionSequence.compile_file(ARGV[0], false)
Saira::VirtualMachine.new(iseq).run
