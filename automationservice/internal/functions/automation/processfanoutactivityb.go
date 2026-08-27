package automation

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ProcessFanoutActivityB)(nil)

// ProcessFanoutActivityB
type ProcessFanoutActivityB struct{}

func (f *ProcessFanoutActivityB) Map(_ context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	//TODO: Need to be implemented
	// Return Activity B's typed fan-out result.
}

// MakeProcessFanoutActivityB is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeProcessFanoutActivityB(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ProcessFanoutActivityB, error) {
	return &ProcessFanoutActivityB{}, nil
}
