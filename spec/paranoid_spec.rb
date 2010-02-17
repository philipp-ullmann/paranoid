require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/models')

LUKE = 'Luke Skywalker'

describe Paranoid do
  before(:each) do
    Sticker.delete_all
    Place.delete_all
    Android.delete_all
    Person.delete_all
    Component.delete_all

    @luke = Person.create(:name => LUKE)
    @r2d2 = Android.create(:name => 'R2D2', :owner_id => @luke.id)
    @c3p0 = Android.create(:name => 'C3P0', :owner_id => @luke.id)

    @r2d2.components.create(:name => 'Rotors')

    @r2d2.memories.create(:name => 'A pretty sunset')
    @c3p0.sticker = Sticker.create(:name => 'OMG, PONIES!')
    @tatooine = Place.create(:name => "Tatooine")
    @r2d2.places << @tatooine
  end
end
