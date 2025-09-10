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
  Extracts values from OK tuples.

  - `{:ok, value}` returns `value`
  - `{:error, _}` returns `false`
  - `:ok` returns `true`
  - `:error` returns `false`
  - Any other value is returned unchanged

  ## Examples

      iex> from_ok({:ok, 123})
      123
      
      iex> from_ok({:error, :reason})
      false
      
      iex> from_ok(:error)
      false
      
      iex> from_ok(123)
      123

      iex> from_ok({:ok, 42})
      42

      iex> from_ok(:ok)
      true

      iex> from_ok(:ok, default_value: "all ok")
      "all ok"

      iex> from_ok({:error, "something went wrong"}, on_error: "error msg")
      "error msg"

      iex> from_ok(:error, on_error: "error msg")
      "error msg"

      iex> from_ok(nil, on_error: "error msg")
      nil
  """
  def from_ok(x, opts \\ [default_value: true, on_error: false]) do
    case x do
      {:ok, x} -> x
      :ok -> opts[:default_value]
      {:error, _e} -> opts[:on_error]
      :error -> opts[:on_error]
      # lenience
      x -> x
    end
  end

  # def from_ok(val, fallback \\ nil)
  # def from_ok({:ok, val}, _fallback), do: val
  # def from_ok({:error, _val}, fallback), do: fallback
  # def from_ok(:error, fallback), do: fallback
  # def from_ok(val, fallback), do: val || fallback



   @doc """

  Unwraps an `{:ok, val}` tuple, returning the value. If not OK, returns a fallback value (default is `nil`).

  ## Parameters

    - `val`: The value or tuple to unwrap.
    - `fallback`: The fallback value if the tuple is an error.

  ## Examples


  """
  # def from_ok(val, fallback \\ nil)
  # def from_ok({:ok, val}, _fallback), do: val

  # def from_ok({:error, val}, fallback) do
  #   error(val)
  #   fallback
  # end

  # def from_ok(:ok, fallback), do: fallback
  # def from_ok(:error, fallback), do: fallback
  # def from_ok(val, fallback), do: val || fallback


  @doc """
  Wraps a value in an OK tuple or returns an error tuple. Sets a default value or error when none is provided.

  ## Examples

      iex> ok({:ok, 123})
      {:ok, 123}
      
      iex> ok({:error, :reason})
      {:error, :reason}
      
      iex> ok(123)
      {:ok, 123}

      iex> ok({:ok, 123}, default_error: "default error msg")
      {:ok, 123}

      iex> ok({:error, :reason}, default_error: "default error msg")
      {:error, :reason}

      iex> ok(:error, default_error: "default error msg")
      {:error, "default error msg"}

      iex> ok(nil, default_error: "default error msg")
      {:error, "default error msg"}

      iex> ok(123, default_error: "default error msg")
      {:ok, 123}

      iex> ok(:ok, default_value: "all ok")
      {:ok, "all ok"}
  """
  def ok(x, opts \\ [default_value: true, default_error: nil]) do
    case x do
      {:ok, _} -> x
      {:error, _} -> x
      :error -> {:error, opts[:default_error]}
      :ok -> {:ok, opts[:default_value]}
      nil -> {:error, opts[:default_error]}
      x -> {:ok, x}
    end
  end

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
