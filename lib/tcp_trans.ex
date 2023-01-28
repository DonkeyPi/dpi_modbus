defmodule Dpi.Modbus.Tcp.Transport do
  @moduledoc false
  @behaviour Dpi.Modbus.Transport
  @to 2000

  def open(opts) do
    ip = Keyword.fetch!(opts, :ip) |> fix_ip()
    port = Keyword.fetch!(opts, :port)
    timeout = Keyword.get(opts, :timeout, @to)
    opts = [:binary, packet: :raw, active: false]
    :gen_tcp.connect(ip, port, opts, timeout)
  end

  def readn(socket, count, timeout) do
    :gen_tcp.recv(socket, count, timeout)
  end

  def readp(socket) do
    :gen_tcp.recv(socket, 0)
  end

  def write(socket, packet) do
    # discard before send
    :gen_tcp.recv(socket, 0, 0)
    :gen_tcp.send(socket, packet)
  end

  def close(socket) do
    :gen_tcp.close(socket)
  end

  defp fix_ip(ip) when is_binary(ip), do: ip |> String.to_charlist()
  defp fix_ip({a, b, c, d}), do: '#{a}.#{b}.#{c}.#{d}'
  defp fix_ip(ip) when is_list(ip), do: ip
end
