package edu.emory.cloudypipelines.nexusweb.bean.generated;

import com.fasterxml.jackson.annotation.JsonProperty;
import javax.annotation.Generated;
import java.io.Serializable;

@Generated("com.robohorse.robopojogenerator")
public class TaskCInputDTO implements Serializable {

	@JsonProperty("wf_containerC.taskC.dataInput")
	private String wfContainerCTaskCDataInput;

	public void setWfContainerCTaskCDataInput(String wfContainerCTaskCDataInput){
		this.wfContainerCTaskCDataInput = wfContainerCTaskCDataInput;
	}

	public String getWfContainerCTaskCDataInput(){
		return wfContainerCTaskCDataInput;
	}

	@Override
 	public String toString(){
		return 
			"TaskCInputDTO{" + 
			"wf_containerC.taskC.dataInput = '" + wfContainerCTaskCDataInput + '\'' + 
			"}";
		}
}