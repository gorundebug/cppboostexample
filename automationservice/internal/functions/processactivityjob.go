package functions

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ProcessActivityJob)(nil)

// ProcessActivityJob
type ProcessActivityJob struct{}

func (f *ProcessActivityJob) Map(ctx context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	_ = runtime.DurableCallHeartbeat(ctx, "processing:"+value)
	out.Out(ctx, "activity:processed:"+value)
}

// MakeProcessActivityJob is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeProcessActivityJob(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ProcessActivityJob, error) {
	return &ProcessActivityJob{}, nil
}
