module Paranoid
  module Base
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

    def paranoid?
      @paranoid = false unless defined?(@paranoid)
      @paranoid
    end
  end
end

ActiveRecord::Base.class_eval { extend Paranoid::Base }
