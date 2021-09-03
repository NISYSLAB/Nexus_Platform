package edu.emory.cloudypipelines.nexusweb.bean;


import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.ZonedDateTime;
import java.util.UUID;
import java.util.zip.ZipEntry;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class TaskMetadata {
    private UUID taskId;
    private int taskIndex = 0;
    private String taskName = "";
    private String project = "";
    private String cromwellId = "";
    private String requestId = "";
    private String processStatus = "";
    private ZonedDateTime timeSubmitted = null;
}
