module Bmg
  module Operator
    include Relation

    attr_reader :type
    attr_writer :type
    protected   :type=

    def to_s
      str = "(#{self.class.name.split('::').last.downcase}\n"
      str << operands.map{|op| op.to_s.gsub(/^/m, "  ") }.join("\n")
      str << "\n"
      str << args.map{|a| a.to_s.gsub(/^/m, "  ") }.join("\n")
      str << ")"
      str
    end

    def inspect
      str = "(#{self.class.name.split('::').last.downcase}\n"
      str << operands.map{|op| op.inspect.gsub(/^/m, "  ") }.join("\n")
      str << "\n"
      str << args.map{|a| a.inspect.gsub(/^/m, "  ") }.join("\n")
      str << ")"
      str
    end

  end # module Operator
end # module Bmg
require_relative 'operator/shared/unary'
require_relative 'operator/shared/binary'
require_relative 'operator/shared/nary'

require_relative 'operator/allbut'
require_relative 'operator/autosummarize'
require_relative 'operator/autowrap'
require_relative 'operator/constants'
require_relative 'operator/extend'
require_relative 'operator/group'
require_relative 'operator/image'
require_relative 'operator/join'
require_relative 'operator/matching'
require_relative 'operator/not_matching'
require_relative 'operator/page'
require_relative 'operator/project'
require_relative 'operator/rename'
require_relative 'operator/restrict'
require_relative 'operator/rxmatch'
require_relative 'operator/summarize'
require_relative 'operator/transform'
require_relative 'operator/union'
require_relative 'operator/unwrap'
