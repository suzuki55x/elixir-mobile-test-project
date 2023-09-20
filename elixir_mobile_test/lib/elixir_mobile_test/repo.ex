defmodule ElixirMobileTest.Repo do
  use Ecto.Repo,
    otp_app: :elixir_mobile_test,
    adapter: Ecto.Adapters.SQLite3

  def initialize() do
    # DBの初期化を実行
  end
end
