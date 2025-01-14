defmodule Jsonpatch.Operation.Move do
  @moduledoc """
  Move operations change the position of values in map or struct.

  ## Examples

      iex> move = %Jsonpatch.Operation.Move{from: "/a/b", path: "/a/e"}
      iex> target = %{"a" => %{"b" => %{"c" => "Bob"}}, "d" => false}
      iex> Jsonpatch.Operation.apply_op(move, target)
      %{"a" => %{"e" => %{"c" => "Bob"}}, "d" => false}
  """

  alias Jsonpatch.Operation
  alias Jsonpatch.Operation.Copy
  alias Jsonpatch.Operation.Move
  alias Jsonpatch.Operation.Remove

  @enforce_keys [:from, :path]
  defstruct [:from, :path]
  @type t :: %__MODULE__{from: String.t(), path: String.t()}

  defimpl Operation do
    @spec apply_op(Move.t(), list() | map() | Jsonpatch.error(), keyword()) ::
            map()
    def apply_op(_, {:error, _, _} = error, _opts), do: error

    def apply_op(%Move{from: from, path: path}, target, opts) do
      copy_patch = %Copy{from: from, path: path}

      case Operation.apply_op(copy_patch, target, opts) do
        {:error, _, _} = error -> error
        updated_target -> Operation.apply_op(%Remove{path: from}, updated_target, opts)
      end
    end
  end
end
