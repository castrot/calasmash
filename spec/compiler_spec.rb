require 'spec_helper'

describe Calasmash::Compiler do

  it "should have a scheme instance" do
    compiler = Calasmash::Compiler.new("scheme")
    compiler.scheme.should match("scheme")
  end

  describe "when generating the command" do

    before(:each) do
      Calasmash::Compiler.any_instance.stub(:workspace)
      @compiler = Calasmash::Compiler.new("test-scheme")
    end

    it "should contain the scheme" do
      @compiler.instance_eval{command}.should match(/test-scheme/)
    end
  end

  describe "when getting the workspacae" do

    before(:each) do
      @compiler = Calasmash::Compiler.new(nil)
      Dir.stub(:[]){["workspace-file"]}
    end

    it "should get the workspace from the current directory" do
      @compiler.instance_eval{workspace}.should match(/workspace-file/)
    end
  end
end