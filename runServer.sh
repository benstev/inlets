go run main.go server --token=totor --print-token --disable-transport-wrapping
go run main.go client --token=totor --print-token --insecure --url=ws://127.0.0.1:8001 --upstream=zobi=http://127.0.0.1:3000
