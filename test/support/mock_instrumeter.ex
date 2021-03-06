defmodule PushEx.Test.MockInstrumenter do
  @behaviour PushEx.Behaviour.PushInstrumentation

  @state %{
    delivered: [],
    requested: [],
    api_processed: [],
    api_requested: []
  }

  alias PushEx.Instrumentation.Push.Context

  def setup_config(opts \\ []) do
    count = Keyword.get(opts, :count, 1)
    listeners = for i <- 0..count, i > 0, do: __MODULE__

    reset()
    Application.put_env(:push_ex, PushEx.Instrumentation, push_listeners: listeners)
  end

  def setup() do
    {:ok, _agent} = Agent.start_link(fn -> @state end, name: __MODULE__)
  end

  def reset() do
    Agent.update(__MODULE__, fn _state -> @state end)
  end

  def state() do
    Agent.get(__MODULE__, & &1)
  end

  def api_processed(%Context{}) do
    Agent.update(__MODULE__, fn state = %{api_processed: list} -> %{state | api_processed: [[:ctx] | list]} end)
  end

  def api_requested(%Context{}) do
    Agent.update(__MODULE__, fn state = %{api_requested: list} -> %{state | api_requested: [[:ctx] | list]} end)
  end

  def delivered(p = %PushEx.Push{}, %Context{}) do
    Agent.update(__MODULE__, fn state = %{delivered: list} -> %{state | delivered: [[p, :ctx] | list]} end)
  end

  def requested(p = %PushEx.Push{}, %Context{}) do
    Agent.update(__MODULE__, fn state = %{requested: list} -> %{state | requested: [[p, :ctx] | list]} end)
  end
end
