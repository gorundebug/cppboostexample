package functions

import (
	"context"
	"testing"
	"time"

	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/stretchr/testify/assert"
)

// Apply the ordinary local Delay inside an Activity started by Temporal Schedule.

func TestScheduledActivityPause_Duration(t *testing.T) {
	f := &ScheduledActivityPause{}
	stream := &automationDelayStream{cfg: &runtimecfg.DelayStreamConfig{Duration: 30}}
	result := f.Duration(context.Background(), stream, "job")
	assert.Equal(t, 30*time.Millisecond, result)
}

func TestScheduledActivityPause_DelayError(t *testing.T) {
	f := &ScheduledActivityPause{}
	f.DelayError(context.Background(), nil, "job", context.DeadlineExceeded, nil)
}
