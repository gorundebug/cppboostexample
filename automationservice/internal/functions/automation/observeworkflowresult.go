package automation

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ObserveWorkflowResult)(nil)

// ObserveWorkflowResult
type ObserveWorkflowResult struct{}

func (f *ObserveWorkflowResult) Map(_ context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	//TODO: Need to be implemented
	// Preserve the result returned through the on-demand Workflow endpoint.
}

// MakeObserveWorkflowResult is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeObserveWorkflowResult(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ObserveWorkflowResult, error) {
	return &ObserveWorkflowResult{}, nil
}
