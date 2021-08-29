package edu.emory.cloudypipelines.nexusweb.bean;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class TaskSubmissionResponse {
    private UUID taskHeaderId;
    private String inputPath = "";
    List<TaskMetadata> taskMetadataList = new ArrayList<>();
}
