module Bmg
  module Sql
    module Version

      MAJOR = 0
      MINOR = 17
      TINY  = 0

      def self.to_s
        [ MAJOR, MINOR, TINY ].join('.')
      end

    end
    VERSION = Version.to_s
  end
end
