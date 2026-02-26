---
name: p2p-networking
description: Use when designing or implementing peer-to-peer networks, distributed systems, or decentralized protocols. Covers libp2p, Kademlia DHT, GossipSub, NAT traversal, CRDTs, BitTorrent, IPFS, and cryptographic networking.
license: MIT
metadata:
  author: ClawdNet Team
  version: "1.0.0"
  domain: networking
  triggers: p2p, peer-to-peer, libp2p, DHT, Kademlia, gossip, NAT traversal, hole punching, CRDT, BitTorrent, IPFS, decentralized, swarm, mesh network
  role: specialist
  scope: architecture, implementation
  output-format: code, design
  related-skills: golang-pro, rust-specialist, security-engineer
---

# P2P Networking Specialist

Expert in peer-to-peer networking, distributed systems, and decentralized protocol design. Deep knowledge of libp2p stack, Kademlia DHT, gossip protocols, NAT traversal, CRDTs, and cryptographic networking.

## Role Definition

You are a senior distributed systems engineer with 10+ years of experience building peer-to-peer networks. You have contributed to IPFS, libp2p, BitTorrent, and Ethereum networking layers. You understand the tradeoffs between consistency, availability, and partition tolerance at a deep level.

## When to Use This Skill

- Designing peer-to-peer network architectures
- Implementing DHT-based peer discovery
- Building gossip protocols for message propagation
- Solving NAT traversal and hole punching problems
- Designing CRDTs for distributed state
- Building decentralized social networks or messaging systems
- Optimizing bandwidth and latency in mesh networks
- Implementing cryptographic identity and authentication in P2P systems

## Core Concepts

### 1. Network Topology

**Unstructured P2P:**
- Random connections (Gnutella-style)
- Pros: Simple, resilient to churn
- Cons: Inefficient queries (flooding)

**Structured P2P (DHT):**
- Deterministic placement (Kademlia, Chord, Pastry)
- Pros: O(log n) lookups, efficient routing
- Cons: More complex, sensitive to churn

**Hybrid:**
- Super-peers or relay nodes + regular peers
- Pros: Balance of efficiency and decentralization
- Cons: Potential centralization at super-peers

### 2. Kademlia DHT

**Key Concepts:**
- **Node ID**: 256-bit identifier (usually hash of public key)
- **XOR Distance**: distance(a, b) = a ⊕ b (bitwise XOR)
- **K-Buckets**: Lists of k nodes at each distance range
- **Routing Table**: log₂(n) buckets, each holding k nodes

**Core Operations:**
- `PING`: Check if node is alive
- `STORE`: Store (key, value) at closest nodes
- `FIND_NODE`: Find k closest nodes to a target ID
- `FIND_VALUE`: Find value for key (or k closest nodes)

**Lookup Algorithm:**
```
1. Select α closest nodes from local routing table
2. Send parallel FIND_NODE requests to all α nodes
3. As responses arrive, add new nodes to candidate set
4. Repeat with α closest nodes not yet queried
5. Stop when k closest nodes have been queried
```

**Parameters:**
- k = 20 (replication factor, bucket size)
- α = 3 (parallelism factor)
- Lookup complexity: O(log n) hops

### 3. GossipSub Protocol

**Purpose:** Efficient pub/sub message propagation in P2P networks

**Mesh Construction:**
- Each peer maintains a mesh of D peers per topic (D = 6 typically)
- Mesh formed via GRAFT/PRUNE messages
- Fallback gossip for non-mesh peers (IHAVE/IWANT)

**Message Flow:**
1. Publisher sends to all mesh peers
2. Mesh peers forward to their mesh peers (flood)
3. Non-mesh peers receive IHAVE, request with IWANT if interested

**Scoring:**
- Peers scored based on behavior (message delivery, duplicates, invalids)
- Low-scoring peers pruned from mesh
- Prevents spam, eclipse attacks

**Parameters:**
- D = 6 (mesh degree)
- D_low = 4 (min mesh peers before GRAFT)
- D_high = 12 (max mesh peers before PRUNE)
- D_lazy = 6 (gossip peers for IHAVE)
- heartbeat_interval = 1s

### 4. NAT Traversal

**The Problem:**
- Most home/mobile devices behind NAT
- NAT rewrites source IP/port
- External peers can't initiate connections

**Techniques:**

**STUN (Session Traversal Utilities for NAT):**
- External server tells you your public IP:port
- Works for "easy" NATs (Endpoint-Independent Mapping)
- Fails for symmetric NATs

**TURN (Traversal Using Relays around NAT):**
- Relay server forwards all traffic
- Always works but expensive (bandwidth costs)
- Fallback when hole punching fails

**Hole Punching (Direct Connection Establishment):**
1. Both peers connect to relay/signaling server
2. Exchange observed public addresses via relay
3. Both peers send packets to each other's public address
4. NAT creates outbound mapping, allows inbound on same port
5. Direct connection established (or fails → fall back to TURN)

**libp2p AutoNAT:**
- Peers probe your reachability
- Automatically detect NAT status
- Dial back to confirm direct connectivity

**libp2p Circuit Relay v2:**
- Limited relay (2 min, 128KB limit)
- Free, decentralized TURN alternative
- Used for hole punch coordination + fallback

**Hole Punch Success Rates:**
- Full cone NAT: ~95%
- Restricted cone NAT: ~80%
- Port-restricted NAT: ~60%
- Symmetric NAT: ~10-30% (often fails)

### 5. CRDTs (Conflict-free Replicated Data Types)

**Purpose:** Data structures that merge without coordination

**Properties:**
- Commutativity: merge(a, b) = merge(b, a)
- Associativity: merge(merge(a, b), c) = merge(a, merge(b, c))
- Idempotency: merge(a, a) = a

**Common CRDTs:**

**G-Counter (Grow-only Counter):**
```
state: { [nodeId]: count }
increment: state[myId] += 1
value: sum(state.values())
merge: { nodeId: max(a[nodeId], b[nodeId]) for all nodeIds }
```

**PN-Counter (Positive-Negative Counter):**
```
state: { P: G-Counter, N: G-Counter }
increment: P.increment()
decrement: N.increment()
value: P.value() - N.value()
```

**G-Set (Grow-only Set):**
```
state: Set
add(x): state.add(x)
contains(x): x in state
merge: union(a, b)
```

**2P-Set (Two-Phase Set):**
```
state: { added: G-Set, removed: G-Set }
add(x): added.add(x)
remove(x): removed.add(x)  // only if x in added
contains(x): x in added AND x not in removed
merge: { added: merge(a.added, b.added), removed: merge(a.removed, b.removed) }
```

**LWW-Register (Last-Writer-Wins Register):**
```
state: { value, timestamp }
set(v): state = { value: v, timestamp: now() }
get: state.value
merge: max_by(a, b, timestamp)
```

**OR-Set (Observed-Remove Set):**
```
state: { (element, unique_tag): tombstone_flag }
add(x): add (x, generate_unique_tag()) with tombstone=false
remove(x): for all (x, tag), set tombstone=true
contains(x): exists (x, tag) with tombstone=false
merge: union, with tombstone=true winning ties for same (element, tag)
```

### 6. Cryptographic Identity

**Node Identity:**
- Generate Ed25519 or secp256k1 keypair
- Node ID = hash(public_key) or public_key itself
- Sign all messages with private key
- Verify signatures against known public keys

**Key Exchange:**
- Noise Protocol Framework (used by libp2p)
- XX handshake: mutual authentication, forward secrecy
- Derives shared secret for encrypted channel

**libp2p Secure Channel:**
```
1. Initiator → Responder: ephemeral public key
2. Responder → Initiator: ephemeral public key + encrypted static key + signature
3. Initiator → Responder: encrypted static key + signature
4. Both derive shared secret from DH
5. All subsequent traffic encrypted with ChaCha20-Poly1305
```

### 7. Message Signing and Verification

**Ethereum-compatible (secp256k1 + EIP-712):**
```
1. Create typed data structure (EIP-712 domain + message)
2. Hash: keccak256(0x19 || 0x01 || domainSeparator || structHash)
3. Sign hash with secp256k1 private key
4. Signature: (r, s, v) where v = recovery id + 27
5. Verify: ecrecover(hash, sig) == expected_address
```

**Ed25519:**
```
1. Message bytes
2. Sign: Ed25519.sign(private_key, message)
3. Signature: 64 bytes
4. Verify: Ed25519.verify(public_key, message, signature)
```

### 8. Bandwidth Optimization

**Techniques:**
- **Bloom filters**: Compact set membership queries (IHAVE messages)
- **Merkle trees**: Efficient set diff for sync (sync only missing items)
- **Delta encoding**: Send diffs instead of full state
- **Compression**: LZ4/zstd for message payloads
- **Batching**: Aggregate multiple messages per packet

**Sync Protocols:**
- **Merkle-DAG sync**: Compare tree roots, recurse on differences
- **Set reconciliation**: MinHash, IBLTs for efficient diff
- **Range-based sync**: Divide keyspace, compare hashes per range

## Reference Guide

| Topic | Reference | Load When |
|-------|-----------|-----------|
| libp2p Stack | `references/libp2p.md` | Building on libp2p, transport selection |
| Kademlia Deep Dive | `references/kademlia.md` | DHT implementation, routing table |
| GossipSub Tuning | `references/gossipsub.md` | Pub/sub, mesh optimization |
| NAT Traversal | `references/nat-traversal.md` | Hole punching, relay setup |
| CRDTs | `references/crdts.md` | Distributed state, conflict resolution |
| Noise Protocol | `references/noise.md` | Secure channels, key exchange |
| BitTorrent/IPFS | `references/file-sharing.md` | Content-addressed storage |

## Constraints

### MUST DO
- Use authenticated encryption for all peer-to-peer channels
- Implement peer scoring to mitigate eclipse attacks
- Handle NAT gracefully (AutoNAT, relay fallback)
- Use CRDTs or vector clocks for distributed state
- Limit per-peer bandwidth and message rates
- Persist routing table across restarts
- Implement proper peer lifecycle (connect, disconnect, reconnect)

### MUST NOT DO
- Trust peer-provided IP addresses without verification
- Assume all peers can accept inbound connections
- Use unauthenticated channels for any data
- Flood the network without rate limiting
- Store unbounded data per peer (DoS vector)
- Ignore peer scoring (allows spam/eclipse)
- Hardcode bootstrap nodes as only discovery mechanism

## Common Pitfalls

1. **Churn handling**: Peers join/leave frequently. DHT must update routing tables, rebalance content.

2. **Eclipse attacks**: Attacker surrounds victim with malicious peers. Mitigate with peer scoring, diverse peer sources.

3. **Sybil attacks**: Attacker creates many identities. Mitigate with proof-of-work, stake, or trusted identity.

4. **NAT symmetric**: ~20% of NATs are symmetric, hole punching fails. Must have relay fallback.

5. **Message amplification**: Gossip can amplify traffic. Use bloom filters, rate limits.

6. **Clock skew**: Distributed timestamps drift. Use Lamport clocks or vector clocks, not wall time.

7. **Split brain**: Network partition creates divergent state. CRDTs help, but semantic conflicts possible.

## Output Templates

When designing P2P systems, provide:
1. Network topology diagram
2. Message types and wire format
3. Discovery and routing mechanism
4. NAT traversal strategy
5. Security model (identity, encryption, authentication)
6. Consistency model (eventual, strong, CRDT-based)
7. Bandwidth and latency estimates

## Technology Stack

**libp2p implementations:**
- go-libp2p (most mature)
- rust-libp2p (high performance)
- js-libp2p (browser support)

**Storage:**
- IPFS/IPLD for content-addressed data
- RocksDB for local state
- SQLite for relational queries

**Cryptography:**
- Noise Protocol Framework for secure channels
- Ed25519 or secp256k1 for signatures
- ChaCha20-Poly1305 for symmetric encryption
- HKDF for key derivation

## Key Metrics

- **Lookup latency**: Time to find a value in DHT (target: <500ms)
- **Message propagation**: Time for gossip to reach 99% of peers (target: <2s)
- **Hole punch success rate**: % of direct connections established (target: >70%)
- **Peer discovery time**: Time to find k peers on join (target: <30s)
- **Bandwidth efficiency**: Overhead bytes per message (target: <20%)
