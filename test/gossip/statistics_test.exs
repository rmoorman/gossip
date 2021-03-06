defmodule Gossip.StatisticsTest do
  use Gossip.DataCase

  alias Gossip.Statistics

  describe "record player count for a game" do
    test "successful" do
      game = create_game(create_user())

      {:ok, stats} = Statistics.record_players(game, ["Guard", "Bandit"], Timex.now())

      assert stats.player_count == 2
      assert stats.player_names == ["Guard", "Bandit"]
    end
  end

  describe "recent stats" do
    test "fetch the last few days of stats" do
      game = create_game(create_user())

      now = Timex.now()
      Enum.each(1..15, fn i ->
        now = Timex.shift(now, minutes: -15 * i)
        {:ok, _stats} = Statistics.record_players(game, ["Guard", "Bandit"], now)
      end)

      stats = Statistics.last_few_days(game)

      stats =
        stats
        |> Enum.take(-4)
        |> Enum.map(&elem(&1, 1))
        |> Enum.take(3)

      assert Enum.all?(stats, &(&1 > 0))
    end
  end
end
