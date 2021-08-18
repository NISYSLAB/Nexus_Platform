package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class SystemCommandOutput {
    private String normalOutput;
    private String errorOutput;
}