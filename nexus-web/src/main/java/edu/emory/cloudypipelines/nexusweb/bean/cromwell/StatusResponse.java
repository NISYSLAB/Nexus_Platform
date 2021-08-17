package edu.emory.cloudypipelines.nexusweb.bean.cromwell;


import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class StatusResponse {
    private String id = "";
    private String status = "";
}
