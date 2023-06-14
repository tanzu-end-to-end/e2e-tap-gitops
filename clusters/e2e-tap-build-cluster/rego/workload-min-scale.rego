package workloadminscale

autoscale_annotation := "autoscaling.knative.dev/minScale"

violation[{"msg": msg}] {
  workloadMinScale := input.review.object.metadata.annotations[autoscale_annotation]
  minScale := to_number(workloadMinScale)
  minScaleMax := input.parameters.minScale
  minScale > minScaleMax
  msg := sprintf("Workload sets autoscaling.knative.dev/minScale: %d which is higher than the allowable minScale of %d", [minScale, minScaleMax])
}

violation[{"msg": msg}] {
	minScaleStr := {minScale |
		param := input.review.object.spec.params[_]
		param.name == "annotations"
		minScale := param.value[autoscale_annotation]
	}
  
	minScale := to_number(minScaleStr[_])
  trace(sprintf("minScale: %s", [minScale]))
	minScaleMax := input.parameters.minScale
	minScale > minScaleMax
	msg := sprintf("Workload sets autoscaling.knative.dev/minScale: %d which is higher than the allowable minScale of %d", [minScale, minScaleMax])
}