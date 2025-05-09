defmodule Arrows.Test do
  use ExUnit.Case
  use Arrows

  def double(x), do: x * 2
  def double_fst(x, _), do: x * 2
  def double_snd(_, x), do: x * 2
  def add_snd_thd(_, x, y), do: x + y

  test "|> drop-in replacement works" do
    assert 4 == 2 |> double
    assert 4 == 2 |> double()
    assert 4 == 2 |> double(...)
    assert 8 == 2 |> double(double(...))
    assert 4 == 2 |> double_fst(1)
    assert 4 == 2 |> double_fst(..., 1)
    assert 8 == 2 |> double_fst(double(...), 1)
    assert 4 == 2 |> double_snd(1, ...)
    assert 8 == 2 |> double_snd(1, double(...))
    assert 3 == 2 |> add_snd_thd(1, ..., 1)
    assert 4 == 2 |> add_snd_thd(1, ..., ...)
    assert 6 == 2 |> add_snd_thd(1, ..., double(...))
    assert 4 == 2 |> Arrows.Test.double()
    assert 4 == 2 |> Arrows.Test.double()
    assert 4 == 2 |> Arrows.Test.double(...)
    assert 8 == 2 |> Arrows.Test.double(double(...))
    assert 4 == 2 |> Arrows.Test.double_fst(1)
    assert 4 == 2 |> Arrows.Test.double_fst(..., 1)
    assert 8 == 2 |> Arrows.Test.double_fst(double(...), 1)
    assert 4 == 2 |> Arrows.Test.double_snd(1, ...)
    assert 8 == 2 |> Arrows.Test.double_snd(1, double(...))
    assert 3 == 2 |> Arrows.Test.add_snd_thd(1, ..., 1)
    assert 4 == 2 |> Arrows.Test.add_snd_thd(1, ..., ...)
    assert 6 == 2 |> Arrows.Test.add_snd_thd(1, ..., double(...))

    # FIXME
    # for x <- [:yes, 2, nil, false] do
    #   assert {:ok, x} == (x |> {:ok, ...})
    # end
  end

  # test ">>>" do
  #   assert 4 == (2 >>> double)
  #   assert 4 == (2 >>> double())
  #   assert 4 == (2 >>> double(...))
  #   assert 8 == (2 >>> double(double(...)))
  #   assert 4 == (2 >>> double_fst(..., 1))
  #   assert 8 == (2 >>> double_fst(double(...), 1))
  #   assert 4 == (2 >>> double_snd(1))
  #   assert 4 == (2 >>> double_snd(1, ...))
  #   assert 8 == (2 >>> double_snd(1, double(...)))
  #   assert 3 == (2 >>> add_snd_thd(1, ..., 1))
  #   assert 4 == (2 >>> add_snd_thd(1, ..., ...))
  #   assert 6 == (2 >>> add_snd_thd(1, ..., double(...)))
  # end

  # test "<<<" do
  #   assert 4 == (double <<< 2)
  #   assert 4 == (double() <<< 2)
  #   assert 4 == (double(...) <<< 2)
  #   assert 8 == (double(double(...)) <<< 2)
  #   assert 4 == (double_fst(..., 1) <<< 2)
  #   assert 8 == (double_fst(double(...), 1) <<< 2)
  #   assert 4 == (double_snd(1) <<< 2)
  #   assert 4 == (double_snd(1, ...) <<< 2)
  #   assert 8 == (double_snd(1, double(...)) <<< 2)
  #   assert 3 == (add_snd_thd(1, ..., 1) <<< 2)
  #   assert 4 == (add_snd_thd(1, ..., ...) <<< 2)
  #   assert 6 == (add_snd_thd(1, ..., double(...)) <<< 2)
  # end

  test "||| works like `||`, except only defaults if the left is nil (i.e. false is valid)" do
    assert 1 == (nil ||| 1)

    for thing <- [true, false, 2, [], :a, %{}, {}, {:ok, 2}, {:error, 2}],
        do: assert(thing == (thing ||| 1))
  end

  test "~> works as an OK-pipe" do
    assert nil == nil ~> double
    assert nil == nil ~> double()
    assert nil == nil ~> double(...)
    assert nil == nil ~> double(double(...))
    assert nil == nil ~> double_fst(1)
    assert nil == nil ~> double_fst(..., 1)
    assert nil == nil ~> double_fst(double(...), 1)
    assert nil == nil ~> double_snd(1, ...)
    assert nil == nil ~> double_snd(1, double(...))
    assert nil == nil ~> add_snd_thd(1, ..., 1)
    assert nil == nil ~> add_snd_thd(1, ..., ...)
    assert nil == nil ~> add_snd_thd(1, ..., double(...))

    assert 4 == 2 ~> double
    assert 4 == 2 ~> double()
    assert 4 == 2 ~> double(...)
    assert 8 == 2 ~> double(double(...))
    assert 4 == 2 ~> double_fst(1)
    assert 4 == 2 ~> double_fst(..., 1)
    assert 8 == 2 ~> double_fst(double(...), 1)
    assert 4 == 2 ~> double_snd(1, ...)
    assert 8 == 2 ~> double_snd(1, double(...))
    assert 3 == 2 ~> add_snd_thd(1, ..., 1)
    assert 4 == 2 ~> add_snd_thd(1, ..., ...)
    assert 6 == 2 ~> add_snd_thd(1, ..., double(...))

    assert 4 == {:ok, 2} ~> double
    assert 4 == {:ok, 2} ~> double()
    assert 4 == {:ok, 2} ~> double(...)
    assert 8 == {:ok, 2} ~> double(double(...))
    assert 4 == {:ok, 2} ~> double_fst(1)
    assert 4 == {:ok, 2} ~> double_fst(..., 1)
    assert 8 == {:ok, 2} ~> double_fst(double(...), 1)
    assert 4 == {:ok, 2} ~> double_snd(1, ...)
    assert 8 == {:ok, 2} ~> double_snd(1, double(...))
    assert 3 == {:ok, 2} ~> add_snd_thd(1, ..., 1)
    assert 4 == {:ok, 2} ~> add_snd_thd(1, ..., ...)
    assert 6 == {:ok, 2} ~> add_snd_thd(1, ..., double(...))

    for thing <- [:error, {:error, 2}] do
      assert thing == thing ~> double
      assert thing == thing ~> double()
      assert thing == thing ~> double(...)
      assert thing == thing ~> double(double(...))
      assert thing == thing ~> double_fst(1)
      assert thing == thing ~> double_fst(..., 1)
      assert thing == thing ~> double_fst(double(...), 1)
      assert thing == thing ~> double_snd(1, ...)
      assert thing == thing ~> double_snd(1, double(...))
      assert thing == thing ~> add_snd_thd(1, ..., 1)
      assert thing == thing ~> add_snd_thd(1, ..., ...)
      assert thing == thing ~> add_snd_thd(1, ..., double(...))
    end

    # FIXME
    # for x <- [:yes, 2, true] do
    #   assert {:ok, x} == (x ~> {:ok, ...})
    #   assert {:error, x} == ({:error, x} ~> {:ok, ...})
    # end
    # assert nil == (nil ~> {:ok, ...})
  end

  # test "<~" do
  #   assert nil == (double <~ nil)
  #   assert nil == (double() <~ nil)
  #   assert nil == (double(...) <~ nil)
  #   assert nil == (double(double(...)) <~ nil)
  #   assert nil == (double_fst(1) <~ nil)
  #   assert nil == (double_fst(..., 1) <~ nil)
  #   assert nil == (double_fst(double(...), 1) <~ nil)
  #   assert nil == (double_snd(1, ...) <~ nil)
  #   assert nil == (double_snd(1, double(...)) <~ nil)
  #   assert nil == (add_snd_thd(1, ..., 1) <~ nil)
  #   assert nil == (add_snd_thd(1, ..., ...) <~ nil)
  #   assert nil == (add_snd_thd(1, ..., double(...)) <~ nil)

  #   assert 4 == (double <~ 2)
  #   assert 4 == (double() <~ 2)
  #   assert 4 == (double(...) <~ 2)
  #   assert 8 == (double(double(...)) <~ 2)
  #   assert 4 == (double_fst(1) <~ 2)
  #   assert 4 == (double_fst(..., 1) <~ 2)
  #   assert 8 == (double_fst(double(...), 1) <~ 2)
  #   assert 4 == (double_snd(1, ...) <~ 2)
  #   assert 8 == (double_snd(1, double(...)) <~ 2)
  #   assert 3 == (add_snd_thd(1, ..., 1) <~ 2)
  #   assert 4 == (add_snd_thd(1, ..., ...) <~ 2)
  #   assert 6 == (add_snd_thd(1, ..., double(...)) <~ 2)

  #   assert 4 == (double <~ {:ok, 2})
  #   assert 4 == (double() <~ {:ok, 2})
  #   assert 4 == (double(...) <~ {:ok, 2})
  #   assert 8 == (double(double(...)) <~ {:ok, 2})
  #   assert 4 == (double_fst(1) <~ {:ok, 2})
  #   assert 4 == (double_fst(..., 1) <~ {:ok, 2})
  #   assert 8 == (double_fst(double(...), 1) <~ {:ok, 2})
  #   assert 4 == (double_snd(1, ...) <~ {:ok, 2})
  #   assert 8 == (double_snd(1, double(...)) <~ {:ok, 2})
  #   assert 3 == (add_snd_thd(1, ..., 1) <~ {:ok, 2})
  #   assert 4 == (add_snd_thd(1, ..., ...) <~ {:ok, 2})
  #   assert 6 == (add_snd_thd(1, ..., double(...)) <~ {:ok, 2})

  #   for thing <- [:error, {:error, 2}] do
  #     assert thing == (double <~ thing)
  #     assert thing == (double() <~ thing)
  #     assert thing == (double(...) <~ thing)
  #     assert thing == (double(double(...)) <~ thing)
  #     assert thing == (double_fst(1) <~ thing)
  #     assert thing == (double_fst(..., 1) <~ thing)
  #     assert thing == (double_fst(double(...), 1) <~ thing)
  #     assert thing == (double_snd(1, ...) <~ thing)
  #     assert thing == (double_snd(1, double(...)) <~ thing)
  #     assert thing == (add_snd_thd(1, ..., 1) <~ thing)
  #     assert thing == (add_snd_thd(1, ..., ...) <~ thing)
  #     assert thing == (add_snd_thd(1, ..., double(...)) <~ thing)
  #   end
  # end

  # test "~>>" do
  #   assert nil == (nil ~>> double)
  #   assert nil == (nil ~>> double())
  #   assert nil == (nil ~>> double(...))
  #   assert nil == (nil ~>> double(double(...)))
  #   assert nil == (nil ~>> double_fst(..., 1))
  #   assert nil == (nil ~>> double_fst(double(...), 1))
  #   assert nil == (nil ~>> double_snd(1))
  #   assert nil == (nil ~>> double_snd(1, ...))
  #   assert nil == (nil ~>> double_snd(1, double(...)))
  #   assert nil == (nil ~>> add_snd_thd(1, ..., 1))
  #   assert nil == (nil ~>> add_snd_thd(1, ..., ...))
  #   assert nil == (nil ~>> add_snd_thd(1, ..., double(...)))

  #   assert 4 == (2 ~>> double)
  #   assert 4 == (2 ~>> double())
  #   assert 4 == (2 ~>> double(...))
  #   assert 8 == (2 ~>> double(double(...)))
  #   assert 4 == (2 ~>> double_fst(..., 1))
  #   assert 8 == (2 ~>> double_fst(double(...), 1))
  #   assert 4 == (2 ~>> double_snd(1))
  #   assert 4 == (2 ~>> double_snd(1, ...))
  #   assert 8 == (2 ~>> double_snd(1, double(...)))
  #   assert 3 == (2 ~>> add_snd_thd(1, ..., 1))
  #   assert 4 == (2 ~>> add_snd_thd(1, ..., ...))
  #   assert 6 == (2 ~>> add_snd_thd(1, ..., double(...)))

  #   assert 4 == ({:ok, 2} ~>> double)
  #   assert 4 == ({:ok, 2} ~>> double())
  #   assert 4 == ({:ok, 2} ~>> double(...))
  #   assert 8 == ({:ok, 2} ~>> double(double(...)))
  #   assert 4 == ({:ok, 2} ~>> double_fst(..., 1))
  #   assert 8 == ({:ok, 2} ~>> double_fst(double(...), 1))
  #   assert 4 == ({:ok, 2} ~>> double_snd(1))
  #   assert 4 == ({:ok, 2} ~>> double_snd(1, ...))
  #   assert 8 == ({:ok, 2} ~>> double_snd(1, double(...)))
  #   assert 3 == ({:ok, 2} ~>> add_snd_thd(1, ..., 1))
  #   assert 4 == ({:ok, 2} ~>> add_snd_thd(1, ..., ...))
  #   assert 6 == ({:ok, 2} ~>> add_snd_thd(1, ..., double(...)))

  #   for thing <- [:error, {:error, 2}] do
  #     assert thing == (thing ~>> double)
  #     assert thing == (thing ~>> double())
  #     assert thing == (thing ~>> double(...))
  #     assert thing == (thing ~>> double(double(...)))
  #     assert thing == (thing ~>> double_fst(..., 1))
  #     assert thing == (thing ~>> double_fst(double(...), 1))
  #     assert thing == (thing ~>> double_snd(1))
  #     assert thing == (thing ~>> double_snd(1, ...))
  #     assert thing == (thing ~>> double_snd(1, double(...)))
  #     assert thing == (thing ~>> add_snd_thd(1, ..., 1))
  #     assert thing == (thing ~>> add_snd_thd(1, ..., ...))
  #     assert thing == (thing ~>> add_snd_thd(1, ..., double(...)))
  #   end
  # end

  # test "<<~" do
  #   assert nil == (double <<~ nil)
  #   assert nil == (double() <<~ nil)
  #   assert nil == (double(...) <<~ nil)
  #   assert nil == (double(double(...)) <<~ nil)
  #   assert nil == (double_fst(..., 1) <<~ nil)
  #   assert nil == (double_fst(double(...), 1) <<~ nil)
  #   assert nil == (double_snd(1) <<~ nil)
  #   assert nil == (double_snd(1, ...) <<~ nil)
  #   assert nil == (double_snd(1, double(...)) <<~ nil)
  #   assert nil == (add_snd_thd(1, ..., 1) <<~ nil)
  #   assert nil == (add_snd_thd(1, ..., ...) <<~ nil)
  #   assert nil == (add_snd_thd(1, ..., double(...)) <<~ nil)

  #   assert 4 == (double <<~ 2)
  #   assert 4 == (double() <<~ 2)
  #   assert 4 == (double(...) <<~ 2)
  #   assert 8 == (double(double(...)) <<~ 2)
  #   assert 4 == (double_fst(..., 1) <<~ 2)
  #   assert 8 == (double_fst(double(...), 1) <<~ 2)
  #   assert 4 == (double_snd(1) <<~ 2)
  #   assert 4 == (double_snd(1, ...) <<~ 2)
  #   assert 8 == (double_snd(1, double(...)) <<~ 2)
  #   assert 3 == (add_snd_thd(1, ..., 1) <<~ 2)
  #   assert 4 == (add_snd_thd(1, ..., ...) <<~ 2)
  #   assert 6 == (add_snd_thd(1, ..., double(...)) <<~ 2)

  #   assert 4 == (double <<~ {:ok, 2})
  #   assert 4 == (double() <<~ {:ok, 2})
  #   assert 4 == (double(...) <<~ {:ok, 2})
  #   assert 8 == (double(double(...)) <<~ {:ok, 2})
  #   assert 4 == (double_fst(..., 1) <<~ {:ok, 2})
  #   assert 8 == (double_fst(double(...), 1) <<~ {:ok, 2})
  #   assert 4 == (double_snd(1) <<~ {:ok, 2})
  #   assert 4 == (double_snd(1, ...) <<~ {:ok, 2})
  #   assert 8 == (double_snd(1, double(...)) <<~ {:ok, 2})
  #   assert 3 == (add_snd_thd(1, ..., 1) <<~ {:ok, 2})
  #   assert 4 == (add_snd_thd(1, ..., ...) <<~ {:ok, 2})
  #   assert 6 == (add_snd_thd(1, ..., double(...)) <<~ {:ok, 2})

  #   for thing <- [:error, {:error, 2}] do
  #     assert thing == (double <<~ thing)
  #     assert thing == (double() <<~ thing)
  #     assert thing == (double(...) <<~ thing)
  #     assert thing == (double(double(...)) <<~ thing)
  #     assert thing == (double_fst(..., 1) <<~ thing)
  #     assert thing == (double_fst(double(...), 1) <<~ thing)
  #     assert thing == (double_snd(1) <<~ thing)
  #     assert thing == (double_snd(1, ...) <<~ thing)
  #     assert thing == (double_snd(1, double(...)) <<~ thing)
  #     assert thing == (add_snd_thd(1, ..., 1) <<~ thing)
  #     assert thing == (add_snd_thd(1, ..., ...) <<~ thing)
  #     assert thing == (add_snd_thd(1, ..., double(...)) <<~ thing)
  #   end
  # end

  test "<~> works like `||`, except with the logic applied by `~>`" do
    assert 1 == nil <~> 1
    assert 1 == :error <~> 1
    assert {:ok, nil} == {:ok, nil} <~> 1

    for thing <- [true, false, 2, [], :a, %{}, {}] do
      assert thing == thing <~> 1
      assert {:ok, thing} == {:ok, thing} <~> 1
      assert 1 == {:error, thing} <~> 1
    end
  end

  test "when you use `...` twice within a single pipe, it should pipe the same value twice" do
    assert true =
             :rand.uniform()
             |> Kernel.==(..., ...)
  end
end
