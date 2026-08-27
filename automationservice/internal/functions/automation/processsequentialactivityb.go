package automation

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ProcessSequentialActivityB)(nil)

// ProcessSequentialActivityB
type ProcessSequentialActivityB struct{}

func (f *ProcessSequentialActivityB) Map(_ context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	//TODO: Need to be implemented
	// Return sequential Activity B's typed result to its Temporal sink.
}

// MakeProcessSequentialActivityB is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeProcessSequentialActivityB(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ProcessSequentialActivityB, error) {
	return &ProcessSequentialActivityB{}, nil
}
