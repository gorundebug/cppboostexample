package functions

import (
	"context"
	"testing"
	"time"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Suspend a DurableCall through a Temporal timer, then resume the pipeline without occupying an Activity slot.

type durablePauseStream struct {
	cfg *runtimecfg.DelayStreamConfig
}

func (s *durablePauseStream) GetName() string                                { return "Durable Pause" }
func (s *durablePauseStream) GetTransformationName() string                  { return "Delay" }
func (s *durablePauseStream) GetTypeName() string                            { return "string" }
func (s *durablePauseStream) GetID() int                                     { return 1 }
func (s *durablePauseStream) GetConfig() runtimecfg.StreamConfig             { return s.cfg }
func (s *durablePauseStream) GetEnvironment() environment.ServiceEnvironment { return nil }

func TestDurablePause_Duration(t *testing.T) {
	f := &DurablePause{}
	stream := &durablePauseStream{cfg: &runtimecfg.DelayStreamConfig{Duration: 250}}
	result := f.Duration(context.Background(), stream, "job")
	assert.Equal(t, 250*time.Millisecond, result)
}

func TestDurablePause_DelayError(t *testing.T) {
	f := &DurablePause{}
	durable := runtime.NewDurableCallContext("test", nil, nil)
	err := runtime.RunDurableCallActivity(context.Background(), durable, func(ctx context.Context) error {
		f.DelayError(ctx, nil, "job", context.DeadlineExceeded, nil)
		return nil
	})
	require.ErrorIs(t, err, context.DeadlineExceeded)
}
