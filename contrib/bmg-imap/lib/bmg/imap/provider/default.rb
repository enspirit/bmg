module Bmg
  module Imap
    class Provider
      #
      # Default provider for servers with no known extensions.
      # Returns empty/default values for all official extra attributes.
      #
      class Default < Provider

        def name
          "default"
        end

      end # class Default
    end # class Provider
  end # module Imap
end # module Bmg
