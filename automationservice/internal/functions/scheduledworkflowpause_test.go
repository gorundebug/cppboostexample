package functions

import (
	"context"
	"testing"
	"time"

	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/stretchr/testify/assert"
)

// Use the official Temporal Workflow timer for a scheduled Workflow.

func TestScheduledWorkflowPause_Duration(t *testing.T) {
	f := &ScheduledWorkflowPause{}
	stream := &automationDelayStream{cfg: &runtimecfg.DelayStreamConfig{Duration: 35}}
	result := f.Duration(context.Background(), stream, "job")
	assert.Equal(t, 35*time.Millisecond, result)
}

func TestScheduledWorkflowPause_DelayError(t *testing.T) {
	f := &ScheduledWorkflowPause{}
	f.DelayError(context.Background(), nil, "job", context.DeadlineExceeded, nil)
}
