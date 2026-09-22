#pragma once

#include <chrono>
#include <cstddef>
#include <memory>
#include <stdexcept>
#include <tuple>
#include <utility>
#include <vector>

#include <boost/asio/awaitable.hpp>

#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/common.hpp>
#include <servicelib/runtime/base.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <analyticsservice/internal/types/analytics_event.hpp>
#include <analyticsservice/internal/types/analytics_result.hpp>


namespace example::analytics_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct InvokeAnalyticsSubstream final {
  using Event = example::analytics_service::types::AnalyticsEvent;
  using Result = example::analytics_service::types::AnalyticsResult;

  explicit InvokeAnalyticsSubstream(
      std::shared_ptr<servicelib::ISubStream<Event, Result>> substream)
      : substream_(std::move(substream)) {}

  template <typename Output>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::analytics_service::types::AnalyticsEvent& value,
                  Output&& out) const {
    (void)stream;
    substream_->consume(
        std::move(context), servicelib::Payload<Event>::make(value),
        std::make_shared<servicelib::SubStreamCollectorFunc<Result>>(
            [&out](servicelib::MessageContext result_context,
                   const Result& result) {
              out.out(std::move(result_context), result);
              return true;
            }));
  }

 private:
  std::shared_ptr<servicelib::ISubStream<Event, Result>> substream_;
};

inline boost::asio::awaitable<std::unique_ptr<InvokeAnalyticsSubstream>> MakeInvokeAnalyticsSubstream(
    servicelib::Context context, servicelib::IServiceEnvironment& environment) {
  (void)context;
  (void)environment;

  throw std::logic_error(
      "InvokeAnalyticsSubstream must be constructed by "
      "Service::customMakersInit with the analyzeAnalyticsSubstream handle");
  co_return std::unique_ptr<InvokeAnalyticsSubstream>{};
}

}  // namespace example::analytics_service::functions
