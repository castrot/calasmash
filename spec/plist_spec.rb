require 'spec_helper'

describe Calasmash::Plist do

  describe "when executed" do

    before(:each) do
      @plist = Calasmash::Plist.new("scheme")
      @plist.stub(:update)
      @plist.stub(:clear)
      @plist.stub(:completed)
      @plist.stub(:started)
    end

    it "should update" do
      @plist.should_receive(:update)
      @plist.execute
    end

    it "should clear" do
      @plist.should_receive(:clear)
      @plist.execute
    end
  end

  describe "when clearing" do

    before(:each) do
      @plist = Calasmash::Plist.new("scheme")
      @plist.stub(:update)
      @plist.stub(:completed)
      @plist.stub(:started)
    end

    it "should delete the simulator plist" do
      @plist.stub(:simulator_plist_path){"plist_path"}
      FileUtils.should_receive(:rm).with("plist_path", anything)
      @plist.execute
    end
  end

  describe "when updating" do

    before(:each) do
      @cfplist = double(CFPropertyList::List)
      @cfplist.stub(:value)
      @cfplist.stub(:value=)
      @cfplist.stub(:save)
      CFPropertyList::List.stub(:new){@cfplist}
      CFPropertyList.stub(:native_types){@cfplist}
      CFPropertyList.stub(:guess)

      @plist = Calasmash::Plist.new("scheme")
      @plist.stub(:clear)
      @plist.stub(:completed)
      @plist.stub(:started)
      @plist.stub(:app_path){"app_path"}
    end

    it "should set the server ip and port" do
      @plist.stub(:server_ip){"server_ip"}
      stub_const("Calasmash::PORT", 123)

      @cfplist.should_receive(:[]=).with("url_preference", "server_ip")
      @cfplist.should_receive(:[]=).with("port_preference", 123)

      @plist.execute
    end

    it "should write the app server plist" do
      @cfplist.should_receive(:save).with("app_path/server_config.plist", anything)
      @cfplist.stub(:[]=)

      @plist.execute
    end

  end
end