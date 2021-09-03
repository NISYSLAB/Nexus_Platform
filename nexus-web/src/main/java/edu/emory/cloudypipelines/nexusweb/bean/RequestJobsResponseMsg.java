package edu.emory.cloudypipelines.nexusweb.bean;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class RequestJobsResponseMsg {
    private String requestId;

    @JsonProperty("jobs")
    private List<CPJobStatus> jobStatusList;
}
