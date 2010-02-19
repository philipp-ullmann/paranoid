module Paranoid
  module ParanoidMethods
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
      alias_method_chain :create_or_update, :paranoid
    end

    module ClassMethods
      # Returns the condition used to scope the return to exclude
      # soft deleted records
      def paranoid_condition
        {destroyed_field => field_not_destroyed}
      end

      # Returns the condition used to scope the return to contain
      # only soft deleted records
      def paranoid_only_condition
        val = field_not_destroyed.respond_to?(:call) ? field_not_destroyed.call : field_not_destroyed
        column_sql = arel_table[destroyed_field].to_sql
        case val
        when nil then "#{column_sql} IS NOT NULL"
        else          ["#{column_sql} != ?", val]
        end
      end

      # Temporarily disables paranoid on the model
      def disable_paranoid
        if block_given?
          @paranoid = false
          yield
        else
          raise 'Only block form is supported'
        end
      ensure
        @paranoid = true
      end
    end

    # Restores the record
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

    # Overrides ActiveRecord::Base#create_or_update
    # to disable paranoid during the create and update operations
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