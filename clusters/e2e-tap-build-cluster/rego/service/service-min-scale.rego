package serviceminscale

violation[{"msg": msg}] {
  workloadMinScale := input.review.object.spec.template.metadata.annotations["autoscaling.knative.dev/minScale"]
  minScale := to_number(workloadMinScale)
  minScaleMax := input.parameters.minScaleLimit
  minScale > minScaleMax
  msg := sprintf("Service sets autoscaling.knative.dev/minScale: %d which is higher than the allowable minScale of %d", [minScale, minScaleMax])
}