# CommandComplete
Ruby class for simple bash command completion.

## Description
CommandComplete is a self contained, zero-dependency, compact class whose core function is to translate between a Ruby object (the "tree"), and bash command completion.  While the most typical tree would be a multi-level Hash, a tree could be a String, an Array, a Lambda/Proc, or a mixture of any of these.  Additional functionality is provided to auto-detect whether or not the containing script is being run by bash as a command completion handler, a simple string which can be used by `eval` to setup the completion environment, and debugging hooks.

## Examples
`test.rb` is a self contained, running example.  Run ``eval `./test.rb``` to register the command completion handler with bash (this needs to be done in each shell; and is usually done via in the `.bashrc`/`.bash_profile`, then type `./test.rb <tab><tab>`.

Example object tree, mixture of Hash, Array and Proc, String and Symbol objects.
```
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
```

Example use with auto-detection (this would be placed before parsing command line options):
```
cc = CommandComplete.new(tree: tree)

if cc.command_completion_detected?
  puts cc
  exit
end
```
