require "rspec"
require "blackjack"

include Blackjack

describe Deck do
  subject(:deck) { Deck.new }

  context "Deck" do
    its("cards.count") { should eq(52) }

    it "should shuffle cards" do
      unshuffled = Deck.new
      deck.shuffle
      deck.cards.should_not eq(unshuffled.cards)
    end

    it "should allow cards to be taken off" do
      deck.take(2).count.should eq(2)
      deck.cards.count.should eq(50)
    end

    it "should allow cards to be returned" do
      cards = deck.take(2)
      deck.return(cards)

      deck.cards.count.should eq(52)
    end

    it "should return cards to the bottom" do
      cards = deck.take(2)
      deck.return(cards)

      deck.take(2).should_not eq(cards)
    end
  end
end