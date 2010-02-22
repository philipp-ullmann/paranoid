module Paranoid
  module JoinAssociation
    extend ActiveSupport::Concern

    included do
      alias_method_chain :association_join, :paranoid
    end

    # Overrides ActiveRecord::Associations::ClassMethods::JoinDependency::JoinAssociation#association_join
    # adding paranoid conditions when necessary
    def association_join_with_paranoid
      return @join if @join
      result = association_join_without_paranoid
      if reflection.klass.paranoid?
        aliased_table = Arel::Table.new(table_name, :as => @aliased_table_name, :engine => arel_engine)
        pb = ActiveRecord::PredicateBuilder.new(arel_engine)
        result.concat(pb.build_from_hash(reflection.klass.paranoid_condition, aliased_table))
      end
      result
    end
  end
end

ActiveRecord::Associations::ClassMethods::JoinDependency::JoinAssociation.class_eval { include Paranoid::JoinAssociation }
