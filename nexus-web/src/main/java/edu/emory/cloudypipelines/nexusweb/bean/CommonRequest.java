package edu.emory.cloudypipelines.nexusweb.bean;

import java.io.Serializable;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class CommonRequest implements Serializable {
    private String email;
    private String label = "";
    private PreemptibleOption preemptibleOption = PreemptibleOption.PREEMPTIBLE_STANDARD_ATTEMPT_BOTH;
    private String project;
    private WorkflowType workflowType = WorkflowType.WDL;
    private String runningHoursAllowed = "24";
}
