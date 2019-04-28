defmodule ExconfigTest do
  use ExUnit.Case
  doctest Exconfig
  doctest Exconfig.Cache

  setup _ do
    Exconfig.clear_cache!()
    System.put_env("ELIXIRRULES", "yes it do")
    :ok
  end

  describe "GET VALUES FROM EXCONFIG" do
    test "read from application config" do
      log_level = Exconfig.get(:logger, :level)
      assert :debug == log_level
    end

    test "read from system environment" do
      System.put_env("ELIXIRRULES", "yes it do")
      does_elixir_rules = Exconfig.get(:_env, :elixirrules)
      assert "yes it do" == does_elixir_rules
    end
  end

  describe "USING THE CACHE" do
    test "read value stores it in cache" do
      # Given an empty cache
      assert Exconfig.get() == %{}

      # When reading from the cache
      read_once = Exconfig.get(:exconfig, :elixirrules)
      assert "yes it do" == read_once

      # Then the key/value pair is cached
      assert Exconfig.get() == %{{:exconfig, :elixirrules} => "yes it do"}
    end

    test "cached values are not getting re-read" do
      # Given an empty cache
      assert Exconfig.get() == %{}

      # When reading from the cache
      read_once = Exconfig.get(:exconfig, :elixirrules)
      assert "yes it do" == read_once

      # And then changing the value
      System.put_env("ELIXIRRULES", "Ignored by cache")

      # Then we still read the old value from cache
      value = Exconfig.get(:exconfig, :elixirrules)
      assert "yes it do" == value
    end
  end
end
