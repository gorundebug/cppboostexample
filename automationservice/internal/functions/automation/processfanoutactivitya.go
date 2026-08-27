package automation

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ProcessFanoutActivityA)(nil)

// ProcessFanoutActivityA
type ProcessFanoutActivityA struct{}

func (f *ProcessFanoutActivityA) Map(_ context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	//TODO: Need to be implemented
	// Return Activity A's typed result before the Workflow Split.
}

// MakeProcessFanoutActivityA is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeProcessFanoutActivityA(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ProcessFanoutActivityA, error) {
	return &ProcessFanoutActivityA{}, nil
}
