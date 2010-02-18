module Paranoid
  module Relation
    extend ActiveSupport::Concern

    included do
      alias_method_chain :arel, :paranoid
      alias_method_chain :delete_all, :paranoid
    end

    def add_paranoid_condition?
      @add_paranoid = true unless defined?(@add_paranoid)
      @klass.paranoid? && @add_paranoid
    end

    def arel_with_paranoid
      if add_paranoid_condition?
        @arel ||= without_destroyed.arel_without_paranoid
      else
        arel_without_paranoid
      end
    end

    def delete_all_with_paranoid(*args)
      if add_paranoid_condition?
        with_destroyed.delete_all_without_paranoid(*args)
      else
        delete_all_without_paranoid(*args)
      end
    end

    def skip_paranoid_condition
      @add_paranoid = false
    end

    def with_destroyed
      spawn.tap {|relation| relation.skip_paranoid_condition }
    end

    def with_destroyed_only
      where(@klass.paranoid_only_condition).tap {|relation| relation.skip_paranoid_condition }
    end

    def without_destroyed
      where(@klass.paranoid_condition).tap {|relation| relation.skip_paranoid_condition }
    end
  end
end

ActiveRecord::Relation.class_eval { include Paranoid::Relation }
