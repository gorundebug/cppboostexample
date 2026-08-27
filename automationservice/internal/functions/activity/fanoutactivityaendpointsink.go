package activity

import (
	"context"

	temporalsink "github.com/gorundebug/servicelib/datasink/temporal"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsink.EndpointHandler[FanoutActivityAEndpointSinkHandlerState, string] = (*FanoutActivityAEndpointSink)(nil)

type FanoutActivityAEndpointSinkHandlerState struct{}

// FanoutActivityAEndpointSink controls application identity and lifecycle for submissions to the
// symmetric Temporal endpoint. Serialization and retries remain framework-owned.
type FanoutActivityAEndpointSink struct{}

func (ep *FanoutActivityAEndpointSink) GetMessageID(ctx context.Context, _ runtime.Stream, _ FanoutActivityAEndpointSinkHandlerState, _ string) string {
	if id, ok := runtime.StreamIdFromContext(ctx); ok {
		return id.GetID()
	}
	return ""
}

func (ep *FanoutActivityAEndpointSink) BeginRequest(ctx context.Context, _ runtime.Stream) (context.Context, FanoutActivityAEndpointSinkHandlerState) {
	return ctx, FanoutActivityAEndpointSinkHandlerState{}
}

func (ep *FanoutActivityAEndpointSink) EndRequest(_ context.Context, _ runtime.Stream, _ error, _ FanoutActivityAEndpointSinkHandlerState) {
}

func MakeFanoutActivityAEndpointSink(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*FanoutActivityAEndpointSink, error) {
	return &FanoutActivityAEndpointSink{}, nil
}
