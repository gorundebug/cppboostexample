package functions

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ProcessScheduledActivity)(nil)

// ProcessScheduledActivity
type ProcessScheduledActivity struct{}

func (f *ProcessScheduledActivity) Map(ctx context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	_ = runtime.DurableCallHeartbeat(ctx, "processing:"+value)
	out.Out(ctx, "activity:processed:"+value)
}

// MakeProcessScheduledActivity is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeProcessScheduledActivity(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ProcessScheduledActivity, error) {
	return &ProcessScheduledActivity{}, nil
}
