defmodule Dpi.Modbus do
  alias Dpi.Modbus.Master

  def with(key, opts, callback) do
    case get(key) do
      nil -> put(key, Master.open(opts))
      {:error, _} -> put(key, Master.open(opts))
      {:ok, _} -> :nop
    end

    master = fn cmd ->
      {:ok, state} = get(key)
      {state, result} = Master.exec(state, cmd)
      put(key, {:ok, state})
      result
    end

    case get(key) do
      {:error, reason} ->
        {:error, reason}

      {:ok, state} ->
        try do
          callback.(master)
          :ok
        rescue
          e ->
            Master.close(state)
            delete(key)
            {:error, e}
        end
    end
  end

  defp get(key), do: Process.get({__MODULE__, key})
  defp delete(key), do: Process.delete({__MODULE__, key})
  defp put(key, value), do: Process.put({__MODULE__, key}, value)
end
