defmodule Exconfig.ConfigLogger do
  @moduledoc ~s"""
  This module starts a GenServer at the first use of `Exconfig.get/3` and adds
  each usage of `Exconfig.get/3` to the state of the server. At termination,
  all captured entries will be written to the configured logfile.
  """
  require Logger
  use GenServer

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.info(
      "Config cache started. All usage of `Exconfig.get` will be written to '#{state.filename}'"
    )

    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  @doc ~s"""
  Add a new entry to the state of `#{__MODULE__}`.
  """
  def record_usage(env, key, default) do
    case GenServer.whereis(__MODULE__) do
      nil ->
        start_config_logger()
        record_usage(env, key, default)

      pid ->
        GenServer.cast(pid, {:add, env, key, default})
    end
  end

  @impl true
  def handle_cast({:add, env, key, default}, state) do
    Logger.debug("record usage of #{env}, #{key}, #{default} to file #{state.filename}")
    existing = state[:entries] || []
    new_state = Map.merge(state, %{entries: [{env, key, default} | existing]})
    {:noreply, new_state}
  end

  @doc ~s"""
  Write the configuration log to disk before terminating.
  """
  @impl true
  def terminate(reason, state) do
    Logger.info(
      "Terminating Config cache. Reason: #{inspect(reason)}, Write Exconfig usage to #{
        state.filename
      }"
    )

    save_state(state)
    :timer.sleep(1000)
    {:stop, state}
  end

  defp save_state(state) do
    formatted =
      state.entries
      |> Enum.map(fn entry -> format_entry(entry) end)
      |> Enum.join("\n")

    File.open(state.filename, [:append])
    |> elem(1)
    |> IO.binwrite(formatted <> "\n")
  end

  defp format_entry({:env, key, default}) when is_atom(key) do
    key = Atom.to_string(key) |> String.upcase()
    format_entry({:env, key, default})
  end

  defp format_entry({:env, key, nil}) when is_binary(key),
    do: "#{key}" <> "=\"DEFAULTS TO NIL\""

  defp format_entry({:env, key, default}) when is_binary(key) and is_number(default) do
    format_entry({:env, key, "#{default}"})
  end

  defp format_entry({:env, key, default}) when is_binary(key),
    do: "#{key}" <> "=" <> inspect(default)

  defp format_entry({env, key, value}),
    do: "# Configured in #{inspect(env)}, #{inspect(key)}, #{inspect(value)}"

  defp start_config_logger() do
    filename = Application.get_env(:exconfig, :config_log_file, "configuration.log")
    __MODULE__.start_link(%{filename: filename})
  end
end
