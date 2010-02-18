module Paranoid
  module Base
    def paranoid(opts = {})
      return if paranoid?
      @paranoid = true

      opts[:field] ||= [:deleted_at, Proc.new{Time.now.utc}, nil]
      class_inheritable_accessor :destroyed_field, :field_destroyed, :field_not_destroyed
      self.destroyed_field, self.field_destroyed, self.field_not_destroyed = opts[:field]

      extend ClassMethods
      include InstanceMethods

      class_eval do
        class << self
          delegate :with_destroyed, :to => :scoped
        end
      end
    end

    def paranoid?
      @paranoid = false unless defined?(@paranoid)
      @paranoid
    end

    module ClassMethods
      def paranoid_condition
        {destroyed_field => field_not_destroyed}
      end

      def paranoid_only_condition
        ["#{table_name}.#{destroyed_field} IS NOT ?", field_not_destroyed]
      end

      def disable_paranoid
        if block_given?
          @paranoid = false
          yield
        end
      ensure
        @paranoid = true
      end
    end

    module InstanceMethods
      extend ActiveSupport::Concern

      included do
        alias_method_chain :create_or_update, :paranoid
      end

      def restore
        set_destroyed(field_not_destroyed.respond_to?(:call) ? field_not_destroyed.call : field_not_destroyed)
        @destroyed = false

        self
      end

      # Override the default destroy to allow us to soft delete records.
      # This preserves the before_destroy and after_destroy callbacks.
      # Because this is also called internally by Model.destroy_all and
      # the Model.destroy(id), we don't need to specify those methods
      # separately.
      def destroy
        _run_destroy_callbacks do
          set_destroyed(field_destroyed.respond_to?(:call) ? field_destroyed.call : field_destroyed)
          @destroyed = true
        end

        self
      end

      protected

      def create_or_update_with_paranoid
        self.class.disable_paranoid { create_or_update_without_paranoid }
      end

      # Set the value for the destroyed field.
      def set_destroyed(val)
        self[destroyed_field] = val
        updates = self.class.send(:sanitize_sql_for_assignment, {destroyed_field => val})
        self.class.unscoped.with_destroyed.where(self.class.arel_table[self.class.primary_key].eq(id)).arel.update(updates)
        @destroyed = true
      end
    end
  end
end

ActiveRecord::Base.class_eval { extend Paranoid::Base }
