package edu.emory.cloudypipelines.nexusweb.bean;

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
    private List<CPJob> jobs;
}
