defmodule Arrows do
  @moduledoc """
  A handful of (mostly) arrow macros with superpowers.
  """

  defmacro __using__(_foptions) do
    quote do
      import Kernel, except: [|>: 2]
      import unquote(__MODULE__),
        only: [|>: 2, >>>: 2, <|>: 2,
               <<<: 2, <~: 2, <<~: 2,
               ~>: 2, ~>>: 2, <~>: 2,
              ]
    end
  end

  import Kernel, except: [|>: 2]

  defp pipe_args(where, l, args) do
    r = Macro.prewalk(args, 0, fn form, acc ->
      case form do
        {:..., _, c} when not is_list(c) -> {l, acc+1}
        _ -> {form, acc}
      end
    end)
    case r do
      {args, 0} when where == :first -> [l | args]
      {args, 0} when where == :last -> args ++ [l]
      {args, _} -> args
    end
  end

  defp pipe(where, kind, l, r) do
    case r do
      {name, meta, args} ->
        args = if(is_list(args), do: args, else: [])
        v = Macro.var(:ret, __MODULE__)
        continue = {name, meta, pipe_args(where, v, args)}
        case kind do
          :normal ->
            quote do
              unquote(v) = unquote(l)
              unquote(continue)
            end
          :ok ->
            quote do
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
        raise RuntimeError, message: "Can't pipe into #{inspect(r)}"
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

  @doc "Like `Magritte.|>`"
  defmacro l |> r,  do: pipe(:first, :normal, l, r)
  @doc "Like `|>`, except threads into the *last* argument position."
  defmacro l >>> r, do: pipe(:last, :normal, l, r)
  @doc "Like `>>>`, except the argument order is flipped"
  defmacro l <<< r, do: pipe(:last, :normal, r, l)
  @doc "Like `||`, except only defaults if the left is nil (i.e. false is valid)"
  defmacro l <|> r, do: join(:normal, l, r)

  @doc "Like `OK.~>`"
  defmacro l ~> r,  do: pipe(:first, :ok, l, r)
  @doc "Like `~>`, except the argument order is flipped"
  defmacro l <~ r,  do: pipe(:first, :ok, r, l)
  @doc "Like `~>`, except threads into the *last* argument position"
  defmacro l ~>> r, do: pipe(:last, :ok, l, r)
  @doc "Like `~>>`, except the argument order is flipped"
  defmacro l <<~ r, do: pipe(:last, :ok, r, l)

  @doc "Like `||`, except with the logic applied by `~>`"
  defmacro l <~> r, do: join(:ok, l, r)

end
