defmodule Hangman.Game do

  defstruct turns_left: 7, game_state: :initializing,
    letters: [],
    used: MapSet.new()


  def new_game() do
    %Hangman.Game{
      letters: Dictionary.random_word |> String.codepoints
    }
  end

  @spec new_game(binary) :: %Hangman.Game{
          game_state: :initializing,
          letters: [binary],
          turns_left: 7,
          used: MapSet.t()
        }
  def new_game(word) do
    %Hangman.Game{
      letters: word |> String.codepoints
    }
  end

  def make_move(game = %{game_state: state}, _guess) when state in [:won, :lost] do
    {game, tally(game)}
  end

  def make_move(game, guess) do
    game = accept_move(game, guess, MapSet.member?(game.used, guess))

    {game, tally(game)}
  end

  def accept_move(game, guess, _already_guessed = true) do
    game = Map.put(game, :game_state, :already_used)
  end

  def accept_move(game, guess, _already_guessed) do
    Map.put(game, :used, MapSet.put(game.used, guess))
      |> score_guess(Enum.member?(game.letters, guess))
  end


  def score_guess(game, _good_guess = true) do
    new_state = MapSet.new(game.letters)
                |> MapSet.subset?(game.used)
                |> maybe_won
    %{game | game_state: new_state}
  end

  def score_guess(game = %{turns_left: turns_left }, _not_good_guess) do
    %{ game |
       game_state: :bad_guess,
       turns_left: turns_left - 1
      }
   end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: game.letters |> reveal_guessed(game.used)
    }
  end

  def reveal_guessed(letters, used) do
    letters
      |> Enum.map(fn letter -> reveal_letter(letter, MapSet.member?(used, letter)) end)
  end

  def reveal_letter(letter, _in_word = true), do: letter
  def reveal_letter(letter, _not_in_word), do: "_"


  def maybe_won(true), do: :won
  def maybe_won(_), do: :good_guess
end
