defmodule Arrows do
  @moduledoc "./README.md" |> File.stream!() |> Enum.drop(1) |> Enum.join()

  defmacro __using__(_options) do
    quote do
      import Kernel, except: [|>: 2]

      import unquote(__MODULE__),
        only: [
          |>: 2,
          |||: 2,
          ~>: 2,
          <~>: 2,
          ok: 1,
          to_ok: 1,
          from_ok: 1
        ]
    end
  end

  import Kernel, except: [|>: 2]

  @doc """
  Enhanced pipe operator with support for ellipsis (`...`) placement.

  This is a more flexible drop-in replacement for the standard Elixir pipe operator (`|>`).

  ## Special Features

  * The ellipsis (`...`) will be replaced with the result of evaluating the left-hand side expression.
  * The right-hand side need not be a function; it can be any expression containing the ellipsis (`...`).
  * You may use the ellipsis multiple times, and the left-hand side will be calculated exactly once.
  * If no ellipsis is present, it behaves like the standard pipe operator (placing the value as the first argument).

  ## Examples

      # Standard first position pipe
      iex> 2 |> Integer.to_string()
      "2"
      
      # Using ellipsis for explicit placement
      iex> 2 |> Integer.to_string(...)
      "2"
      
      # Using ellipsis to place the piped value in a non-first position
      iex> 3 |> String.pad_leading("2", ..., "0")
      "002"
      
      # Using the ellipsis multiple times
      iex> 2 |> Kernel.==(..., ...)
      true
      
      # Nested expressions with ellipsis
      iex> 2 |> String.pad_leading(Integer.to_string(...), 3, "0")
      "002"

      # With expressions and transformations
      iex> 2 |> (... * 3)
      6
      
  """
  defmacro l |> r, do: pipe(:first, :normal, l, r)

  @doc """
  OK-pipe operator.

  Similar to the enhanced pipe (`|>`), but with additional error handling for the following patterns:

  - `{:ok, value}` - Extracts `value` and passes it to the right side
  - `{:error, _}` - Passes through unchanged (short-circuits the pipeline)
  - `:error` - Passes through unchanged (short-circuits the pipeline)
  - `nil` - Passes through unchanged (short-circuits the pipeline)
  - Any other value - Passes the value directly to the right side

  ## Examples

      iex> 2 ~> Integer.to_string()
      "2"
      
      iex> {:ok, 2} ~> Integer.to_string() |> String.pad_leading(3, "0")
      "002"
      
      iex> {:error, :reason} ~> Integer.to_string()
      {:error, :reason}
      
      # Note that the following would pass :error to `String.pad_leading` breaking our pipe: 
      # :error ~> Integer.to_string() |> String.pad_leading(2, "0")
      
      # Instead we want to do:
      iex> :error ~> Integer.to_string() ~> String.pad_leading(2, "0")
      :error
      
      iex> nil ~> Integer.to_string()
      nil
      
      iex> 2 ~> (... * 2)
      4
      
      # With a non-standard position using ellipsis
      iex> 2 ~> Kernel./(3, ...)
      1.5
  """
  defmacro l ~> r, do: pipe(:first, :ok, l, r)

  @doc """
  Nil-coalescing "or" operator.

  Works like the logical OR (`||`), except it only defaults to the right side if the left side is `nil` (whereas `||` also defaults on `false` and other falsy values).

  ## Examples

      iex> nil ||| "default"
      "default"
      
      iex> false ||| "default"
      false
      
      iex> 0 ||| "default"
      0
      
      iex> "" ||| "default"
      ""
  """
  defmacro l ||| r, do: join(:normal, l, r)

  @doc """
  Error-coalescing operator.

  Similar to the nil-coalescing operator (`|||`), but applies a similar logic of the OK-pipe (`~>`).

  It return the right side value if the left side is:
  - `nil`
  - `:error`
  - `{:error, _}`

  ## Examples

      iex> nil <~> "default"
      "default"
      
      iex> :error <~> "default"
      "default"
      
      iex> {:error, :reason} <~> "default"
      "default"
      
      iex> {:ok, "value"} <~> "default"
      {:ok, "value"}
      
      iex> "value" <~> "default"
      "value"
      
      iex> false <~> "default"
      false
  """
  defmacro l <~> r, do: join(:ok, l, r)

  @doc """
  Converts various values to an OK tuple format.

  - `{:ok, value}` and `{:error, reason}` are returned unchanged
  - `:error` is returned unchanged
  - `nil` is converted to `:error`
  - Any other value `x` is converted to `{:ok, x}`

  ## Examples

      iex> to_ok({:ok, 123})
      {:ok, 123}
      
      iex> to_ok({:error, :reason})
      {:error, :reason}
      
      iex> to_ok(:error)
      :error
      
      iex> to_ok(nil)
      :error
      
      iex> to_ok(123)
      {:ok, 123}
  """
  def to_ok(x) do
    case x do
      {:ok, _} -> x
      {:error, _} -> x
      :error -> :error
      nil -> :error
      x -> {:ok, x}
    end
  end

  @doc """
  Extracts values from OK tuples.

  - `{:ok, value}` returns `value`
  - `{:error, _}` returns `nil`
  - `:error` returns `nil`
  - Any other value is returned unchanged

  ## Examples

      iex> from_ok({:ok, 123})
      123
      
      iex> from_ok({:error, :reason})
      nil
      
      iex> from_ok(:error)
      nil
      
      iex> from_ok(123)
      123
  """
  def from_ok(x) do
    case x do
      {:ok, x} -> x
      {:error, _} -> nil
      :error -> nil
      # lenience
      x -> x
    end
  end

  @doc """
  Wraps a value in an OK tuple if it's not already in a result tuple format.

  - `{:ok, value}`, `{:error, reason}` and `:error` are returned unchanged
  - Any other value `x` is converted to `{:ok, x}`

  ## Examples

      iex> ok({:ok, 123})
      {:ok, 123}
      
      iex> ok({:error, :reason})
      {:error, :reason}
      
      iex> ok(:error)
      :error
      
      iex> ok(123)
      {:ok, 123}
  """
  def ok(x = {:ok, _}), do: x
  def ok(x = {:error, _}), do: x
  def ok(:error), do: :error
  def ok(x), do: {:ok, x}

  @doc """
  Wraps a value in an OK tuple or returns an error tuple with a default error.

  - `{:ok, value}`, `{:error, reason}` and `:error` are returned unchanged
  - `nil` returns `{:error, err}` where `err` is the default error provided in the second argument
  - Any other value `x` returns `{:ok, x}`

  ## Examples

      iex> ok_or({:ok, 123}, :default_error)
      {:ok, 123}
      
      iex> ok_or({:error, :reason}, :default_error)
      {:error, :reason}
      
      iex> ok_or(:error, :default_error)
      :error
      
      iex> ok_or(nil, :default_error)
      {:error, :default_error}
      
      iex> ok_or(123, :default_error)
      {:ok, 123}
  """
  def ok_or(x = {:ok, _}, _), do: x
  def ok_or(x = {:error, _}, _), do: x
  def ok_or(:error, _), do: :error
  def ok_or(nil, err), do: {:error, err}
  def ok_or(ok, _), do: {:ok, ok}

  defp ellipsis(l, arg) do
    Macro.prewalk(arg, 0, fn form, acc ->
      case form do
        {:..., _, ctx} when is_atom(ctx) or ctx == [] -> {l, acc + 1}
        _ -> {form, acc}
      end
    end)
  end

  defp pipe_args(where, l, args) do
    case ellipsis(l, args) do
      {args, 0} when where == :first -> [l | args]
      {args, _} -> args
    end
  end

  defp pipe(where, kind, l, r) do
    v = Macro.var(:ret, __MODULE__)

    case r do
      {name, meta, args} ->
        args = if(is_list(args), do: args, else: [])
        continue = {name, meta, pipe_args(where, v, args)}

        case kind do
          :normal ->
            quote generated: true do
              unquote(v) = unquote(l)
              unquote(continue)
            end

          :ok ->
            quote generated: true do
              case unquote(l) do
                nil -> nil
                :error -> :error
                {:error, _} = unquote(v) -> unquote(v)
                {:ok, unquote(v)} -> unquote(continue)
                unquote(v) -> unquote(continue)
              end
            end
        end

      _ ->
        case ellipsis(l, r) do
          {arg, 0} ->
            raise RuntimeError,
              message: "Can't pipe into #{inspect(r)}: missing ellipsis(`...`) in #{inspect(arg)}"

          {continue, _} ->
            case kind do
              :normal ->
                quote generated: true do
                  unquote(v) = unquote(l)
                  unquote(continue)
                end

              :ok ->
                quote generated: true do
                  case unquote(l) do
                    nil -> nil
                    :error -> :error
                    {:error, _} = unquote(v) -> unquote(v)
                    {:ok, unquote(v)} -> unquote(continue)
                    unquote(v) -> unquote(continue)
                  end
                end
            end
        end
    end
  end

  defp join(kind, l, r) do
    v = Macro.var(:l, __MODULE__)

    case kind do
      :normal ->
        quote generated: true do
          unquote(v) = unquote(l)
          if is_nil(unquote(v)), do: unquote(r), else: unquote(v)
        end

      :ok ->
        quote generated: true do
          case unquote(l) do
            nil -> unquote(r)
            :error -> unquote(r)
            {:error, _} -> unquote(r)
            unquote(v) -> unquote(v)
          end
        end
    end
  end
end
