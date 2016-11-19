# coding:UTF-8 vi:et:ts=2

module Blackjack

  CARD_SUITS = {
    :hearts => "♥",
    :spades => "♠",
    :clubs => "♣",
    :diamonds => "♦"
  }

  CARD_VALUES = {
    :two => "2",
    :three => "3",
    :four => "4",
    :five => "5",
    :six => "6",
    :seven => "7",
    :eight => "8",
    :nine => "9",
    :ten => "10",
    :jack => "J",
    :queen => "Q",
    :king => "K",
    :ace => "A",
  }

  class Card
    attr_reader :suit, :value

    def self.suits
      CARD_SUITS.keys
    end

    def self.values
      CARD_VALUES.keys
    end

    def initialize(suit, value)
      @suit, @value = suit, value
    end
  end

end