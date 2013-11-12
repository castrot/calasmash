require 'spec_helper'

describe Calasmash::Command do

  describe "when executing" do

    before(:each) do
      Calasmash::Command.stub(:compile)
      Calasmash::Command.stub(:parse){nil}
    end

    it "should output the overview if missing args" do
      Calasmash::Command.should_receive(:overview)
      Calasmash::Command.execute
    end
  end

  describe "when starting a compile" do

    before(:each) do
      @mock = double(Calasmash::Compiler)
      @mock.stub(:compile)
      Calasmash::Compiler.stub(:new){@mock}
    end

    it "should set the compilers scheme" do
      Calasmash::Compiler.should_receive(:new).with("scheme")
      Calasmash::Command.compile("scheme")
    end

    it "should start compiling" do
      @mock.should_receive(:compile)
      Calasmash::Command.compile("scheme")
    end
  end

  describe "when updating the plist" do

    before(:each ) do
      @mock = double(Calasmash::Plist)
      @mock.stub(:execute)
      Calasmash::Plist.stub(:new){@mock}
    end

    it "should set the plists scheme" do
      Calasmash::Plist.should_receive(:new).with("scheme")
      Calasmash::Command.update_plist("scheme")
    end

    it "should execute the plist update" do
      @mock.should_receive(:execute)
      Calasmash::Command.update_plist("scheme")
    end

    describe "when running the cucumber tests" do

      before(:each ) do
        @mock = double(Calasmash::Cucumber)
        @mock.stub(:test)
        Calasmash::Cucumber.stub(:new){@mock}
      end

      it "should set the cucumber ios version" do
        Calasmash::Cucumber.should_receive(:new).with("ios", anything)
        Calasmash::Command.run_tests("ios", "tags", nil)
      end

      it "should set the cucumber tags" do
        Calasmash::Cucumber.should_receive(:new).with(anything, "tags")
        Calasmash::Command.run_tests("ios", "tags", nil)
      end

      it "should set the format" do
        @cucumber = Calasmash::Cucumber.new
        Calasmash::Cucumber.stub(:new){@cucumber}

        @cucumber.should_receive(:format=)
        Calasmash::Command.run_tests(nil, nil, "format")
      end

      it "should start the tests" do
        @mock.should_receive(:test)
        Calasmash::Command.run_tests("ios", "tags")
      end

    end
  end
end