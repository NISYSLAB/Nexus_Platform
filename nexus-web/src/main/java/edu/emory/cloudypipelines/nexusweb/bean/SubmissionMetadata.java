package edu.emory.cloudypipelines.nexusweb.bean;


import edu.emory.cloudypipelines.nexusweb.db.entity.Task;
import edu.emory.cloudypipelines.nexusweb.db.entity.TaskHeader;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class SubmissionMetadata {
    private TaskHeader taskHeader;
    private List<Task> tasks;
}
