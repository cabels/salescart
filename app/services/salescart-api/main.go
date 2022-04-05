package main

import (
	"log"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	_ "github.com/emadolsky/automaxprocs"
)

var build = "develop"

func main() {
	g := runtime.GOMAXPROCS(0)

	log.Printf("starting service build[%s] CPU[%d]", build, g)
	defer log.Println("service stopped")

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)
	<-shutdown

	log.Println("stopping service")
}
