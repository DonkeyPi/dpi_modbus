defmodule Ash.Modbus do
  alias Ash.Modbus.Master

  def with(key, opts, callback) do
    case Process.get(key) do
      nil -> Process.put(key, Master.open(opts))
      {:error, _} -> Process.put(key, Master.open(opts))
      {:ok, _} -> :nop
    end

    master = fn cmd ->
      {:ok, state} = Process.get(key)
      {state, result} = Master.exec(state, cmd)
      Process.put(key, {:ok, state})
      result
    end

    case Process.get(key) do
      {:error, reason} ->
        {:error, reason}

      {:ok, state} ->
        try do
          callback.(master)
          :ok
        rescue
          e ->
            Master.close(state)
            Process.delete(key)
            {:error, e}
        end
    end
  end
end
