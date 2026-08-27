package activity

import (
	"context"

	temporalsink "github.com/gorundebug/servicelib/datasink/temporal"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ temporalsink.EndpointHandler[FanoutActivityBEndpointSinkHandlerState, string] = (*FanoutActivityBEndpointSink)(nil)

type FanoutActivityBEndpointSinkHandlerState struct{}

// FanoutActivityBEndpointSink controls application identity and lifecycle for submissions to the
// symmetric Temporal endpoint. Serialization and retries remain framework-owned.
type FanoutActivityBEndpointSink struct{}

func (ep *FanoutActivityBEndpointSink) GetMessageID(ctx context.Context, _ runtime.Stream, _ FanoutActivityBEndpointSinkHandlerState, _ string) string {
	if id, ok := runtime.StreamIdFromContext(ctx); ok {
		return id.GetID()
	}
	return ""
}

func (ep *FanoutActivityBEndpointSink) BeginRequest(ctx context.Context, _ runtime.Stream) (context.Context, FanoutActivityBEndpointSinkHandlerState) {
	return ctx, FanoutActivityBEndpointSinkHandlerState{}
}

func (ep *FanoutActivityBEndpointSink) EndRequest(_ context.Context, _ runtime.Stream, _ error, _ FanoutActivityBEndpointSinkHandlerState) {
}

func MakeFanoutActivityBEndpointSink(_ context.Context, _ environment.ServiceEnvironment, _ *runtimecfg.TemporalEndpointConfig) (*FanoutActivityBEndpointSink, error) {
	return &FanoutActivityBEndpointSink{}, nil
}
