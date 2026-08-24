package functions

import (
	"context"
	"fmt"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[runtime.ScheduleTrigger, string] = (*LocalJob)(nil)

// LocalJob
type LocalJob struct{}

func (f *LocalJob) Map(ctx context.Context, _ runtime.Stream, value runtime.ScheduleTrigger, out runtime.Collect[string]) {
	out.Out(ctx, fmt.Sprintf("local:%s:%s", value.ScheduleID, value.TriggerID))
}

// MakeLocalJob is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeLocalJob(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*LocalJob, error) {
	return &LocalJob{}, nil
}
