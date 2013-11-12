require 'spec_helper'

describe Calasmash::Cucumber do

  before(:each) do
    Calasmash::Cucumber.any_instance.stub(:puts)
  end

  describe "when running the tests" do

    before(:each) do
      wait = double
      @value = double
      wait.stub(:value){@value}
      wait.stub(:join)
      Open3.stub(:popen3).and_yield(nil, nil, nil, wait)

      @cucumber = Calasmash::Cucumber.new(nil, nil)
      @cucumber.stub(:command)
    end

    it "should exit if something goes bad" do
      @value.stub(:exitstatus){1}
      lambda { @cucumber.test }.should raise_error SystemExit
    end

    it "should complete if all is well" do
      @value.stub(:exitstatus){0}
      @cucumber.should_receive(:completed)
      @cucumber.test
    end
  end

  describe "when generating the command" do

    it "should add the ios version" do
      @cucumber = Calasmash::Cucumber.new("1.0", nil)
      @cucumber.stub(:tag_arguments)

      @cucumber.instance_eval{command}.should match(/OS=ios1 SDK_VERSION=1.0/)
    end

    it "should not add the ios version if missing" do
      @cucumber = Calasmash::Cucumber.new(nil, nil)
      @cucumber.stub(:tag_arguments)

      @cucumber.instance_eval{command}.should_not match(/OS/)
      @cucumber.instance_eval{command}.should_not match(/SDK_VERSION/)
    end

    it "should add the format" do
      @cucumber = Calasmash::Cucumber.new(nil, nil)
      @cucumber.format = "test-format"

      @cucumber.instance_eval{command}.should match(/--format test-format/)
    end

    it "should not add the format if missing" do
      @cucumber = Calasmash::Cucumber.new(nil, nil)

      @cucumber.instance_eval{command}.should_not match(/--format/)
    end

    it "should add the output" do
      @cucumber = Calasmash::Cucumber.new(nil, nil)
      @cucumber.output = "test-output"

      @cucumber.instance_eval{command}.should match(/--out test-output/)
    end

    it "should not add the output if missing" do
      @cucumber = Calasmash::Cucumber.new(nil, nil)

      @cucumber.instance_eval{command}.should_not match(/--out/)
    end

    it "should add the tags" do
      @cucumber = Calasmash::Cucumber.new(nil, ["tag1", "tag2"])
      @cucumber.instance_eval{command}.should match(/--tags tag1 --tags tag2/)
    end

    it "should not add tags if missing" do
      @cucumber = Calasmash::Cucumber.new(nil, nil)
      @cucumber.instance_eval{command}.should_not match(/--tags/)
    end
  end
end