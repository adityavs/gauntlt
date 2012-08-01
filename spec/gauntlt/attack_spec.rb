require 'spec_helper'

describe Gauntlt::Attack do
  before do
    File.stub(:exists?).with(:bar).and_return(true)
  end

  subject{
    Gauntlt::Attack.new(:foo, :attack_file => :bar)
  }

  describe :initialize do
    context "attack file exists for passed name" do
      it "sets name and opts" do
        subject.name.should == :foo
        subject.opts.should == {:attack_file => :bar}
      end
    end

    context "attack file does not exist for passed name" do
      it "raises an error if the attack file does not exist" do
        File.stub(:exists?).with(:bar).and_return(false)

        expect {
          Gauntlt::Attack.new(:foo, :attack_file => :bar)
        }.to raise_error Gauntlt::Attack::NotFound
      end
    end
  end

  describe :base_dir do
    it "returns the full path for the attack.rb file" do
      File.should_receive(:dirname).and_return(:foo)
      File.should_receive(:expand_path).with(:foo)

      subject.base_dir
    end
  end

  describe :attacks_dir do
    it "joins attacks to base_dir" do
      subject.should_receive(:base_dir).and_return(:bar)
      File.should_receive(:join).with(:bar, 'attack_adapters')

      subject.attacks_dir
    end
  end

  describe :run do
    it "executes the attack file, specifies failure for undefined steps and specifies the attacks_dir" do
      subject.should_receive(:attacks_dir).and_return('/bar')
      subject.should_receive(:attack_file).and_return('/bar/baz.attack')
      Cucumber::Cli::Main.should_receive(:execute).with(['/bar/baz.attack', '--strict', '--require', '/bar'])

      subject.run
    end
  end
end