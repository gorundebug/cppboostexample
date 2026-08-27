package activity

import (
	"context"

	temporalsink "github.com/gorundebug/servicelib/datasink/temporal"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsink.EndpointHandler[FanoutActivityCEndpointSinkHandlerState, string] = (*FanoutActivityCEndpointSink)(nil)

type FanoutActivityCEndpointSinkHandlerState struct{}

// FanoutActivityCEndpointSink controls application identity and lifecycle for submissions to the
// symmetric Temporal endpoint. Serialization and retries remain framework-owned.
type FanoutActivityCEndpointSink struct{}

func (ep *FanoutActivityCEndpointSink) GetMessageID(ctx context.Context, _ runtime.Stream, _ FanoutActivityCEndpointSinkHandlerState, _ string) string {
	if id, ok := runtime.StreamIdFromContext(ctx); ok {
		return id.GetID()
	}
	return ""
}

func (ep *FanoutActivityCEndpointSink) BeginRequest(ctx context.Context, _ runtime.Stream) (context.Context, FanoutActivityCEndpointSinkHandlerState) {
	return ctx, FanoutActivityCEndpointSinkHandlerState{}
}

func (ep *FanoutActivityCEndpointSink) EndRequest(_ context.Context, _ runtime.Stream, _ error, _ FanoutActivityCEndpointSinkHandlerState) {
}

func MakeFanoutActivityCEndpointSink(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*FanoutActivityCEndpointSink, error) {
	return &FanoutActivityCEndpointSink{}, nil
}
