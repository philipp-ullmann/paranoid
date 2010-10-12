class Person < ActiveRecord::Base #:nodoc:
  validates_uniqueness_of :name
  has_many :androids, :foreign_key => :owner_id, :dependent => :destroy
end

class Android < ActiveRecord::Base #:nodoc:
  paranoid
  validates_uniqueness_of :name
  has_many :components, :dependent => :destroy
  has_one :sticker
  has_many :memories, :foreign_key => 'parent_id'
  has_many :dents
  has_many :dings, :through => :dents
  has_many :scratches, :through => :dents
  has_and_belongs_to_many :places

  # this code is to ensure that our destroy and restore methods
  # work without triggering before/after_update callbacks
  before_update :raise_hell
  def raise_hell
    raise "hell"
  end
end

class Biped < Android
end

class Dent < ActiveRecord::Base #:nodoc:
  paranoid
  belongs_to :android
  has_many :dings
  has_many :scratches
end

class Ding < ActiveRecord::Base #:nodoc:
  paranoid :field => :not_deleted, :destroyed_value => true, :not_destroyed_value => false
  belongs_to :dent
end

class Scratch < ActiveRecord::Base #:nodoc:
  paranoid
  belongs_to :dent
end

class Component < ActiveRecord::Base #:nodoc:
  paranoid
  belongs_to :android, :dependent => :destroy
  has_many :sub_components, :dependent => :destroy
  NEW_NAME = 'Something Else!'

  after_destroy :change_name
  def change_name
    self.update_attribute(:name, NEW_NAME)
  end
end

class SubComponent < ActiveRecord::Base #:nodoc:
  paranoid
  belongs_to :component, :dependent => :destroy
end

class Memory < ActiveRecord::Base #:nodoc:
  paranoid
  belongs_to :android, :class_name => "Android", :foreign_key => "parent_id"
end

class Sticker < ActiveRecord::Base #:nodoc:
  MM_NAME = "You've got method_missing"

  # this simply serves to ensure that we don't break method_missing
  # if it is implemented on a class and called before is_paranoid
  def method_missing name, *args, &block
    self.name = MM_NAME
  end

  paranoid
  belongs_to :android
end

class AndroidWithScopedUniqueness < ActiveRecord::Base #:nodoc:
  set_table_name :androids
  validates_uniqueness_of :name, :scope => :deleted_at
  paranoid
end

class Place < ActiveRecord::Base #:nodoc:
  paranoid
  has_and_belongs_to_many :androids

  # this code is to ensure that our destroy and restore methods
  # work without triggering before/after_update callbacks
  before_update :raise_hell
  def raise_hell
    raise "hell"
  end
end

class AndroidsPlaces < ActiveRecord::Base #:nodoc:
end

class Ninja < ActiveRecord::Base #:nodoc:
  validates_uniqueness_of :name, :scope => :visible
  paranoid :field => [:visible, false, true]

  alias_method :vanish, :destroy

  # this code is to ensure that our destroy and restore methods
  # work without triggering before/after_update callbacks
  before_update :raise_hell
  def raise_hell
    raise "hell"
  end
end

class Pirate < ActiveRecord::Base #:nodoc:
  paranoid :field => :alive, :destroyed_value => false, :not_destroyed_value => true

  # this code is to ensure that our destroy and restore methods
  # work without triggering before/after_update callbacks
  before_update :raise_hell
  def raise_hell
    raise "hell"
  end
end

class DeadPirate < ActiveRecord::Base #:nodoc:
  set_table_name :pirates
  paranoid :field => :alive, :destroyed_value => true, :not_destroyed_value => false
end

class RandomPirate < ActiveRecord::Base #:nodoc:
  set_table_name :pirates

  after_destroy :raise_an_error
  def raise_an_error
    raise 'after_destroy works'
  end
end

class UndestroyablePirate < ActiveRecord::Base #:nodoc:
  set_table_name :pirates
  paranoid :field => :alive, :destroyed_value => false, :not_destroyed_value => true

  before_destroy :ret_false
  def ret_false
    false
  end
end

class Uuid < ActiveRecord::Base #:nodoc:
  set_primary_key "uuid"

  before_create :set_uuid
  def set_uuid
    self.uuid = "295b3430-85b8-012c-cfe4-002332cf7d5e"
  end

  paranoid
end
