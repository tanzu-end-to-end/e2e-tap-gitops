package workloadminscale

autoscale_annotation := "autoscaling.knative.dev/minScale"

test_workload_minScale_1_not_violation {
  count(violation)==0 with input.parameters as { "minScaleLimit": 2 }
    with input.review.object as {"metadata": {"name": "foo", "annotations": {autoscale_annotation: "1"}}}
}

test_workload_minScale_not_set_not_violation {
  count(violation)==0 with input.parameters as { "minScaleLimit": 2 }
    with input.review.object as {"metadata": {"name": "foo"}}
}

test_workload_minScale_3_violation {
  count(violation)==1 with input.parameters as { "minScaleLimit": 2 }
    with input.review.object as {"metadata": {"name": "foo", "annotations": {autoscale_annotation: "3"}}}
}

test_workload_minScale_1_param_no_violation {
  count(violation)==0 with input.parameters as { "minScaleLimit": 2 }
    with input.review.object as {"metadata": {"name": "foo"}}
    with input.review.object.spec.params as [
      {"name": "annotations", "value": {autoscale_annotation: "1"}}
    ] 
}

test_workload_minScale_3_param_violation {
  count(violation)==1 with input.parameters as { "minScaleLimit": 2 }
    with input.review.object as {"metadata": {"name": "foo"}}
    with input.review.object.spec.params as [
      {"name": "annotations", "value": {autoscale_annotation: "3"}}
    ] 
}