defmodule Exconfig do
  @moduledoc """
  The module _Exconfig_ provides the API for the Exconfig-package.

  This is

    - `get/0` ... get all cached settings
    - `get/3` ... get a specific entry (read if not cached) [macro]
    - and `clear_cache!/0` ... remove all entries from the cache

  All usage of `Exconfig.get` will be captured and written to
  `configuration.log` at termination. `configuration.log` can be
  used as a template for creating your `setup.env` file.
  """

  require Logger
  require Exconfig.ConfigLogger

  alias Exconfig.Cache

  @doc """
  The macro records the usage of `get` with the `Exconfig.ConfigLogger` module
  and then reads the configuration as usual.
  """
  defmacro get(env, key, default \\ nil) do
    Exconfig.ConfigLogger.record_usage(env, key, default)

    quote do
      e = unquote(env)
      k = unquote(key)
      d = unquote(default)
      Exconfig._get(e, k, d)
    end
  end

  @doc """
  Get the entire loaded cache.

  ## Examples

      iex> Exconfig.get()
      %{}

  """
  def get do
    Cache.get()
  end

  @doc """
  Remove all entries from the cache, so they will be re-read if accessed
  again.
  """
  def clear_cache!() do
    Cache.clear!()
  end

  @doc """
  Get a value from cache or load it if not cached yet.

  ## Examples

  ### Return the default if key is not found anywhere

      iex> Exconfig.get(:exconfig, :unknown_config_key, :not_found)
      :not_found

  ### Return from a value configured in `config/*`

      iex> Exconfig.get(:logger, :level, :error)
      :debug

  ### Return a value provided as a system environment var

  The given key will be converted to a string, if it is an `:atom`.
  Also, it will be uppercased.

      iex> System.put_env("ELIXIRRULEZ", "true")
      iex> Exconfig.get(:exconfig, :elixirrulez, :not_found)
      "true"


  """
  def _get(application_key, key, default \\ nil) do
    lookup(application_key, key, default)
    |> load()
    |> loaded_or_default()
  end

  defp lookup(application_key, key, default) do
    case Cache.lookup(application_key, key, default) do
      {:error, :key_not_found} -> {:not_loaded, application_key, key, default}
      value -> {:cached, application_key, key, value}
    end
  end

  defp load({:cached, application_key, key, value}), do: {:cached, application_key, key, value}

  defp load({_state, _application_key, _key, _default} = args) do
    args
    |> load_application_env()
    |> load_system_env()
    |> update_cache()
  end

  defp update_cache({:not_loaded, _application_key, _key, _value} = args), do: args

  defp update_cache({:loaded, application_key, key, value}) do
    Cache.update(application_key, key, value)
    {:cached, application_key, key, value}
  end

  defp load_application_env({state, application_key, key, default}) do
    case Application.get_env(application_key, key) do
      nil -> {state, application_key, key, default}
      value -> {:loaded, application_key, key, value}
    end
  end

  defp load_system_env({state, application_key, key, default}) do
    case System.get_env(normalize_env_key(key)) do
      nil -> {state, application_key, key, default}
      value -> {:loaded, application_key, key, value}
    end
  end

  defp normalize_env_key(key) when is_atom(key), do: to_string(key) |> normalize_env_key()

  defp normalize_env_key(key) when is_binary(key) do
    key
    |> String.upcase()
  end

  defp loaded_or_default({_, _, _, value_or_default}), do: value_or_default
end
