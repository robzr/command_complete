# CommandComplete -> bash command completion handler  -- @robzr
#   The only mandatory argument is tree:, which is a free-form data structure
#   which can be composed of Hashes, Arrays, Procs and Strings.
#
class CommandComplete
  def initialize(
    argv:  ARGV,
    debug: nil,   # to enable debug logging, pass a proc with a single arg (log message)
    env:   ENV,
    tree:)
    @argv, @debug, @env, @tree = argv, debug, env, tree.dup
  end

  # returns boolean if it detects it is being run as a bash 'complete -C' command
  def command_completion_detected?
    debug(
      'command_completion_detected? = ',
      ((File.basename(@env['SHELL'] || '') == 'bash') and
        @env.key?('COMP_LINE') and
        @env.key?('COMP_POINT') and
        (@env['COMP_LINE'] =~ /^#{@argv.first}/))
    )
  end

  # use with bash eval to setup command completion (print to stdout)
  def source(
    spec:     nil,
    command:  File.expand_path(ENV['_']),
    argument: nil
  )
    argument = " #{argument}" if argument
    debug 'source() = ', "complete -C \"#{command}#{argument}\" \"#{spec or File.basename(command)}\""
  end

  # output for use as a bash "complete -C" command (print to stdout)
  def to_s
    @result ||= [traverse(@tree, get_current_command(@argv, @env))].flatten
    debug 'to_s = ', @result.join(', ')
    @result.join("\n")
  end

  private

  def debug(*arg)
    @debug.call(arg.join) if @debug.respond_to?(:call)
    arg.last
  end

  def get_current_command(argv, env)
    command = argv.first
    line = env['COMP_LINE'].slice(0, env['COMP_POINT'].to_i)

    clean_line = line.sub(command, '').sub(/\s*/, '').gsub(/\s+/, ' ')
    words = clean_line.split(/\s/)

    if clean_line.length == 0 or clean_line =~ /\s$/
      [words, nil].flatten
    else
      words
    end
  end

  def traverse(tree, branch=get_current_command)
    debug "traverse(#{tree.inspect}, #{branch.inspect})"
    return [] if tree.nil?

    tree = [tree] if tree.is_a?(String)
    tree = Hash[tree.map { |k| [k, nil] }] if tree.is_a?(Array)

    if tree.respond_to?(:call)
      tree.call(branch)
    elsif tree.is_a?(Hash)
      tree.keys.select { |k| k.is_a? Symbol }.each do |key|
        tree[key.to_s] = tree[key]
        tree.delete(key)
      end
      if branch.length < 2
        tree.keys.select { |key| key.to_s =~ /^#{branch.first}/ } 
      else
        traverse tree[branch.first], branch[1..-1]
      end
    else
      raise ArgumentError.new("Invalid class type in tree: #{tree} (#{tree.class.name})")
    end
  end
end
