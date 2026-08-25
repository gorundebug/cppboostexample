package functions

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
	"time"
)

var _ transformation.DelayFunction[string] = (*ScheduledActivityPause)(nil)

// ScheduledActivityPause
type ScheduledActivityPause struct{}

func (f *ScheduledActivityPause) Duration(_ context.Context, stream runtime.Stream, value string) time.Duration {
	// Runtime invariant: Delay streams always have *runtimecfg.DelayStreamConfig.
	// Therefore the type assertion cannot fail.
	cfg := stream.GetConfig().(*runtimecfg.DelayStreamConfig)
	return time.Duration(cfg.Duration) * time.Millisecond
}

func (f *ScheduledActivityPause) DelayError(_ context.Context, _ runtime.Stream, _ string, _ error, _ runtime.Collect[string]) {
}

// MakeScheduledActivityPause is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeScheduledActivityPause(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.DelayStreamConfig) (*ScheduledActivityPause, error) {
	return &ScheduledActivityPause{}, nil
}
