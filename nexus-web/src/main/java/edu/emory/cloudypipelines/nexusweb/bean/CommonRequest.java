package edu.emory.cloudypipelines.nexusweb.bean;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiParam;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.io.Serializable;

@ApiModel(description = "Common workflow submission requests")
@Getter
@Setter
@NoArgsConstructor
@ToString
public class CommonRequest implements Serializable {

    @ApiParam(required = true, allowEmptyValue = false)
    private String email;

    @ApiParam(required = true, allowEmptyValue = false)
    private String label = "";

    @ApiParam(required = true, allowEmptyValue = false, defaultValue = "PREEMPTIBLE_STANDARD_ATTEMPT_BOTH")
    private PreemptibleOption preemptibleOption = PreemptibleOption.PREEMPTIBLE_STANDARD_ATTEMPT_BOTH;

    @ApiParam(required = true, allowEmptyValue = false)
    private String project;

    @ApiParam(required = true, allowEmptyValue = false, defaultValue = "WDL")
    private WorkflowType workflowType = WorkflowType.WDL;

    @ApiParam(required = true, allowEmptyValue = false, defaultValue = "24")
    private String runningHoursAllowed = "24";
/**
 @ApiParam( required = true,
 allowEmptyValue = false,
 value = "WDL or CWL file",
 name = "workflowSource")
 private MultipartFile workflowSource;

 @ApiParam( required = true,
 allowEmptyValue = false,
 name = "workflowInputs",
 value = "JSON or YAML file containing inputs as an array of objects"
 )
 private MultipartFile workflowInputs;
 */
}
