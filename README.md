# Exconfig

[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](http://hexdocs.pm/exconfig/)
[![Documentation](https://travis-ci.com/iboard/data_source.svg?branch=master)](https://travis-ci.com/iboard/exconfig)

- [At Github](https://github.com/iboard/exconfig)
- [Hex](https://hex.pm/packages/exconfig)

The application starts a Genserver and caches configuration at runtime.

Loading configuration happens in two steps where each step overwrites
eventually existing values from previous steps.

  - Application.get_env(:app, :key) default
  - System.get_env(:key) default

Once the value is cached it will be returned from the GenServer's state
rather than re-reading it from the environment again.

Using `Exconfig.clear_cache!/0` will drop the cache and values will be
loaded again if being accessed later.

### Example:

    iex> value = Exconfig.get(:my_app, :foo, "bar" )
    "bar"

`Exconfig.get/3` will first lookup for :myapp/:foo in the Exconfig.Cache 
(a GenServer) and if not found load from `Application`, `System`, or
returns the default.

## Installation

[Available in Hex](https://hex.pm/packages/exconfig). The package can be installed
by adding `Exconfig` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exconfig, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with `mix docs` ([ExDoc](https://github.com/elixir-lang/ex_doc))
and is published at [https://hexdocs.pm/exconfig](https://hexdocs.pm/exconfig).

