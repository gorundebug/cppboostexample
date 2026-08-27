package automation

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

// Apply the ordinary local Delay inside an Activity started by Temporal Schedule.

func TestScheduledActivityPause_Duration(t *testing.T) {
	t.Skip("not yet implemented") // TODO: remove when implementation is ready
	f := &ScheduledActivityPause{}
	var value string
	// TODO: populate value with meaningful test data.
	// Note: if your implementation accesses stream.GetConfig(), pass a mock runtime.Stream instead of nil.
	result := f.Duration(context.Background(), nil, value)
	assert.GreaterOrEqual(t, result, time.Duration(0))
}

func TestScheduledActivityPause_DelayError(t *testing.T) {
	t.Skip("not yet implemented") // TODO: remove when implementation is ready
	f := &ScheduledActivityPause{}
	var value string
	// TODO: populate value with meaningful test data and verify whether the value is re-emitted or dropped.
	f.DelayError(context.Background(), nil, value, context.DeadlineExceeded, nil)
}
