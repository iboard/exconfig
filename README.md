# Exconfig

[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](http://hexdocs.pm/exconfig/)
[![Documentation](https://travis-ci.com/iboard/data_source.svg?branch=master)](https://travis-ci.com/iboard/exconfig)

- [At Github](https://github.com/iboard/exconfig)
- [Hex](https://hex.pm/packages/exconfig)

## Context

Don't use ENV-settings for compile-time configuration. (Because it is
hard to maintain your environment-settings for different deployments.

Imagine you want to build a Docker-image for your Phoenix-application
and you use something like

```elixir
   plug SomePlug, config_value: System.get_env("SOME_KEY")
```

`plug` is a macro and therefore, `SOME_KEY` gets evaluated at
compile time. If `SOME_KEY` is customer-related, this setting
get's burned into the image and may surprisingly pop up at the
wrong customer's server.

The `Exconfig`-package will help you not to make this mistake.
Just use `Exconfig.get` instead of all your `Application.get_env`
and `System.get_env` calls. Because the cache-server of `Exconfig`
will not run at compile-time you'll get a compile-error if you
try to use System-envs from your busines-logic.

## Usage

The application starts a GenServer and caches configuration at run time.

Loading configuration happens in two steps where each step overwrites
eventually existing values from previous steps.

  - Application.get_env(:app, :key) default
  - System.get_env(:key) default

Once the value is cached it will be returned from the GenServer state
rather than re-reading it from the environment again.

Using `Exconfig.clear_cache!/0` will drop the cache and values will be
loaded again if being accessed later.

### Example:

    iex> value = Exconfig.get(:my_app, :foo, "bar" )
    "bar"

    iex> value = Exconfig.get(:env, :some_secret )
    nil

`Exconfig.get/3` will first lookup for :myapp/:foo in the Exconfig.Cache 
(a GenServer) and if not found load from `Application`, `System`, or
returns the default. The second example will read from env-var SOME_SECRET.
Because no default value is given, it will return `nil`

## configuration.log

`Exconfig.get/3` is a macro. At compile-time in any environment but `:prod`,
it will capture it's usage in a file. The file can be configured in `config.ex`
and defaults to `configuration.log`.

The File can be used as a template for a shell-script.

## Installation

[Available in Hex](https://hex.pm/packages/exconfig). The package can be installed
by adding `Exconfig` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exconfig, "~> 0.2.0"}
  ]
end
```

Documentation can be generated with `mix docs` ([ExDoc](https://github.com/elixir-lang/ex_doc))
and is published at [https://hexdocs.pm/exconfig](https://hexdocs.pm/exconfig).

