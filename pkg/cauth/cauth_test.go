package cauth

import (
	"testing"
	"time"

	"github.com/tinkler/mqttadmin/pkg/logger"
)

func TestRunAndSendUpdateSignal(t *testing.T) {
	logger.ConsoleLevel = logger.LL_DEBUG
	updated := false
	defaultManager.updateFunc = func() {
		t.Log("set to true")
		updated = true
	}
	err := Run()
	if err != nil {
		t.Fatal(err)
	}
	go func() {
		for range time.NewTicker(time.Second).C {
			defaultManager.updateSignal <- struct{}{}
		}
	}()
	time.Sleep(9 * time.Second)
	if updated {
		t.Fail()
	}
	time.Sleep(3 * time.Second)
	if !updated {
		t.Log("still false")
		t.Fail()
	}
	updated = false
	err = Close()
	if err != nil {
		t.Fatal(err)
	}
	time.Sleep(10 * time.Second)
	if updated {
		t.Fail()
	}
}
