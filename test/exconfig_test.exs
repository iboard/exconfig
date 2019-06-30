defmodule ExconfigTest do
  use ExUnit.Case
  doctest Exconfig
  doctest Exconfig.Cache
  require Exconfig

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

  test "Write to configuration log" do
    s1 = Exconfig.get(:env, :s1, "v1")
    s2 = Exconfig.get(:env, :s2, "v2")
    s3 = Exconfig.get(:env, "S3", 1)
    subject = File.read!("configuration.log")
    assert s1 == "v1"
    assert s2 == "v2"
    assert s3 == 1
    assert Regex.match?(~r/S1="v1"/, subject)
    assert Regex.match?(~r/S2="v2"/, subject)
    assert Regex.match?(~r/S3="1"/, subject)
  end
end
