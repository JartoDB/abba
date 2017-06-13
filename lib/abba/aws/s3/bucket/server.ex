defmodule Abba.Aws.S3.Bucket.Server do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: :amazon_bucket_server)
  end

  def init(:ok) do
    bucket_name = System.get_env("AWS_S3_BUCKET_NAME")
    bucket_host = System.get_env("AWS_S3_BUCKET_REGION")

    {:ok, %{bucket_name: bucket_name, bucket_host: bucket_host}}
  end

  def list_objects() do
    GenServer.call(:amazon_bucket_server, :list_objects)
  end

  def handle_call(:list_objects, _from, %{bucket_name: bn, bucket_host: bh} = state) do
    urls = fetch_objects(bn, bh)
            |> extract_contents(bn)

    {:reply, urls, state}
  end

  defp fetch_objects(bucket_name, bucket_host) do
    bucket_name
      |> ExAws.S3.list_objects()
      |> ExAws.request(region: bucket_host)
  end

  defp extract_contents({:ok, %{body: %{contents: contents }}}, bucket_name) do
    Enum.map(contents, fn(object) ->
      %{
        url: "https://s3.amazonaws.com/#{bucket_name}/#{object.key}"
      }
    end)
  end
end
