defmodule PushExWeb.PushChannel do
  use Phoenix.Channel

  intercept(["msg"])

  def broadcast({:msg, channel}, event, data = %{}, opts \\ []) when is_bitstring(event) do
    endpoint_mod = Keyword.get(opts, :endpoint, PushEx.Config.endpoint())
    endpoint_mod.broadcast!(channel, "msg", %{event: event, data: data})
    :ok
  end

  ## Socket API

  def join(channel, params, socket) do
    PushEx.Config.push_socket_join_fn().(channel, params, socket)
    |> case do
      response = {:ok, _socket} ->
        send(self(), :after_join)
        response

      response ->
        response
    end
  end

  def handle_out("msg", params = %{}, socket) do
    push(socket, "msg", params)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = PushExWeb.PushPresence.track(socket)
    {:noreply, socket}
  end
end
