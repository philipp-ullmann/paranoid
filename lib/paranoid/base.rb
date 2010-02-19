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
    #   Must be a 3 element array in the form
    #   [:field_name, 'destroyed value', 'not destroyed value']
    #   Default: [:deleted_at, Proc.new{Time.now.utc}, nil]
    def paranoid(opts = {})
      return if paranoid?
      @paranoid = true

      opts[:field] ||= [:deleted_at, Proc.new{Time.now.utc}, nil]
      class_inheritable_accessor :destroyed_field, :field_destroyed, :field_not_destroyed
      self.destroyed_field, self.field_destroyed, self.field_not_destroyed = opts[:field]

      include Paranoid::ParanoidMethods

      class_eval do
        class << self
          delegate :with_destroyed, :with_destroyed_only, :to => :scoped
        end
      end
    end

    # Returns true if the model is paranoid and paranoid is enabled
    def paranoid?
      @paranoid = false unless defined?(@paranoid)
      @paranoid
    end
  end
end

ActiveRecord::Base.class_eval { extend Paranoid::Base }
