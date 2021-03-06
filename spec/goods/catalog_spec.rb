require 'spec_helper'

describe Goods::Catalog do
  describe "#initialize" do
    it "should call #from_string when string is passed" do
      expect_any_instance_of(Goods::Catalog).to receive(:from_string).
        with("string", "url", "UTF-8").once
      Goods::Catalog.new(string: "string", url: "url", encoding: "UTF-8")
    end

    it "should raise error when none of 'string', 'url', 'file' params is passed" do
      expect{ Goods::Catalog.new({}) }.to raise_error(ArgumentError)
    end
  end

  describe "#from_string" do
    class NullObject
      def method_missing(name, *args)
        self
      end
    end

    [Goods::XML, Goods::CategoriesList, Goods::CurrenciesList, Goods::OffersList].each do |part|
    it "should create #{part}" do
        expect(part).to receive(:new).and_return(NullObject.new).once
        Goods::Catalog.new(string: "xml")
      end
    end
  end

  describe "#prune" do
    let(:xml) {
      File.read(File.expand_path("../../fixtures/simple_catalog.xml", __FILE__))
    }
    let(:catalog) { Goods::Catalog.new string: xml}

    it "should prune offers and categories" do
      level = 2
      expect(catalog.offers).to receive(:prune_categories).with(level)
      expect(catalog.categories).to receive(:prune).with(level)
      catalog.prune(level)
    end

    it "should replace categories of offers" do
      catalog.prune(0)
      expect(catalog.offers.find("123").category).to be(
        catalog.categories.find("1")
      )
    end

    it "should remove categories affected by prunning" do
      catalog.prune(0)
      expect(catalog.categories.size).to eql(3)
    end
  end
end
