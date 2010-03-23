module Paranoid
  module Relation
    extend ActiveSupport::Concern

    included do
      alias_method_chain :arel, :paranoid
      alias_method_chain :delete_all, :paranoid
      alias_method_chain :except, :paranoid
      alias_method_chain :only, :paranoid
    end

    # Returns true if the relation should be scoped to
    # exclude soft deleted records
    def add_paranoid_condition?
      @add_paranoid = true unless defined?(@add_paranoid)
      @klass.paranoid? && @add_paranoid
    end

    # Overrides ActiveRecord::Relation#arel
    def arel_with_paranoid
      if add_paranoid_condition?
        @arel ||= without_destroyed.arel_without_paranoid
      else
        arel_without_paranoid
      end
    end

    # Overrides ActiveRecord::Relation#delete_all
    # forcing delete_all to ignore deleted flag
    def delete_all_with_paranoid(*args)
      if add_paranoid_condition?
        with_destroyed.delete_all_without_paranoid(*args)
      else
        delete_all_without_paranoid(*args)
      end
    end

    # Overrides ActiveRecord::Relation#except
    def except_with_paranoid(*args)
      result = except_without_paranoid(*args)
      result.instance_variable_set(:@add_paranoid, @add_paranoid) if defined?(@add_paranoid)
      result
    end

    # Overrides ActiveRecord::Relation#only
    def only_with_paranoid(*args)
      result = only_without_paranoid(*args)
      result.instance_variable_set(:@add_paranoid, @add_paranoid) if defined?(@add_paranoid)
      result
    end

    # Returns a new relation scoped to include soft deleted records
    def with_destroyed
      clone.tap {|relation| relation.skip_paranoid_condition }
    end

    # Returns a new relation scoped to include only deleted records
    def with_destroyed_only
      where(@klass.paranoid_only_condition).tap {|relation| relation.skip_paranoid_condition }
    end

    # Can be used to force the exclusion of soft deleted records down
    # the chain from a with_destroyed call. *WARNING*: with_destroyed
    # will do nothing after this has been called! So
    # Model.without_destroyed.with_destroyed.all will *NOT* return
    # soft deleted records
    def without_destroyed
      where(@klass.paranoid_condition).tap {|relation| relation.skip_paranoid_condition }
    end

    protected

    # Tell the relation to skip adding the paranoid conditions. DO NOT
    # call directly. Call with_destroyed.
    def skip_paranoid_condition
      @add_paranoid = false
    end
  end
end

ActiveRecord::Relation.class_eval { include Paranoid::Relation }
