# frozen_string_literal: true

module Mutant
  module Meta
    class Example
      include Adamantium

      include Anima.new(
        :expected,
        :location,
        :lvars,
        :node,
        :operators,
        :original_source,
        :types
      )

      class Expected
        include Anima.new(:original_source, :node)
      end

      # Verification instance for example
      #
      # @return [Verification]
      def verification
        Verification.new(example: self, mutations: generated)
      end
      memoize :verification

      # Example identification
      #
      # @return [String]
      def identification
        location.to_s
      end

      # Context of mutation
      #
      # @return [Context]
      def context
        Context.new(
          constant_scope: Context::ConstantScope::None.new,
          scope:,
          source_path:    location.path
        )
      end

      # Original source as generated by unparser
      #
      # @return [String]
      def original_source_generated
        Unparser.unparse(node)
      end
      memoize :original_source_generated

      # Generated mutations on example source
      #
      # @return [Enumerable<Mutant::Mutation>]
      def generated
        Mutator::Node.mutate(
          config: Mutation::Config::DEFAULT.with(operators:),
          node:
        ).map do |node|
          Mutation::Evil.new(subject: self, node:)
        end
      end
      memoize :generated

    private

      def scope
        Scope.new(
          expression: Expression::Namespace::Exact.new(scope_name: 'Object'),
          raw:        Object
        )
      end

    end # Example
  end # Meta
end # Mutant
