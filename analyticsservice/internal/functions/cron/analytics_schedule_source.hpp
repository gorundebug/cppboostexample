#pragma once

#include <memory>
#include <utility>

#include <servicelib/runtime/common.hpp>
#include <servicelib/runtime/config/endpoint_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <servicelib/runtime/schedule.hpp>
#include <model_cpp/include/example/model/types/automation_job.hpp>


namespace example::analytics_service::functions {

struct AnalyticsScheduleSource final {
  template <typename Output>
  void operator()(servicelib::MessageContext context,
                  const servicelib::ScheduleTrigger& trigger,
                  Output&& out) const {
    std::forward<Output>(out).out(
        std::move(context),
        "analytics:" + trigger.scheduleId + ":" + trigger.triggerId);
  }
};

inline std::unique_ptr<AnalyticsScheduleSource> MakeAnalyticsScheduleSource(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::CronEndpointConfig& config) {
  (void)context;
  (void)config;
  (void)environment;
  return std::make_unique<AnalyticsScheduleSource>();
}

}  // namespace example::analytics_service::functions
