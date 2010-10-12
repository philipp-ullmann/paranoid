module Paranoid
  module Base
    # Call this in your model to enable paranoid.
    #
    # === Examples
    #
    #   Post < ActiveRecord::Base
    #     paranoid
    #   end
    #
    #   Item < ActiveRecord::Base
    #     paranoid :field => [:available, fales, true]
    #   end
    #
    # === Options
    #
    # [:field]
    #   The field used to recognize a record as destroyed.
    #   Default: :deleted_at
    #   IsParanoid Compatibility: Also accepts an Array of form
    #   [field_name, destroyed_value, not_destroyed_value]
    #   however :destroyed_value and :not_destroyed_value will
    #   be ignored
    #
    # [:destroyed_value]
    #   The value to set the paranoid field to on destroy.
    #   Can be either a static value or a Proc which will be
    #   evaluated when destroy is called.
    #   Default: Proc.new{Time.now.utc}
    #
    # [:not_destroyed_value]
    #   The value used to recognize a record as not destroyed.
    #   Default: nil
    def paranoid(opts = {})
      return if paranoid?
      @paranoid = true

      opts[:field] ||= [:deleted_at, Proc.new{Time.now.utc}, nil]
      class_inheritable_accessor :destroyed_field, :field_destroyed, :field_not_destroyed
      if opts[:field].is_a?(Array)
        self.destroyed_field, self.field_destroyed, self.field_not_destroyed = opts[:field]
      else
        self.destroyed_field = opts.key?(:field) ? opts[:field] : :deleted_at
        self.field_destroyed = opts.key?(:destroyed_value) ? opts[:destroyed_value] : Proc.new{Time.now.utc}
        self.field_not_destroyed = opts.key?(:not_destroyed_value) ? opts[:not_destroyed_value] : nil
      end

      include Paranoid::ParanoidMethods

      class_eval do
        class << self
          delegate :with_destroyed, :with_destroyed_only, :to => :scoped
        end
      end
    end

    # Returns true if the model is paranoid and paranoid is enabled
    def paranoid?
      @paranoid = (self != ActiveRecord::Base && self.superclass.paranoid?) unless defined?(@paranoid)
      @paranoid
    end
  end
end

ActiveRecord::Base.class_eval { extend Paranoid::Base }
