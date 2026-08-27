package automation

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ProcessFanoutActivityC)(nil)

// ProcessFanoutActivityC
type ProcessFanoutActivityC struct{}

func (f *ProcessFanoutActivityC) Map(_ context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	//TODO: Need to be implemented
	// Return Activity C's typed fan-out result.
}

// MakeProcessFanoutActivityC is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeProcessFanoutActivityC(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ProcessFanoutActivityC, error) {
	return &ProcessFanoutActivityC{}, nil
}
