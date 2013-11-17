require 'spec_helper'

describe Calasmash::Setup do

  describe "when executing" do

    it "should add the server plist to xcode" do
      Calasmash::Setup.should_receive(:add_plist)
      Calasmash::Setup.execute
    end
  end

  describe "when getting the xcode project" do

    before(:each) do
      Dir.stub(:[]){["xcode-project"]}
    end

    it "should get the xcodeproj from the current directory" do
      Calasmash::Setup.instance_eval{xcodeproj}.should match(/xcode-project/)
    end
  end

end