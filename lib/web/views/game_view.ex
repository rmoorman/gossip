defmodule Web.GameView do
  use Web, :view

  alias Gossip.UserAgents
  alias Web.ConnectionView
  alias Web.ReactView
  alias Web.RedirectURIView

  def render("index.json", %{games: games}) do
    %{
      collection: render_many(games, __MODULE__, "show.json"),
    }
  end

  def render("show.json", %{game: game}) do
    %{
      game: Map.take(game.game, [:name, :homepage_url]),
      players: game.players,
    }
  end

  def render("status.json", %{game: game}) do
    json = %{game: game.short_name, display_name: game.name}

    json
    |> maybe_add(:description, game.description)
    |> maybe_add(:homepage_url, game.homepage_url)
    |> maybe_add(:user_agent, game.user_agent)
    |> maybe_add(:user_agent_url, user_agent_repo_url(game.user_agent))
    |> maybe_add_connections(game)
  end

  def render("sync.json", %{game: game}) do
    %{
      id: game.id,
      game: game.short_name,
      display_name: game.name,
      display: game.display,
      description: game.description,
      homepage_url: game.homepage_url,
      user_agent: game.user_agent,
      user_agent_url: user_agent_repo_url(game.user_agent),
      connections: format_connections(game.connections),
      redirect_uris: format_redirect_uris(game.redirect_uris),
      allow_character_registration: game.allow_character_registration,
      client_id: game.client_id,
      client_secret: game.client_secret,
    }
  end

  defp maybe_add_connections(json, game) do
    case game.connections do
      [] ->
        json

      connections ->
        Map.put(json, :connections, format_connections(connections))
    end
  end

  defp format_connections(connections) do
    connections
    |> Enum.map(fn connection ->
      ConnectionView.render("show.json", %{connection: connection})
    end)
  end

  defp format_redirect_uris(redirect_uris) do
    Enum.map(redirect_uris, &(&1.uri))
  end

  defp user_agent_repo_url(nil), do: nil

  defp user_agent_repo_url(user_agent) do
    with {:ok, user_agent} <- UserAgents.get_user_agent(user_agent),
         {:ok, user_agent} <- check_if_repo_url(user_agent) do
      user_agent.repo_url
    else
      _ ->
        nil
    end
  end

  defp maybe_add(json, _field, nil), do: json

  defp maybe_add(json, field, value) do
    Map.put(json, field, value)
  end

  def user_agent(game) do
    case game.user_agent do
      nil ->
        nil

      user_agent ->
        display_user_agent(user_agent)
    end
  end

  defp display_user_agent(user_agent) do
    with {:ok, user_agent} <- UserAgents.get_user_agent(user_agent),
         {:ok, user_agent} <- check_if_repo_url(user_agent) do
      link(user_agent.version, to: user_agent.repo_url, target: "_blank")
    else
      {:error, :no_repo_url, user_agent} ->
        user_agent.version

      _ ->
        nil
    end
  end

  defp check_if_repo_url(user_agent) do
    case user_agent.repo_url do
      nil ->
        {:error, :no_repo_url, user_agent}

      _ ->
        {:ok, user_agent}
    end
  end
end
