package edu.emory.cloudypipelines.nexusweb.bean.generated;

import com.fasterxml.jackson.annotation.JsonProperty;
import javax.annotation.Generated;
import java.io.Serializable;

@Generated("com.robohorse.robopojogenerator")
public class TaskBInputDTO implements Serializable {

	@JsonProperty("wf_containerB.taskB.dataInput")
	private String wfContainerBTaskBDataInput;

	public void setWfContainerBTaskBDataInput(String wfContainerBTaskBDataInput){
		this.wfContainerBTaskBDataInput = wfContainerBTaskBDataInput;
	}

	public String getWfContainerBTaskBDataInput(){
		return wfContainerBTaskBDataInput;
	}

	@Override
 	public String toString(){
		return 
			"TaskBInputDTO{" + 
			"wf_containerB.taskB.dataInput = '" + wfContainerBTaskBDataInput + '\'' + 
			"}";
		}
}