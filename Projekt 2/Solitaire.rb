# File: Solitaire.rb
# Author: Andreas Saméus
# Date: 2024-02-16
# Description: A game of solitaire


#sets up the screen and its different traits
require 'ruby2d'
set title: 'Solitaire Game'
set background: 'green'
set width: 1070
set height: 600

# Class for creating card objects
# Attributes:
# rank: the rank of a card
# suit: the suit of a card
# color: the color of the card
# flipped: boolean for if a card is flipped or not
class Card
  attr_accessor :rank, :suit, :color, :flipped


  @@symbols_rank = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
  @@symbols_suit = ["clubs", "diamonds", "hearts", "spades"]

  def initialize(the_rank, the_suit, flipped = false)
    @rank = the_rank
    @suit = the_suit
    @flipped = flipped

    if @@symbols_suit[@suit] == "clubs" || @@symbols_suit[@suit] == "spades"
      @color = "Black"
    else
      @color = "Red"
    end
    
  end

  #method for changing the boolean of the :flipped attribute
  def flip
      @flipped = !@flipped
  end


  #method for getting the image path of a card
  #no parameters
  #returns: "cards/card_back.png" or "cards/#{@@symbols_suit[@suit]}#{@@symbols_rank[@rank]}.png"
  def image_path
    if @flipped
      return "cards/card_back.png"
    else
      return "cards/#{@@symbols_suit[@suit]}#{@@symbols_rank[@rank]}.png"
    end
  end

  #method for determing if a card in one rank below another
  #parameters:
  #other_card
  def rank_one_below(other_card)
      return self.rank == other_card.rank + 1
  end

end


#initializes global variables
$deck = []
$draw = []
$columns = [$col1 = [],
            $col2 = [],
            $col3 = [],
            $col4 = [],
            $col5 = [],
            $col6 = [],
            $col7 = []]
$foundations = [$f1 = [],
                $f2 = [],
                $f3 = [],
                $f4 = []]
$click_count = 0
$source_deck = nil
$index = 0


# Creates the cards and puts it into their stack
# No Parameters
# No Returns

def initialize_board

  #creates 52 cards with a rank between 0-12 and suit between 0-3 for easier use
  for rank in 0..12
    for suit in 0..3
      $deck << Card.new(rank, suit)
    end
  end


  $deck = $deck.shuffle #shuffels the deck

  #puts the cards in 7 columns with 1 - 7 cards
  for col in 0..6
    for i in 0..col
      if i == col
          $columns[col] << $deck.pop
      else
          #flips the card if it isnt the last card in a column
          col_card = $deck.pop
          col_card.flip
          $columns[col] << col_card
      end
    end
  end

  #flips all the cards in the deck
  for card in $deck
    card.flip
  end

end

# moves a card from a stack to a foundation
# Parameters:
# source_deck: the array the player wants to move a card from
# destination_deck: the array the last card in the source deck goes to
# No Returns


def move_cards_foundation(source_deck, destination_deck)


  card_to_move = source_deck.last
  if !valid_destination_foundation(card_to_move, destination_deck) #if the move isnt vaild return
    return
  end
  
  destination_deck << source_deck.pop #appends the card to move and pops it from  the source_deck

  #flips the card if the source_deck isnt empty and if the new bottom card is flipped
  if !source_deck.empty? && source_deck.last.flipped
    source_deck.last.flip 
  end

end

# Checks the logic for moving a card to a foundation
# Parameters:
# card_to_move: the card the player tries to move
# destination_deck: The foundation array
# Returns: True or False

def valid_destination_foundation(card_to_move, destination_deck)
  dc = destination_deck.last

  #if the dc is nil then the only valid move is an ace with the rank of 0
  if dc.nil?
    if card_to_move.rank == 0
      return true
    else
      return false
    end
  else 
    #else the valid move would be if the suit is the same and the card to move is one above the dc
    if card_to_move.suit == dc.suit && card_to_move.rank_one_below(dc)
      return true
    else
      return false
    end
  end


end

# moves a card from a stack to a column on the board
# Parameters:
# source_deck: the array the player wants to move a card from
# destination_deck: the array the cards will be moved to
# num_cards: The amount of cards that the player wants to move from the source deck
# No Returns

def move_cards(source_deck, destination_deck, num_cards)
  if num_cards <= 0
    return
  end
  
  cards_to_move = source_deck.last(num_cards) #creates an array with the cards that will move
  if !valid_destination(cards_to_move, destination_deck)
    return
  end

  #concats the cards to move and pops them from the source_deck
  destination_deck.concat(cards_to_move)
  source_deck.pop(num_cards)

  #flips the card if the source_deck isnt empty and if the new bottom card is flipped
  if !source_deck.empty? && source_deck.last.flipped
    source_deck.last.flip 
  end
end

# Checks the logic for moving a card to a column
# Parameters:
# cards_to_move: Array with the cards the player wants to move
# destination_deck: The column array
# Returns: True or False

def valid_destination(cards_to_move, destination_deck)
  if cards_to_move.empty?
    return false #to prevent crashes
  end
  if destination_deck == nil
    return false #to prevent crashes
  end
  dc = destination_deck.last

  first_card = cards_to_move.first #only the first card in cards_to_move matters for if a move is possilbe
  if first_card.flipped
    return false #if the card is flipped the move isnt possible
  end

  if dc == nil
    #if the dc is nil then only a king can be moved there
    if first_card.rank == 12
      return true
    else
      return false
    end
  end

  if first_card.color != dc.color && dc.rank_one_below(first_card)
    return true #if the statement above is true then a move can be made 
  end

  return false
end

# Puts cards for the deck to the draw array and 
# fills the deck and empties the draw array if the deck is empty
# No Parameters
# No Returns

def draw_card_from_deck
  if $deck.empty?
    #if the deck is empty fills it from the draw pile and resets draw pile
    for card in $draw
      card.flip 
      $deck << card
    end
    $draw = []
  else 
    #take a card from the deck and puts it in the draw pile
    card = $deck.shift
    card.flip
    $draw << card
  end
end

# draws up the entire board
# No Parameters
# No Returns

def update_board
  
  clear #clears the board

  # Update and draw columns when a move is made
  x = 120
  y = 60
  for column in $columns
   for card_index in 0...column.length
     card = column[card_index]
       Image.new(card.image_path, x: x, y: y, width: 80, height: 120)
       y += 30
    end
    x += 120
    y = 60
  end

  # Update and draw deck and draw pile when a move is made
  x = 10
  for card in $deck
    Image.new(card.image_path, x: x, y: y, width: 80, height: 120)
    y +=1
  end
  if !$draw.empty?
    Image.new($draw.last.image_path, x: x, y: 230, width: 80, height: 120)
  end

  # Update and draw the foundation when a move is made
  y = 60
  x = 950
  for foundation in $foundations
    if foundation.empty?
      Rectangle.new(x: x, y: y, width: 80, height: 120, color: "#006400")
    else
      Image.new(foundation.last.image_path,x: x, y: y, width: 80, height: 120,)
    end
    y += 130
  end


end

# Handles the player input
# Parameters:
# event: The info on the player input
# No Returns

def handle_click(event)
  # Increment the click count
  $click_count += 1

  if $click_count == 1
  
    # Determine source deck based on the click position
    if event.x.between?(120, 200)
      $source_deck = $col1
    elsif event.x.between?(240, 320)
      $source_deck = $col2
    elsif event.x.between?(360, 440)
      $source_deck = $col3
    elsif event.x.between?(480, 560)
      $source_deck = $col4
    elsif event.x.between?(600, 680)
      $source_deck = $col5
    elsif event.x.between?(720, 800)
      $source_deck = $col6
    elsif event.x.between?(840, 920)
      $source_deck = $col7
    end

    $index = (((event.y) - 60.0)/30.0).ceil  #determine index based on click

    #if the user clicks on the drawdeck
    if event.x.between?(10, 90) && event.y.between?(60, 204)
      draw_card_from_deck
      update_board
      $click_count = 0
    end

    #if user wants to move card from drawdeck
    if event.x.between?(10, 90) && event.y.between?(230, 350)
      $source_deck = $draw
    end

    #if the user wants to move card from foundation
    if event.x.between?(950,1030) && event.y.between?(60,180)
      $source_deck = $f1
    elsif event.x.between?(950,1030) && event.y.between?(190,310)
      $source_deck = $f2
    elsif event.x.between?(950,1030) && event.y.between?(320,440)
      $source_deck = $f3
    elsif event.x.between?(950,1030) && event.y.between?(450,570)
      $source_deck = $f4
    end

  elsif $click_count == 2
    # Determine destination deck based on the click position
    if event.x.between?(120, 200)
      destination_deck = $col1
    elsif event.x.between?(240, 320)
      destination_deck = $col2
    elsif event.x.between?(360, 440)
      destination_deck = $col3
    elsif event.x.between?(480, 560)
      destination_deck = $col4
    elsif event.x.between?(600, 680)
      destination_deck = $col5
    elsif event.x.between?(720, 800)
      destination_deck = $col6
    elsif event.x.between?(840, 920)
      destination_deck = $col7
    end


    #determine if the user clicks on a foundation
    if event.x.between?(950,1030) && event.y.between?(60,180)
      foundation_destination_deck = $f1
    elsif event.x.between?(950,1030) && event.y.between?(190,310)
      foundation_destination_deck = $f2
    elsif event.x.between?(950,1030) && event.y.between?(320,440)
      foundation_destination_deck = $f3
    elsif event.x.between?(950,1030) && event.y.between?(450,570)
      foundation_destination_deck = $f4
    end
  end

  if $click_count == 2


    if $source_deck == nil
      $click_count = 0  #resets the #click count to prevent error with a nil source_deck
    elsif foundation_destination_deck
      move_cards_foundation($source_deck, foundation_destination_deck) #move card to the foundation if the foundation_destination_deck isnt nil
    elsif$source_deck == $draw || $source_deck == $f1 || $source_deck == $f2 || $source_deck == $f3 || $source_deck == $f4
      move_cards($source_deck, destination_deck, 1) #moves 1 card if the move is from the foundation or draw
    else
      cards_to_move = $source_deck.length - $index + 1 #calculates how many cards the user wants to move
      if cards_to_move <= 0 && cards_to_move >= -2 #if between these indexes the user has pressed a card
        cards_to_move = 1 #sets the cards_to_move to 1 to make the move possible
      end

      move_cards($source_deck, destination_deck, cards_to_move) #make a move on the board
    end
    if $f1.length == 13 && $f2.length == 13 &&  $f3.length == 13 &&  $f4.length == 13 
      puts "Congratulations You Win" #if the foundations are filled the game is complete
      exit #shuts down the window
    end
    update_board # updates the board when a move is made

    #resets global variabels
    $click_count = 0
    $index = nil
  end



end

# Main function that shows the window and uses previous functions
# No Parameters
# No Returns

def main
  #sets up the board and draws it for the first time
  initialize_board
  update_board

  #when a click is made calls upon the handle_click function
  on :mouse_down do |event|
    handle_click(event)
  end

  #starts the window
  show
end


main #runs the main function and entire game