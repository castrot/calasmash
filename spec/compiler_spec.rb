require 'spec_helper'

describe Calasmash::Compiler do

  before(:each) do
    Calasmash::Compiler.any_instance.stub(:puts)
  end

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

  describe "when compiling" do

    before(:each) do
      wait = double
      @value = double
      wait.stub(:value){@value}
      wait.stub(:join)
      Open3.stub(:popen3).and_yield(nil, nil, nil, wait)

      @compiler = Calasmash::Compiler.new(nil)
    end

    it "should exit if something goes bad" do
      @value.stub(:exitstatus){1}
      lambda { @compiler.compile }.should raise_error SystemExit
    end

    it "should complete if all is well" do
      @value.stub(:exitstatus){0}
      @compiler.compile do |complete|
        complete.should equal(true)
      end
    end
  end

end