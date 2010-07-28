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
      @tatooine, @mos_eisley, @coruscant = Place.create([{:name => "Tatooine"}, {:name => 'Mos Eisley'}, {:name => 'Coruscant'}])
    end

    it 'should recognize a class as paranoid' do
      Person.paranoid?.should be_false
      Place.paranoid?.should be_true
    end

    it 'should recognize an STI class as paranoid' do
      Biped.paranoid?.should be_true
    end

    it 'should hide destroyed records' do
      @tatooine.destroy
      Place.first(:conditions => {:name => 'Tatooine'}).should be_nil
    end

    it 'should reveal destroyed records when with_destroyed' do
      @tatooine.destroy
      Place.with_destroyed.first(:conditions => {:name => 'Tatooine'}).should_not be_nil
    end

    it 'should restore the destroyed record' do
      @tatooine.destroy

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

    it 'should properly count records' do
      Place.count.should == 3

      @tatooine.destroy
      Place.count.should == 2
      Place.with_destroyed.count.should == 3
      Place.with_destroyed_only.count.should == 1
    end
  end

  describe 'for alternate field information' do
    before(:each) do
      Pirate.delete_all
      @roberts, @jack, @hook = Pirate.create([{:name => 'Roberts'}, {:name => 'Jack'}, {:name => 'Hook'}])
    end

    it 'should have 3 alive pirates' do
      Pirate.all.size.should == 3
    end

    it 'should kill the pirate' do
      @roberts.destroy

      record = Pirate.first(:conditions => {:name => 'Roberts'})
      record.should be_nil
    end

    it 'should not remove the pirate record' do
      @roberts.destroy

      record = Pirate.with_destroyed.first(:conditions => {:name => 'Roberts'})
      record.should_not be_nil
      record.alive.should be_false
    end

    it 'should mark the pirate dead' do
      @roberts.destroy
      @roberts.destroyed?.should be_true
    end

    it 'should set alive to false' do
      @roberts.destroy
      @roberts.alive.should be_false
    end

    it 'should show deleted_only' do
      @roberts.destroy
      destroyed = Pirate.with_destroyed_only.all
      destroyed.size.should == 1
      destroyed[0].should == @roberts
    end

    it 'should properly count records' do
      Pirate.count.should == 3

      @roberts.destroy
      Pirate.count.should == 2
      Pirate.with_destroyed.count.should == 3
      Pirate.with_destroyed_only.count.should == 1
    end
  end

  describe 'for alternate field information with is_paranoid format field information' do
    before(:each) do
      Ninja.delete_all
      @steve, @bob, @tim = Ninja.create([{:name => 'Steve', :visible => true}, {:name => 'Bob', :visible => true}, {:name => 'Tim', :visible => true}])
    end

    it 'should have 3 visible ninjas' do
      Ninja.all.size.should == 3
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

    it 'should properly count records' do
      Ninja.count.should == 3

      @steve.destroy
      Ninja.count.should == 2
      Ninja.with_destroyed.count.should == 3
      Ninja.with_destroyed_only.count.should == 1
    end
  end

  describe 'has_many association' do
    before(:each) do
      Android.delete_all
      Dent.delete_all

      @r2d2 = Android.create(:name => 'R2D2')
      @dents = Dent.create([
        {:android => @r2d2, :description => 'Hit by debris'},
        {:android => @r2d2, :description => 'Dropped while loading into X-Wing'},
        {:android => @r2d2, :description => 'Blaster hit'}
      ])

      @dents[2].destroy
    end

    it 'should hide the soft deleted dent' do
      @r2d2.dents.to_a.should == @dents[0,2]
    end

    it 'should show all dents with_destroyed' do
      @r2d2.dents.with_destroyed.to_a.should == @dents
    end

    it 'should show only soft deleted with destroyed_only' do
      @r2d2.dents.with_destroyed_only.to_a.should == [@dents[2]]
    end

    it 'should show the correct counts' do
      @r2d2.dents.size.should == 2
      @r2d2.dents.with_destroyed.size.should == 3
      @r2d2.dents.with_destroyed_only.size.should == 1
    end

    it 'should load correctly through an eager load' do
      @r2d2 = Android.eager_load(:dents).first
      @r2d2.dents.loaded?.should be_true
      @r2d2.dents.size.should == 2
      @r2d2.dents.to_a.should == @dents[0,2]
    end

    it 'should load correctly through an include' do
      @r2d2 = Android.includes(:dents).first
      @r2d2.dents.loaded?.should be_true
      @r2d2.dents.size.should == 2
      @r2d2.dents.to_a.should == @dents[0,2]
    end

    it 'should work correctly for a include dependency' do
      @nil = Android.includes(:dents).where('dents.description' => 'Blaster hit').first
      @nil.should be_nil
    end
  end

  describe 'callbacks' do
    before(:each) do
      Pirate.delete_all
    end

    it 'should not destroy the record when before_destroy returns false' do
      pirate = UndestroyablePirate.create!(:name => 'Roberts')
      lambda { pirate.destroy }.should_not change(UndestroyablePirate, :count)
    end

    it 'should run after_destroy callbacks' do
      pirate = RandomPirate.create!(:name => 'Roberts')
      lambda { pirate.destroy }.should raise_error(/after_destroy works/)
    end

    it 'should rollback on after_destroy error' do
      pirate = RandomPirate.create!(:name => 'Roberts')
      lambda { pirate.destroy rescue nil }.should_not change(RandomPirate, :count)
    end
  end
end
