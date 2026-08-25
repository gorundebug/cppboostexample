package functions

import (
	"context"
	"time"

	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
	"github.com/gorundebug/servicelib/transformation"
)

var _ transformation.DelayFunction[string] = (*DurablePause)(nil)

// DurablePause
type DurablePause struct{}

func (f *DurablePause) Duration(_ context.Context, stream runtime.Stream, _ string) time.Duration {
	cfg := stream.GetConfig().(*runtimecfg.DelayStreamConfig)
	return time.Duration(cfg.Duration) * time.Millisecond
}

func (f *DurablePause) DelayError(ctx context.Context, _ runtime.Stream, _ string, delayErr error, _ runtime.Collect[string]) {
	if err := runtime.DurableCallError(ctx, delayErr); err != nil {
		panic(err)
	}
}

// MakeDurablePause is instantiated once at application startup via its maker function.
// Fields of this struct are not protected by any synchronization — do not use
// shared mutable state here without external synchronization.
func MakeDurablePause(ctx context.Context, env environment.ServiceEnvironment, cfg *runtimecfg.DelayStreamConfig) (*DurablePause, error) {
	return &DurablePause{}, nil
}
