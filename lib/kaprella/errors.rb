module Kaprella
  module Errors
    class Base < StandardError
      attr_reader :message, :status

      def initialize(message, status: :unprocessable_entity)
        @message = message
        @status = status
      end
    end

    class RestrictedGeneratedColumnIdentifier < Kaprella::Errors::Base
      def initialize(identifier)
        super("Restricted generated column identifier (matches native attribute or a reserved keyword): #{identifier}")
      end
    end

    class InvalidGeneratedColumnIdentifier < Kaprella::Errors::Base
      def initialize(identifier)
        super("Invalid generated column identifier (alphanumerics and _ only, must not start with a number): #{identifier}")
      end
    end

    class GeneratorFunctionArgumentError < Kaprella::Errors::Base
    end

    class UnknownPropertyIdentifier < Kaprella::Errors::Base
      def initialize(identifier)
        super("Unknown property identifier '#{identifier}'")
      end
    end

    class InvalidFilterExpression < Kaprella::Errors::Base
      def initialize
        super("Invalid filter expression; must be a boolean expression")
      end
    end

    class InvalidSortExpression < Kaprella::Errors::Base
      def initialize
        super("Sort expression must be enclosed by asc() or desc()")
      end
    end

    class UndefinedFunctionError< Kaprella::Errors::Base
      def initialize(name)
        super("Undefined function '#{name}'")
      end
    end
  end
end
