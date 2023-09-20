defmodule ElixirMobileTest do
  @moduledoc """
  ElixirMobileTest keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Hex.Application

  use Application

  def config_dir() do
    Path.join([Desktop.OS.home(), ".config", "elixir_mobile_test"])
  end

  @app Mix.Project.config()[:app]
  def start(:normal, []) do
    # configフォルダを掘る
    File.mkdir_p!(config_dir())

    # DBの場所を指定する
    Application.put_env(:elixir_mobile_test, ElixirMobileTest.Repo,
      database: Path.join([config_dir(), "/database.sq3"])
    )

    # session用のETSを起動
    :session = :ets.new(:session, [:named_table, :public, read_concurrency: true])

    # メインのSupervisorが管理する子プロセスを定義
    children = [
      ElixirMobileTest.Repo,
      {Phoenix.PubSub, name: ElixirMobileTest.PubSub},
      ElixirMobileTestWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: ElixirMobileTest.Supervisor]
    # メインのSupervisorを起動
    {:ok, sup} = Supervisor.start_link(children, opts)

    # DBの初期化を実行
    ElixirMobileTest.Repo.initialize()

    # Phoenixサーバが起動中のポート番号を取得
    port = :ranch.get_port(ElixirMobileTestWeb.HTTP)
    # メインのSupervisorの配下にElixirDesktopのsupevisorを追加
    {:ok, _} =
      Supervisor.start_child(sup, {
        Desktop.Window,
        [
          app: @app,
          id: ElixirMobileTestWindow,
          title: "ElixirMobileTest",
          url: "http://localhost:#{port}",
          size: {800, 600}
        ]
      })
  end

  def config_change(changed, _new, removed) do
    ElixirMobileTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
