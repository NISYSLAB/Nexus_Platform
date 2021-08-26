package edu.emory.cloudypipelines.nexusweb.bean;


import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class TaskMetadata {
    private String groupUid = "";
    private String cromwellId = "";
    private int taskIndex = 0;
    private String taskName = "";
    private String taskStatus = "";
    private String taskOutput = "";
    private String taskProject = "";
}
