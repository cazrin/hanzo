defmodule Hanzo.Game.Player.Data do
  @moduledoc ~S"""
  Acts as a simple interface for handling game state data.

  Trying out using `:ets` here to recover data from crashes. Seems to be
  working well at the moment. Will want to make the interface for it better
  than it currently is though. For example, the ETS table is currently public
  (not great).
  """

  defstruct id: nil, channel: nil, answers: %{}, questions: [],
  current_question: 0, state: :start

  def new(id, channel, questions) do
    case :ets.lookup(:player_data, id) do
      [] ->
        data = %__MODULE__{id: id, channel: channel, questions: questions}
        :ets.insert(:player_data, {id, data})
        data
      [{^id, data}] ->
        data
    end
  end

  def put_answer(data, answer) do
    current_question = Enum.at(data.questions, data.current_question)
    answers = data.answers |> Map.put(current_question.id, answer)

    data = Map.put(data, :answers, answers)
    data = Map.put(data, :current_question, data.current_question + 1)

    :ets.insert(:player_data, {data.id, data})

    data
  end

  def put_state(data, state) do
    data = %{data | state: state}
    :ets.insert(:player_data, {data.id, data})
    data
  end
end
