package functions

import (
	"context"
	"strings"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ProcessWorkflowJob)(nil)

// ProcessWorkflowJob
type ProcessWorkflowJob struct{}

func (f *ProcessWorkflowJob) Map(ctx context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	const continuedPrefix = "continued:"
	if !strings.HasPrefix(value, continuedPrefix) {
		runtime.TemporalContinueAsNew(ctx, continuedPrefix+value)
	}
	out.Out(ctx, "workflow:processed:"+strings.TrimPrefix(value, continuedPrefix))
}

// MakeProcessWorkflowJob is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeProcessWorkflowJob(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ProcessWorkflowJob, error) {
	return &ProcessWorkflowJob{}, nil
}
