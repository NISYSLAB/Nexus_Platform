package edu.emory.cloudypipelines.nexusweb.bean.generated;

import java.util.List;
import com.fasterxml.jackson.annotation.JsonProperty;
import javax.annotation.Generated;
import java.io.Serializable;

@Generated("com.robohorse.robopojogenerator")
public class SubmissionConfig implements Serializable {

	@JsonProperty("email")
	private String email;

	@JsonProperty("label")
	private String label;

	@JsonProperty("dataInput")
	private String dataInput;

	@JsonProperty("taskList")
	private List<TaskListItem> taskList;

	public void setEmail(String email){
		this.email = email;
	}

	public String getEmail(){
		return email;
	}

	public void setLabel(String label){
		this.label = label;
	}

	public String getLabel(){
		return label;
	}

	public String getDataInput() {
		return dataInput;
	}

	public void setDataInput(String dataInput) {
		this.dataInput = dataInput;
	}

	public void setTaskList(List<TaskListItem> taskList){
		this.taskList = taskList;
	}

	public List<TaskListItem> getTaskList(){
		return taskList;
	}

	@Override
 	public String toString(){
		return 
			"SubmissionConfig{" + 
			"email = '" + email + '\'' + 
			",label = '" + label + '\'' + 
			",taskList = '" + taskList + '\'' + 
			"}";
		}
}