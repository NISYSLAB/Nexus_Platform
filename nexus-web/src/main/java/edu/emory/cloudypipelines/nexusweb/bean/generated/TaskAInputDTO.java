package edu.emory.cloudypipelines.nexusweb.bean.generated;

import com.fasterxml.jackson.annotation.JsonProperty;
import javax.annotation.Generated;
import java.io.Serializable;

@Generated("com.robohorse.robopojogenerator")
public class TaskAInputDTO implements Serializable {

	@JsonProperty("wf_containerA.taskA.dataInput")
	private String wfContainerATaskADataInput;

	public void setWfContainerATaskADataInput(String wfContainerATaskADataInput){
		this.wfContainerATaskADataInput = wfContainerATaskADataInput;
	}

	public String getWfContainerATaskADataInput(){
		return wfContainerATaskADataInput;
	}

	@Override
 	public String toString(){
		return 
			"TaskAInputDTO{" + 
			"wf_containerA.taskA.dataInput = '" + wfContainerATaskADataInput + '\'' + 
			"}";
		}
}