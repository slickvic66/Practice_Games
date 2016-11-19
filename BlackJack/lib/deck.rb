# coding:UTF-8 vi:et:ts=2

module Blackjack

  class Deck
    attr_reader :cards

    def self.build_default_deck
      Card.suits.product(Card.values).map do |suit, value|
        Card.new(suit, value)
      end
    end

    def initialize(cards = Deck.build_default_deck)
      @cards = cards
    end

    def shuffle
      @cards.shuffle!
    end

    def take(n)
      @cards.pop(n)
    end

    def return(cards)
      @cards.unshift(*cards)
    end
  end
end