module Paranoid
  module JoinAssociation
    extend ActiveSupport::Concern

    included do
      alias_method_chain :conditions, :paranoid
    end

    # Has been an override for ActiveRecord::Associations::JoinDependency::JoinAssociation#association_join
    #def association_join_with_paranoid
    #  return @join if @join
    #  result = association_join_without_paranoid
    #  if reflection.klass.paranoid?
    #    aliased_table = Arel::Table.new(table_name, :as => @aliased_table_name, :engine => arel_engine)
    #    pb = ActiveRecord::PredicateBuilder.new(arel_engine)
    #    result.concat(pb.build_from_hash(reflection.klass.paranoid_condition, aliased_table))
    #  end
    #  result
    #end

    # Don't know how the new version of ActiveRecord builds it's options on EagerLoading
    # adding paranoid conditions when necessary
    def conditions_with_paranoid
      @conditions = conditions_without_paranoid
      @conditions # just pass through
    end

  end
end

ActiveRecord::Associations::JoinDependency::JoinAssociation.class_eval { include Paranoid::JoinAssociation }
