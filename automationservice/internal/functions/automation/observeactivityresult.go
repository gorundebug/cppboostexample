package automation

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ObserveActivityResult)(nil)

// ObserveActivityResult
type ObserveActivityResult struct{}

func (f *ObserveActivityResult) Map(_ context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	//TODO: Need to be implemented
	// Preserve the result returned through the on-demand Activity endpoint.
}

// MakeObserveActivityResult is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeObserveActivityResult(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ObserveActivityResult, error) {
	return &ObserveActivityResult{}, nil
}
