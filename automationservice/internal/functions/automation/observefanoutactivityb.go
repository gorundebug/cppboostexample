package automation

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ObserveFanoutActivityB)(nil)

// ObserveFanoutActivityB
type ObserveFanoutActivityB struct{}

func (f *ObserveFanoutActivityB) Map(_ context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	//TODO: Need to be implemented
	// Observe the typed result returned by the Activity B fan-out branch.
}

// MakeObserveFanoutActivityB is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeObserveFanoutActivityB(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ObserveFanoutActivityB, error) {
	return &ObserveFanoutActivityB{}, nil
}
