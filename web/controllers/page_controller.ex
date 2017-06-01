defmodule Abba.PageController do
  use Abba.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
