tor &

# Wait for onion address to be generated
while [ ! -f /var/lib/tor/hidden_service/hostname ]; do
  sleep 1
done

echo "=========================================="
echo "Your Monero RPC Onion address is: $(cat /var/lib/tor/hidden_service/hostname)"
echo "=========================================="

# Keep alive
tail -f /dev/null