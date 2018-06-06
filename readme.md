# guid - Yet another globally unique identifier generator service in Erlang

Guid produces 96-bit, k-ordered ids (read time-ordered lexically). Run one on each node in your infrastructure and they will generate conflict-free ids on-demand without coordination.

Inspired by Flake project: [Flake](https://github.com/boundary/flake), but with some modifications:
* get node id from args file instead of generating it by MAC Address;
* change the number of bits of node id from 48 to 16;
* no time persister, just depends on one NTP service.

# Get Started
Pull the code:

	git clone git://github.com/xuchaoqian/guid.git
	
Then edit <tt>config/vm.args</tt> to fit your environment:

* <tt>-node_id</tt> - set to an available node id in your cluster.

Then simply run the following command to see the result:

	make test

# Anatomy

Guid ids are 96-bits wide described here from most significant to least significant bits.

* 64-bit timestamp - milliseconds since the epoch (Jan 1 1970);
* 16-bit node id - node id from args file such as vm.args;
* 16-bit sequence # - usually 0, incremented when more than one id is requested in the same millisecond and reset to 0 when the clock ticks forward.
