require "rspec"
require "blackjack"

include Blackjack

describe Card do
  subject(:card) { Card.new(:hearts, :ten) }

  context "Card" do
    it "has a suit" do
      card.suit.should eq(:hearts)
    end

    it "has a value" do
      card.value.should eq(:ten)
    end
  end
end