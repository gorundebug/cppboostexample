package functions

import (
	"context"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.MapFunction[string, string] = (*ProcessSequentialActivityA)(nil)

// ProcessSequentialActivityA
type ProcessSequentialActivityA struct{}

func (f *ProcessSequentialActivityA) Map(ctx context.Context, _ runtime.Stream, value string, out runtime.Collect[string]) {
	out.Out(ctx, "sequential:a:"+value)
}

// MakeProcessSequentialActivityA is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeProcessSequentialActivityA(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.MapStreamConfig) (*ProcessSequentialActivityA, error) {
	return &ProcessSequentialActivityA{}, nil
}
