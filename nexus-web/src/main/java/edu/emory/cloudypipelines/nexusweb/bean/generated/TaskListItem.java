package edu.emory.cloudypipelines.nexusweb.bean.generated;

import com.fasterxml.jackson.annotation.JsonProperty;
import javax.annotation.Generated;
import java.io.Serializable;

@Generated("com.robohorse.robopojogenerator")
public class TaskListItem implements Serializable {

	@JsonProperty("name")
	private String name;

	@JsonProperty("index")
	private int index;

	@JsonProperty("preemptibleOption")
	private String preemptibleOption;

	@JsonProperty("project")
	private String project;

	@JsonProperty("runningHoursAllowed")
	private int runningHoursAllowed;

	@JsonProperty("workflowType")
	private String workflowType;

	@JsonProperty("wdlFilePath")
	private String wdlFilePath;

	@JsonProperty("inputFilePath")
	private String inputFilePath;

	public void setName(String name){
		this.name = name;
	}

	public String getName(){
		return name;
	}

	public void setIndex(int index){
		this.index = index;
	}

	public int getIndex(){
		return index;
	}

	public void setPreemptibleOption(String preemptibleOption){
		this.preemptibleOption = preemptibleOption;
	}

	public String getPreemptibleOption(){
		return preemptibleOption;
	}

	public void setProject(String project){
		this.project = project;
	}

	public String getProject(){
		return project;
	}

	public void setRunningHoursAllowed(int runningHoursAllowed){
		this.runningHoursAllowed = runningHoursAllowed;
	}

	public int getRunningHoursAllowed(){
		return runningHoursAllowed;
	}

	public void setWorkflowType(String workflowType){
		this.workflowType = workflowType;
	}

	public String getWorkflowType(){
		return workflowType;
	}

	public void setWdlFilePath(String wdlFilePath){
		this.wdlFilePath = wdlFilePath;
	}

	public String getWdlFilePath(){
		return wdlFilePath;
	}

	public void setInputFilePath(String inputFilePath){
		this.inputFilePath = inputFilePath;
	}

	public String getInputFilePath(){
		return inputFilePath;
	}

	@Override
 	public String toString(){
		return 
			"TaskListItem{" + 
			"name = '" + name + '\'' + 
			",index = '" + index + '\'' + 
			",preemptibleOption = '" + preemptibleOption + '\'' + 
			",project = '" + project + '\'' + 
			",runningHoursAllowed = '" + runningHoursAllowed + '\'' + 
			",workflowType = '" + workflowType + '\'' + 
			",wdlFilePath = '" + wdlFilePath + '\'' + 
			",inputFilePath = '" + inputFilePath + '\'' + 
			"}";
		}
}