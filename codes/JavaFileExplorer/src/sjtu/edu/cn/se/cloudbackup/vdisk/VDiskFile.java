package sjtu.edu.cn.se.cloudbackup.vdisk;

import org.json.JSONException;
import org.json.JSONObject;

import sjtu.edu.cn.se.cloudbackup.util.CodingUtil;

public class VDiskFile {
	public static final String J_ID = "id";
	public static final String J_FID = "fid";
	public static final String J_NAME = "name";
	public static final String J_DIRID = "dir_id";
	public static final String J_CTIME = "ctime";
	public static final String J_LTIME = "ltime";
	public static final String J_SIZE = "size";
	public static final String J_TYPE = "type";
	public static final String J_URL = "url";
	public static final String J_S3_URL = "s3_url";
	
	private String id;
	private String name;
	private String dirId;
	private String cTime;
	private String lTime;
	private String size;
	private String type;
	private String url;
	private String s3_url;
	
	public VDiskFile(){	}
	
	public VDiskFile(String id, String name, String dirId, String cTime, String lTime, String size, String type, String url, String s3_url){
		this.id = id;
		this.name = name;
		this.dirId = "0";
		this.cTime = cTime;
		this.lTime = lTime;
		this.size = size;
		this.type = type;
		this.url = url;
		this.s3_url = s3_url;
	}
	
	public VDiskFile(JSONObject object){
		try {
			this.id = object.isNull(J_ID) ? object.getString(J_FID) : object.getString(J_ID);
			this.name = object.getString(J_NAME);
			this.dirId = "0";
			this.cTime = object.getString(J_CTIME);
			this.lTime = object.getString(J_LTIME);
			this.size = object.getString(J_SIZE);
			this.type = object.getString(J_TYPE);
			this.url = object.getString(J_URL);
			if (!object.isNull(J_S3_URL)) this.s3_url = object.getString(J_S3_URL);
		} catch (JSONException e) {	}
	}
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getDirId() {
		return dirId;
	}
	public void setDirId(String dirId) {
		this.dirId = dirId;
	}
	public String getcTime() {
		return cTime;
	}
	public void setcTime(String cTime) {
		this.cTime = cTime;
	}
	public String getlTime() {
		return lTime;
	}
	public void setlTime(String lTime) {
		this.lTime = lTime;
	}
	public String getSize() {
		return size;
	}
	public void setSize(String size) {
		this.size = size;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}

	public String getS3_url() {
		return s3_url;
	}

	public void setS3_url(String s3_url) {
		this.s3_url = s3_url;
	}
	
	public String getName(String key){
		String fName = this.getName().replace("[", "").split("\\]")[2];
		return CodingUtil.decodeString(key, fName);
	}
}
