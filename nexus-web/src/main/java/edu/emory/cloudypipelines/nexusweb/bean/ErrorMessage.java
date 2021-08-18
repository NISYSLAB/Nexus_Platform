package edu.emory.cloudypipelines.nexusweb.bean;


import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class ErrorMessage {
    private String status;
    private String message;
}
