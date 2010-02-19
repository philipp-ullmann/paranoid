require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/models')

LUKE = 'Luke Skywalker'

describe Paranoid do
  before(:each) do
    # Sticker.delete_all
    # Place.delete_all
    # Android.delete_all
    # Person.delete_all
    # Component.delete_all
    #
    # @luke = Person.create(:name => LUKE)
    # @r2d2 = Android.create(:name => 'R2D2', :owner_id => @luke.id)
    # @c3p0 = Android.create(:name => 'C3P0', :owner_id => @luke.id)
    #
    # @r2d2.components.create(:name => 'Rotors')
    #
    # @r2d2.memories.create(:name => 'A pretty sunset')
    # @c3p0.sticker = Sticker.create(:name => 'OMG, PONIES!')
    # @tatooine = Place.create(:name => "Tatooine")
    # @r2d2.places << @tatooine
  end

  describe 'basic functionality' do
    before(:each) do
      Place.delete_all
      @tatooine, @mos_eisley = Place.create([{:name => "Tatooine"}, {:name => 'Mos Eisley'}])
    end

    it 'should recognize a class as paranoid' do
      Person.paranoid?.should be_false
      Place.paranoid?.should be_true
    end

    it 'should hide destroyed records' do
      @tatooine.update_attribute('deleted_at', Time.now)
      Place.first(:conditions => {:name => 'Tatooine'}).should be_nil
    end

    it 'should reveal destroyed records when with_destroyed' do
      @tatooine.update_attribute('deleted_at', Time.now)
      Place.with_destroyed.first(:conditions => {:name => 'Tatooine'}).should_not be_nil
    end

    it 'should restore the destroyed record' do
      @tatooine.update_attribute('deleted_at', Time.now)

      @tatooine = Place.with_destroyed.first(:conditions => {:name => 'Tatooine'})
      @tatooine.restore

      Place.first(:conditions => {:name => 'Tatooine'}).should_not be_nil
    end

    it 'should soft delete paranoid records' do
      @tatooine.destroy

      record = Place.with_destroyed.first(:conditions => {:name => 'Tatooine'})
      record.should_not be_nil
      record.deleted_at.should_not be_nil
    end

    it 'should mark the record destroyed' do
      @tatooine.destroy
      @tatooine.destroyed?.should be_true
    end

    it 'should set the deleted_field' do
      @tatooine.destroy
      @tatooine.deleted_at.should_not be_nil
    end

    it 'should show deleted_only' do
      @tatooine.destroy
      destroyed = Place.with_destroyed_only.all
      destroyed.size.should == 1
      destroyed[0].should == @tatooine
    end
  end

  describe 'for alternate field information' do
    before(:each) do
      Ninja.delete_all
      @steve, @bob = Ninja.create([{:name => 'Steve', :visible => true}, {:name => 'Bob', :visible => true}])
    end

    it 'should have 2 visible ninjas' do
      Ninja.all.size.should == 2
    end

    it 'should vanish the ninja' do
      @steve.destroy

      record = Ninja.first(:conditions => {:name => 'Steve'})
      record.should be_nil
    end

    it 'should not delete the ninja' do
      @steve.destroy

      record = Ninja.with_destroyed.first(:conditions => {:name => 'Steve'})
      record.should_not be_nil
      record.visible.should be_false
    end

    it 'should mark the ninja vanished' do
      @steve.destroy
      @steve.destroyed?.should be_true
    end

    it 'should set visible to false' do
      @steve.destroy
      @steve.visible.should be_false
    end

    it 'should show deleted_only' do
      @steve.destroy
      destroyed = Ninja.with_destroyed_only.all
      destroyed.size.should == 1
      destroyed[0].should == @steve
    end
  end
end
