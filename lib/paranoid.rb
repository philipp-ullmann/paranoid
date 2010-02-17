require 'active_record'

module Paranoid
  # Call this in your model to enable paranoid
  #
  # Example:
  #
  # class Android < ActiveRecord::Base
  #   paranoid
  # end
  #

  def paranoid(opts = {})
    return if paranoid?

    extend ClassMethods
    include InstanceMethods
  end

  def paranoid?
    false
  end

  module ClassMethods
    def paranoid?
      true
    end
  end

  module InstanceMethods
    def self.included(base)
    end

  end

end

ActiveRecord::Base.class_eval 'extend Paranoid'
