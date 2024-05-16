defmodule Arrows do
  @moduledoc "./README.md" |> File.stream!() |> Enum.drop(1) |> Enum.join()

  defmacro __using__(_options) do
    quote do
      import Kernel, except: [|>: 2]
      import unquote(__MODULE__),
        only: [
          |>: 2, <|>: 2, ~>: 2, <~>: 2,
          ok: 1, to_ok: 1, from_ok: 1
        ]
    end
  end

  import Kernel, except: [|>: 2]

  defp ellipsis(l, arg) do
    Macro.prewalk(arg, 0, fn form, acc ->
      case form do
        {:..., _, c} when not is_list(c) -> {l, acc+1}
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
            quote [generated: true] do
              unquote(v) = unquote(l)
              unquote(continue)
            end
          :ok ->
            quote [generated: true] do
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
          {arg, 0} -> raise RuntimeError, message: "Can't pipe into #{inspect(r)}: missing ellipsis(`...`) in #{inspect(arg)}"
          {continue, _} ->
            case kind do
              :normal ->
                quote [generated: true] do
                  unquote(v) = unquote(l)
                  unquote(continue)
                end
              :ok ->
                quote [generated: true] do
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
        quote [generated: true] do
          unquote(v) = unquote(l)
          if is_nil(unquote(v)), do: unquote(r), else: unquote(v)
        end
      :ok ->
        quote [generated: true] do
          case unquote(l) do
            nil -> unquote(r)
            :error -> unquote(r)
            {:error, _} -> unquote(r)
            unquote(v) -> unquote(v)
          end
        end
    end
  end

  @doc """
  A more flexible drop-in replacement for the standard elixir pipe operator.

  Special features are unlocked when using the `...` (ellipsis) on the right hand side:

  * The right hand side need not be a function, it can be any expression containing the ellipsis.
  * The ellipsis will be replaced with the result of evaluating the hand side expression.
  * You may use the ellipsis multiple times and the left hand side will be calculated exactly once.

  You can do crazy stuff with the ellipsis, but remember that people have to read it!
  """
  defmacro l |> r,  do: pipe(:first, :normal, l, r)
  @doc "Like `||`, except only defaults if the left is nil (i.e. false is valid)"
  defmacro l <|> r, do: join(:normal, l, r)

  @doc "Like `OK.~>`"
  defmacro l ~> r,  do: pipe(:first, :ok, l, r)

  @doc "Like `||`, except with the logic applied by `~>`"
  defmacro l <~> r, do: join(:ok, l, r)

  def to_ok(x) do
    case x do
      {:ok, _} -> x
      {:error, _} -> x
      :error -> x
      nil -> :error
      x -> {:ok, x}
    end
  end

  def from_ok(x) do
    case x do
      {:ok, x} -> x
      {:error, _} -> nil
      :error -> nil
      x -> x # lenience
    end
  end

  def ok(x={:ok, _}), do: x
  def ok(x={:error, _}), do: x
  def ok(:error), do: :error
  def ok(x), do: {:ok, x}

  def ok_or(x={:ok, _}, _), do: x
  def ok_or(x={:error, _}, _), do: x
  def ok_or(:error, _), do: :error
  def ok_or(nil, err), do: {:error, err}
  def ok_or(ok, _), do: {:ok, ok}

end
