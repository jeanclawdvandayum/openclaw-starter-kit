# libp2p Deep Dive

## Architecture Overview

libp2p is a modular networking stack for peer-to-peer applications. Used by IPFS, Filecoin, Ethereum 2.0, and Polkadot.

## Core Layers

### 1. Transports
Low-level connection establishment.

**Available Transports:**
- **TCP**: Reliable, works everywhere, blocked by some firewalls
- **QUIC**: UDP-based, multiplexed, faster handshakes, better NAT traversal
- **WebSocket**: Browser-compatible TCP
- **WebRTC**: Browser P2P with built-in NAT traversal
- **WebTransport**: HTTP/3-based, browser-compatible QUIC

**Recommendation:**
- Servers: QUIC + TCP fallback
- Browsers: WebSocket + WebRTC
- Mobile: QUIC

### 2. Secure Channels
Encryption and authentication.

**Noise Protocol (default):**
- XX handshake pattern (mutual auth)
- Forward secrecy via ephemeral DH
- ChaCha20-Poly1305 for symmetric encryption

**TLS 1.3:**
- Alternative to Noise
- Uses libp2p-specific certificate extension
- Good for interop with existing TLS infrastructure

### 3. Multiplexing
Multiple streams over single connection.

**yamux:**
- Default multiplexer
- Bidirectional streams
- Flow control per stream
- Used by IPFS, Filecoin

**mplex:**
- Simpler protocol
- Less overhead
- Being deprecated

### 4. Peer Discovery

**mDNS:**
- Local network discovery
- No internet required
- Good for development

**Kademlia DHT:**
- Global peer discovery
- Also used for content routing
- O(log n) lookups

**Bootstrap Nodes:**
- Hardcoded initial peers
- Should be diverse (different operators, regions)
- Fallback if DHT fails

**Rendezvous:**
- Topic-based discovery
- Peers register at rendezvous points
- Good for application-specific discovery

### 5. Publish/Subscribe

**GossipSub 1.1:**
- Mesh-based pub/sub
- Peer scoring for spam resistance
- Used by Ethereum consensus layer

**FloodSub:**
- Simple flooding
- High bandwidth cost
- Only for small networks

### 6. NAT Traversal

**AutoNAT:**
- Detects NAT status
- Peers probe your reachability
- Three states: Public, Private, Unknown

**Circuit Relay v2:**
- Limited relay through other peers
- 2-minute reservation, 128KB limit
- Free, decentralized TURN alternative

**DCUtR (Direct Connection Upgrade):**
- Hole punching coordination
- Simultaneous open via relay
- Upgrades relayed connection to direct

## Peer Addressing

**Multiaddress format:**
```
/ip4/192.168.1.1/tcp/4001/p2p/QmNodeId
/dns4/node.example.com/tcp/443/wss/p2p/QmNodeId
/ip4/192.168.1.1/udp/4001/quic-v1/p2p/QmNodeId
```

**Peer ID:**
- Multihash of public key
- Usually SHA-256(Ed25519 public key)
- Base58 encoded: Qm... or 12D3Koo...

## Connection Lifecycle

```
1. Dial multiaddress
2. Transport handshake (TCP connect, QUIC handshake)
3. Security handshake (Noise XX)
4. Multiplexer negotiation (yamux)
5. Protocol negotiation (/ipfs/kad/1.0.0, /meshsub/1.1.0)
6. Application streams
```

## Protocol Negotiation

**Multistream-select:**
```
-> /multistream/1.0.0
<- /multistream/1.0.0
-> /ipfs/kad/1.0.0
<- /ipfs/kad/1.0.0
(protocol-specific messages follow)
```

## Configuration Example (TypeScript)

```typescript
import { createLibp2p } from 'libp2p'
import { tcp } from '@libp2p/tcp'
import { noise } from '@chainsafe/libp2p-noise'
import { yamux } from '@chainsafe/libp2p-yamux'
import { kadDHT } from '@libp2p/kad-dht'
import { gossipsub } from '@chainsafe/libp2p-gossipsub'

const node = await createLibp2p({
  addresses: {
    listen: ['/ip4/0.0.0.0/tcp/0']
  },
  transports: [tcp()],
  connectionEncryption: [noise()],
  streamMuxers: [yamux()],
  services: {
    dht: kadDHT({
      clientMode: false,  // full DHT node
      validators: { ... },
      selectors: { ... }
    }),
    pubsub: gossipsub({
      emitSelf: false,
      gossipsubIWantFollowupMs: 100,
      heartbeatInterval: 1000
    })
  },
  connectionManager: {
    maxConnections: 100,
    minConnections: 20
  }
})

await node.start()
```

## Performance Tuning

**Connection limits:**
- maxConnections: 50-300 depending on resources
- minConnections: 10-50 for DHT health
- maxIncomingPendingConnections: 10-50

**DHT tuning:**
- k (bucket size): 20 is default, increase for faster lookups
- α (parallelism): 3 is default, increase for faster but more bandwidth

**GossipSub tuning:**
- D (mesh degree): 6-8 for most applications
- D_low: 4 (trigger GRAFT below this)
- D_high: 12 (trigger PRUNE above this)
- heartbeatInterval: 700ms-1s

## Debugging

**Metrics to monitor:**
- Connection count (in/out)
- Stream count per protocol
- DHT routing table size
- GossipSub mesh size per topic
- Bandwidth per peer
- Latency to bootstrap nodes

**Common issues:**
- "Unable to dial peer": Check firewall, NAT config
- "Too many open files": Increase ulimit
- "Connection reset": Aggressive NAT timeouts, add keepalive
- "DHT lookups slow": Check routing table health, add bootstrap nodes
