#!/bin/sh

survey()
{
	lua example/survey.lua server ipc:///tmp/survey.ipc & server=$!
	lua example/survey.lua client ipc:///tmp/survey.ipc client0 & client0=$!
	lua example/survey.lua client ipc:///tmp/survey.ipc client1 & client1=$!
	lua example/survey.lua client ipc:///tmp/survey.ipc client2 & client2=$!
	sleep 3
	kill $server $client0 $client1 $client2
}

reqrep()
{
	lua example/reqrep.lua node0 ipc:///tmp/reqrep.ipc & node0=$! && sleep 1
	lua example/reqrep.lua node1 ipc:///tmp/reqrep.ipc
	kill $node0
}

bus()
{
	lua example/bus.lua node0 ipc:///tmp/node0.ipc ipc:///tmp/node1.ipc ipc:///tmp/node2.ipc & node0=$!
	lua example/bus.lua node1 ipc:///tmp/node1.ipc ipc:///tmp/node2.ipc ipc:///tmp/node3.ipc & node1=$!
	lua example/bus.lua node2 ipc:///tmp/node2.ipc ipc:///tmp/node3.ipc & node2=$!
	lua example/bus.lua node3 ipc:///tmp/node3.ipc ipc:///tmp/node0.ipc & node3=$!
	sleep 5
	kill $node0 $node1 $node2 $node3
}

pair()
{
	lua example/pair.lua node0 ipc:///tmp/pair.ipc & node0=$!
	lua example/pair.lua node1 ipc:///tmp/pair.ipc & node1=$!
	sleep 3
	kill $node0 $node1
}

pipeline()
{
	lua example/pipeline.lua node0 ipc:///tmp/pipeline.ipc & node0=$! && sleep 1
	lua example/pipeline.lua node1 ipc:///tmp/pipeline.ipc "Hello, World."
	lua example/pipeline.lua node1 ipc:///tmp/pipeline.ipc "Goodbye."
	kill $node0
}

pubsub()
{
	lua example/pubsub.lua server ipc:///tmp/pubsub.ipc & server=$! && sleep 1
	lua example/pubsub.lua client ipc:///tmp/pubsub.ipc client0 & client0=$!
	lua example/pubsub.lua client ipc:///tmp/pubsub.ipc client1 & client1=$!
	lua example/pubsub.lua client ipc:///tmp/pubsub.ipc client2 & client2=$!
	sleep 5
	kill $server $client0 $client1 $client2
}


case $1 in 
	survey)
		survey
		;;
	bus)
		bus
		;;
	reqrep)
		reqrep
		;;
	pubsub)
		pubsub
		;;
	pair)
		pair
		;;
	pipeline)
		pipeline
		;;
	*)
		echo "Usage:" >&2
		echo "       $0 <survey|bus|pubsub|reqrep|pair|pipeline>" >&2
		exit 1
esac

