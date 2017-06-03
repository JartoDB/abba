defmodule Abba.Aws.S3.Bucket.Server do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: :amazon_bucket_server)
  end

  def init(:ok) do
    bucket_name = System.get_env("AWS_S3_BUCKET_NAME")

    {:ok, %{bucket_name: bucket_name}}
  end

  def list_objects() do
    GenServer.call(:amazon_bucket_server, :list_objects)
  end

  def handle_call(:list_objects, _from, %{bucket_name: bucket_name} = state) do
    urls = fetch_objects(bucket_name)
            |> extract_contents(bucket_name)

    {:reply, urls, state}
  end

  defp fetch_objects(bucket_name) do
    bucket_name
      |> ExAws.S3.list_objects()
      |> ExAws.request()
  end

  defp extract_contents({:ok, %{body: %{contents: contents }}}, bucket_name) do
    Enum.map(contents, fn(object) ->
      %{
        url: "https://s3.amazonaws.com/#{bucket_name}/#{object.key}"
      }
    end)
  end
end
