defmodule HTTPRange.ParseError do
  @type t :: %__MODULE__{part: atom, subject: binary | nil, value: binary}

  defexception [:part, :subject, :value]

  def message(%{part: :ranges, subject: nil, value: value}) do
    "expected a range set to be defined in #{inspect(value)}"
  end

  def message(%{part: :ranges, subject: subject, value: value}) do
    "invalid range specification #{inspect(subject)} in #{inspect(value)}"
  end

  def message(%{part: :unit, subject: nil, value: value}) do
    "expected a unit to be defined in #{inspect(value)}"
  end

  def message(%{value: value}) do
    "invalid header value #{inspect(value)}"
  end
end

defmodule HTTPRange.Parser do
  alias HTTPRange.{ParseError, RangeSpec, Range}

  @type range :: Range.t()

  @spec parse(binary) :: {:ok, RangeSpec.t()} | {:error, ParseError.t()}
  def parse(input) when is_binary(input) do
    case String.split(input, "=") do
      [_, ""] ->
        {:error, %ParseError{part: :ranges, subject: nil, value: input}}

      ["", _] ->
        {:error, %ParseError{part: :unit, subject: nil, value: input}}

      [unit, ranges] ->
        ranges
        |> String.split(",")
        |> parse_ranges(%RangeSpec{unit: unit})
        |> case do
          {:ok, range} ->
            {:ok, range}

          {:error, range} ->
            {:error, %ParseError{part: :ranges, subject: range, value: input}}
        end
    end
  end

  @spec parse_ranges([binary], RangeSpec.t()) :: {:ok, RangeSpec.t()} | {:error, binary}
  defp parse_ranges([], %RangeSpec{} = header), do: {:ok, header}

  defp parse_ranges([h | t], %RangeSpec{} = spec) do
    with {:ok, range} <- parse_range(h) do
      parse_ranges(t, RangeSpec.add_range(spec, range))
    end
  end

  @spec parse_range(binary) :: {:ok, range} | {:error, binary}
  defp parse_range(candidate) do
    case String.split(candidate, "-") do
      ["", length] ->
        case parse_fragment(length) do
          {:ok, parsed} -> {:ok, %Range{first: -parsed}}
          :error -> {:error, candidate}
        end

      [first, ""] ->
        case parse_fragment(first) do
          {:ok, parsed} -> {:ok, %Range{first: parsed}}
          :error -> {:error, candidate}
        end

      [first, last] ->
        with {:ok, parseda} <- parse_fragment(first),
             {:ok, parsedb} <- parse_fragment(last) do
          {:ok, %Range{first: parseda, last: parsedb}}
        else
          :error -> {:error, candidate}
        end

      _ ->
        # Returning just the argument because it's not enough to construct a
        # ParseError struct, the header value is needed.
        {:error, candidate}
    end
  end

  @spec parse_fragment(binary) :: {:ok, integer} | :error
  defp parse_fragment(candidate) do
    case Integer.parse(candidate) do
      {parsed, ""} -> {:ok, parsed}
      _ -> :error
    end
  end
end
