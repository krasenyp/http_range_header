defmodule HTTPRange do
  alias __MODULE__.{Parser, ParseError, RangeSpec}

  @spec parse(binary) :: {:ok, RangeSpec.t()} | {:error, ParseError.t()}
  def parse(input) do
    Parser.parse(input)
  end

  @spec parse!(binary) :: RangeSpec.t() | no_return
  def parse!(input) do
    case parse(input) do
      {:ok, range} -> range
      {:error, error} -> raise error
    end
  end
end
