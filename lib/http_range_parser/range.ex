defmodule HTTPRange.Range do
  @type t :: %__MODULE__{first: integer, last: integer | nil}

  @enforce_keys [:first]
  defstruct [:first, last: nil]
end

defmodule HTTPRange.RangeSpec do
  alias HTTPRange.Range

  @type t :: %__MODULE__{unit: binary, ranges: MapSet.t(binary)}
  @type range :: Range.t()

  @enforce_keys [:unit]
  defstruct [:unit, ranges: MapSet.new()]

  @spec add_range(t, range) :: t
  def add_range(%__MODULE__{ranges: ranges} = spec, %Range{} = range) do
    %{spec | ranges: MapSet.put(ranges, range)}
  end
end
