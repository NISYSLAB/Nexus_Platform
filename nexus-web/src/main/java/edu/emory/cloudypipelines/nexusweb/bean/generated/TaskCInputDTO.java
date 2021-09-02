package edu.emory.cloudypipelines.nexusweb.bean.generated;

import com.fasterxml.jackson.annotation.JsonProperty;
import javax.annotation.Generated;
import java.io.Serializable;

@Generated("com.robohorse.robopojogenerator")
public class TaskCInputDTO implements Serializable {

	@JsonProperty("wf_containerC.taskCFileTransfer.dataInputUrl")
	private String wfContainerCTaskCFileTransferDataInputUrl;

	public void setWfContainerCTaskCFileTransferDataInputUrl(String wfContainerCTaskCFileTransferDataInputUrl){
		this.wfContainerCTaskCFileTransferDataInputUrl = wfContainerCTaskCFileTransferDataInputUrl;
	}

	public String getWfContainerCTaskCFileTransferDataInputUrl(){
		return wfContainerCTaskCFileTransferDataInputUrl;
	}

	@Override
 	public String toString(){
		return 
			"TaskCInputDTO{" + 
			"wf_containerC.taskCFileTransfer.dataInputUrl = '" + wfContainerCTaskCFileTransferDataInputUrl + '\'' + 
			"}";
		}
}