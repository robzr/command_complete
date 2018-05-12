#!/usr/bin/env ruby
# -- @robzr

require_relative 'command_complete'

DEBUG = false
debug_log = Proc.new do |arg|
  File.open('/tmp/command_complete.log', 'a') { |file| file.puts arg }
end

tree = {
  command_one:   {
    flag_one:   'america',
    flag_two:   'canada',
    flag_three: 'denmark',
  },
  command_two:   ['option_a', 'option_b'],
  command_three: lambda { |command_array|
    if command_array.length == 1
      if command_array.first == 'secret'
        'YOU WIN'
      else
        ['!!!', '???']
      end
    end
  }
}

DEBUG and debug_log.call '---'
DEBUG and debug_log.call("ENV: " + ENV.select { |key, value| key =~ /^COMP/ }.inspect)

cc = CommandComplete.new(
  debug: DEBUG ? debug_log : nil,
  tree: tree
)

if cc.command_completion_detected?  # auto-detection is optional; could be flag driven instead
  puts cc.to_s
else
  puts cc.source                    # if flag-driven, use: source(argument: '--the-arg')
end
