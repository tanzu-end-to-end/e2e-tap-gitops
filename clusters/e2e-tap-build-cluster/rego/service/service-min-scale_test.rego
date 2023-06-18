package serviceminscale

autoscale_annotation := "autoscaling.knative.dev/minScale"

test_service_minScale_1_not_violation {
  count(violation)==0 with input.parameters as { "minScaleLimit": 2 }
    with input.review.object.spec.template.metadata.annotations as {"autoscaling.knative.dev/minScale": "1"}
}

test_workload_minScale_not_set_not_violation {
  count(violation)==0 with input.parameters as { "minScaleLimit": 2 }
    with input.review.object.spec.template.metadata.annotations as {"foo": "bar"}
}

test_workload_minScale_3_violation {
  count(violation)==1 with input.parameters as { "minScaleLimit": 2 }
    with input.review.object.spec.template.metadata.annotations as {"autoscaling.knative.dev/minScale": "3"}
}