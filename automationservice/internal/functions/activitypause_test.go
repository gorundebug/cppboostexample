package functions

import (
	"context"
	"testing"
	"time"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/stretchr/testify/assert"
)

// Apply the ordinary local Delay while processing an on-demand Temporal Activity.

type automationDelayStream struct{ cfg *runtimecfg.DelayStreamConfig }

func (s *automationDelayStream) GetName() string                                { return "Automation delay" }
func (s *automationDelayStream) GetTransformationName() string                  { return "Delay" }
func (s *automationDelayStream) GetTypeName() string                            { return "string" }
func (s *automationDelayStream) GetID() int                                     { return 1 }
func (s *automationDelayStream) GetConfig() runtimecfg.StreamConfig             { return s.cfg }
func (s *automationDelayStream) GetEnvironment() environment.ServiceEnvironment { return nil }

func TestActivityPause_Duration(t *testing.T) {
	f := &ActivityPause{}
	stream := &automationDelayStream{cfg: &runtimecfg.DelayStreamConfig{Duration: 25}}
	result := f.Duration(context.Background(), stream, "job")
	assert.Equal(t, 25*time.Millisecond, result)
}

func TestActivityPause_DelayError(t *testing.T) {
	f := &ActivityPause{}
	f.DelayError(context.Background(), nil, "job", context.DeadlineExceeded, runtime.CollectFunc[string](func(context.Context, string) {
		t.Fatal("delay error must drop the value")
	}))
}
