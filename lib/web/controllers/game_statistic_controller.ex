defmodule Web.GameStatisticController do
  use Web, :controller

  alias Gossip.Games
  alias Gossip.Statistics

  @grapevine_url Application.get_env(:gossip, :grapevine)[:cors_host]

  def players(conn, %{"game_id" => short_name}) do
    case Games.get_by_short(short_name) do
      {:ok, game} ->
        conn
        |> assign(:statistics, Statistics.last_few_days(game))
        |> put_resp_header("access-control-allow-origin", @grapevine_url)
        |> render("players.json")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Could not find that game.")
        |> redirect(to: page_path(conn, :index))
    end
  end
end
