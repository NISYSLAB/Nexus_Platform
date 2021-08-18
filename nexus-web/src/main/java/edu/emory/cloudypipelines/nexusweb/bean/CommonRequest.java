package edu.emory.cloudypipelines.nexusweb.bean;

import java.io.Serializable;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import io.swagger.annotations.ApiParam;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.springframework.lang.NonNull;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

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

    @ApiModelProperty("PREEMPTIBLE_STANDARD_ATTEMPT_BOTH")
    @ApiParam(required = true, allowEmptyValue = false, defaultValue = "PREEMPTIBLE_STANDARD_ATTEMPT_BOTH")
    private PreemptibleOption preemptibleOption = PreemptibleOption.PREEMPTIBLE_STANDARD_ATTEMPT_BOTH;

    @ApiParam(required = true, allowEmptyValue = false)
    private String project;

    @ApiModelProperty("WDL")
    @ApiParam(required = true, allowEmptyValue = false, defaultValue = "WDL")
    private WorkflowType workflowType = WorkflowType.WDL;

    @ApiModelProperty("24")
    @ApiParam(required = true, allowEmptyValue = false, defaultValue = "24")
    private String runningHoursAllowed = "24";
}
