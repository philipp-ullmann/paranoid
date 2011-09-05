module Paranoid
  module JoinAssociation
    extend ActiveSupport::Concern

    included do
      alias_method_chain :initialize, :paranoid
    end

    # Add conditions for eager loading
    def initialize_with_paranoid(reflection, join_dependency, parent = nil)
      result = initialize_without_paranoid(reflection, join_dependency, parent)
      chain.reverse.each_with_index do |reflection, i|
        if reflection.klass.paranoid?
          conditions[i] << reflection.klass.paranoid_condition
        end
      end
      result
    end

  end
end

ActiveRecord::Associations::JoinDependency::JoinAssociation.class_eval { include Paranoid::JoinAssociation }
