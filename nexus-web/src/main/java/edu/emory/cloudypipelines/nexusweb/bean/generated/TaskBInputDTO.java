package edu.emory.cloudypipelines.nexusweb.bean.generated;

import com.fasterxml.jackson.annotation.JsonProperty;
import javax.annotation.Generated;
import java.io.Serializable;

@Generated("com.robohorse.robopojogenerator")
public class TaskBInputDTO implements Serializable {

	@JsonProperty("wf_containerB.taskBFileTransfer.dataInputUrl")
	private String wfContainerBTaskBFileTransferDataInputUrl;

	public void setWfContainerBTaskBFileTransferDataInputUrl(String wfContainerBTaskBFileTransferDataInputUrl){
		this.wfContainerBTaskBFileTransferDataInputUrl = wfContainerBTaskBFileTransferDataInputUrl;
	}

	public String getWfContainerBTaskBFileTransferDataInputUrl(){
		return wfContainerBTaskBFileTransferDataInputUrl;
	}

	@Override
 	public String toString(){
		return 
			"TaskBInputDTO{" + 
			"wf_containerB.taskBFileTransfer.dataInputUrl = '" + wfContainerBTaskBFileTransferDataInputUrl + '\'' + 
			"}";
		}
}