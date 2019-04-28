defmodule Exconfig.Cache do
  @moduledoc """
  PRIVATE MODULE -- Do not use this
  module directely but through `Exconfig` API only.

  The module implements a `GenServer` handling the state of the cache.   
  """
  use GenServer

  @doc """
  Start link function used from `Exconfig.Application` to
  start a single instance of this Cache-Server as a supervised
  worker.
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(state), do: {:ok, state}

  @doc """
  Get the entire current cache as a `Map`.

  ### Example

      iex> Exconfig.clear_cache!()
      iex> Exconfig.Cache.get()
      %{}

      iex> Exconfig.clear_cache!()
      iex> Exconfig.get(:logger, :level )
      iex> Exconfig.Cache.get()
      %{{:logger, :level} => :debug}
  """
  def get(), do: GenServer.call(__MODULE__, :get)

  @doc """
  Clear the current cache.

  ### Example

      iex> Exconfig.Cache.clear!()
      iex> Exconfig.get()
      %{}

  """
  def clear!(), do: GenServer.cast(__MODULE__, :clear!)

  @doc """
  Update the given `key` in the cache with a new `value`.
  Also inserts a new key/value if it not exists yet.

  ### Example

      iex> Exconfig.Cache.clear!()
      iex> Exconfig.get(:logger,:level)
      iex> Exconfig.Cache.update(:logger,:level,:new_level)
      iex> Exconfig.get()
      %{{:logger, :level} => :new_level}

  """
  def update(application_key, key, value) do
    GenServer.cast(__MODULE__, {:update, application_key, key, value})
  end

  @doc """
  Find a given key or return `{:error, :key_not_found}`
  """
  def lookup(application_key, key, _default) do
    case GenServer.call(__MODULE__, {:lookup, application_key, key}) do
      nil -> {:error, :key_not_found}
      value -> value
    end
  end

  #
  # GenServer Callbacks
  #
  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, state}

  @impl true
  def handle_call({:lookup, application_key, key}, _from, state) do
    found = Map.get(state, {application_key, key})
    {:reply, found, state}
  end

  @impl true
  def handle_cast(:clear!, _state), do: {:noreply, %{}}

  @impl true
  def handle_cast({:update, application_key, key, value}, state) do
    new_state = Map.merge(state, %{{application_key, key} => value})
    {:noreply, new_state}
  end
end
