# Entities in BitTorrent protocol
- A torrent file.
- A BitTorrent tracker.
- An 'original' downloader, who has the complete file available to be download.
- Multiple Peers.
# Metainfo
Metainfo is the `.torrent` file, which is a bencoded file containing:
- `announce`, the url of tracker server
- `info`, a dictionary containing keys
	- `name`, the suggested name to save the file (or dictionary) as.
	- `piece length`, the number of bytes in each piece is split into. (most commonly 256K)
	- `pieces`, a collection $\{H_i\}$, where for a given piece of the original file $p_i$, $H_i = SHA1(p_i)$.
	- `length` or`files` but not both, in which 
		- `length` representing the length of single file downloaded; 
		- `files` representing the dictionary that the multiple files we are about to download. The dictionary contains key:
			- `length`, the length of the file.
			- `path`, a list of UFT-8 strings representing the subdirectory structure of the downloading file.
# Tracker
Tracker server receives `GET` requests from each downloader to issue response containing the available peer for sharing the file. 

A tracker request contains:
- `info_hash`, a hash $H = SHA1(B)$, where $B$ is is the value of the info entry in the metainfo file.
- `peer_id`, an unique identifier of length 20 for the peer, randomly generated.
- `ip`, optional parameter, gives the IP address or DNS name of the peer at.
- `port`, the port number this peer is listening on. Begins trying to listen with port `6881`, if failed to listen, increment by one until reaches `6889`.
- `uploaded`, the total amount uploaded so far, ASCII encoded.
- `downloaded`, the total amount downloaded so far, ASCII encoded.
- `left`, the number of bytes this peer still has to download, ASCII encoded.
	- not equal to `length - download`.
- `event`, optional, an enum with value
	- `started`, indicates a download firstly begins.
	- `completed`, indicates a download is completed.
	- `stopped`
	- `empty`

A tracker response contains:
- `failure reason`, a human readable string explains the reason for failure.
- or
	- `interval`, the number of seconds the downloader should wait between regular re-requests.
	- `peers`, a list of dictionaries containing 
		- `peer id`
		- `ip`
		- `port`
# Peer Protocol
## Handshake 
- `"19BitTorrent protocol"`
- 8 bytes, reserved, all zero
- 20 bytes, SHA1 hash of the metainfo file
	- serve the connection if both sides don't send the same value.
	- TODO: what if there is a hash collision?
- 20 bytes, peer id
	- serve the connection if the receiving side's peer id doesn't match the one the initiating side expects

Connections contain two bits of state on either end:
- choked or not, choking = no data will be sent until unchoking happens.
- interested or not.

## Peer Messages
Each non-keepalive message starts with a byte indicating their type
- `0 - choke`, no payload
- `1 - unchoke`, no payload
- `2 - interested`, no payload
- `3 - not interested`, no payload
- `4 - have`, payload:
	- the index which that downloader just completed and checked the hash of.
- `5 - bitfield`, payload:
	- a bit map with each index that downloader has send set to 1
- `6 - request`
	- `index`, which piece we want to download 
	- `begin`, the downloading offset of the current progress
	- `length`
- `7 - piece`, response to request
	- `index
	- `begin`
	- `length`
- `8 - cancel`