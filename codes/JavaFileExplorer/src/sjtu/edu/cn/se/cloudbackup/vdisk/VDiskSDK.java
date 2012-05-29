package sjtu.edu.cn.se.cloudbackup.vdisk;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sjtu.edu.cn.se.cloudbackup.util.HashUtils;
import sjtu.edu.cn.se.cloudbackup.util.HttpPostUtil;
import sjtu.edu.cn.se.cloudbackup.util.HttpPostUtil.NameFilePair;

public class VDiskSDK {
	public static final String P_ACCOUNT = "account"; 
	public static final String P_PASSWORD = "password"; 
	public static final String P_APPKEY = "appkey"; 
	public static final String P_SECRETKEY = "secretKey"; 
	public static final String P_APPTYPE = "app_type"; 
	public static final String P_SIGNITURE = "signature";
	public static final String P_TIME = "time";
	public static final String P_TOKEN = "token";
	public static final String P_DIRID = "dir_id";
	public static final String P_COVER = "cover";
	public static final String P_DOLOGID = "dologid";
	public static final String P_FILE = "file";
	public static final String P_FILE_ID = "fid";
	
	public static final String J_DATA = "data";
	public static final String J_TOKEN = "token";
	public static final String J_DOLOGID = "dologid";
	public static final String J_DATA_LIST = "list";
	
	public static final String URL_GET_TOKEN = "http://openapi.vdisk.me/?m=auth&a=get_token";
	public static final String URL_KEEP_TOKEN = "http://openapi.vdisk.me/?m=user&a=keep_token";
	public static final String URL_LIST = "http://openapi.vdisk.me/?m=dir&a=getlist";
	public static final String URL_UPLOAD = "http://openapi.vdisk.me/?m=file&a=upload_file";
	public static final String URL_GET_FILE = "http://openapi.vdisk.me/?m=file&a=get_file_info";
	public static final String URL_DEL_FILE = "http://openapi.vdisk.me/?m=file&a=delete_file";
	
	public static final String VALUE_YES = "yes";
	public static final String VALUE_NO = "no";
	public static final String VALUE_APPTYPE = "local"; 
	public static final String VALUE_ACCOUNT = "skwwt@163.com";
	public static final String VALUE_PASSWORD = "57377128137";
	public static final String VALUE_APPKEY = "205311130";
	public static final String VALUE_SECRETKEY = "af7b57c124dae7a4d89b8d56222f9d22";
	public static final String VALUE_ROOT_DIR_ID = "0";
	
	private String account = VALUE_ACCOUNT;
	private String password = VALUE_PASSWORD;
	private String appkey = VALUE_APPKEY;
	private String secretKey = VALUE_SECRETKEY;
	private String token = null;
	private String dologid = null;
	
	public VDiskSDK(String account, String password,String appkey, String secretKey){
		this.account = account;
		this.password = password;
		this.appkey = appkey;
		this.secretKey = secretKey;
	}
	
	public VDiskSDK(){}
	
	public void init() throws ClientProtocolException, IOException, JSONException{
		getToken();
		keepToken();
	}
	
	public String getToken() throws ClientProtocolException, IOException, JSONException{
		if (token != null) return token;
		
		String nowTime = String.valueOf(System.currentTimeMillis() /1000);
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair(P_ACCOUNT, account));
		params.add(new BasicNameValuePair(P_PASSWORD, password));
		params.add(new BasicNameValuePair(P_APPKEY, appkey));
		params.add(new BasicNameValuePair(P_TIME, nowTime));

		String data = VDiskSDK.P_ACCOUNT + "=" + account + "&" +
				VDiskSDK.P_APPKEY + "=" + appkey + "&" +
				VDiskSDK.P_PASSWORD + "=" + password + "&" +
				VDiskSDK.P_TIME + "=" + nowTime;
		params.add(new BasicNameValuePair(P_SIGNITURE, HashUtils.hmacSHA256(secretKey, data)));
		params.add(new BasicNameValuePair(P_APPTYPE, VALUE_APPTYPE));
		
		JSONObject object = HttpPostUtil.postReturnJson(URL_GET_TOKEN, params);
		token = object.getJSONObject(J_DATA).getString(J_TOKEN);
		return token;
	}
	
	public void keepToken() throws ClientProtocolException, IOException, JSONException{
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair(P_TOKEN, token));
		
		JSONObject object = HttpPostUtil.postReturnJson(URL_KEEP_TOKEN, params);
		dologid = String.valueOf(object.getInt(J_DOLOGID));
	}
	
	public String getDologid() throws ClientProtocolException, IOException, JSONException{
		if (dologid != null) return dologid;
		
		keepToken();
		
		return dologid;
	}
	
	public List<VDiskFile> listAll() throws ClientProtocolException, IOException, JSONException{
		List<VDiskFile> outcome = new ArrayList<VDiskFile>();
		
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair(P_TOKEN, token));
		params.add(new BasicNameValuePair(P_DIRID, VALUE_ROOT_DIR_ID));
		JSONObject object = HttpPostUtil.postReturnJson(URL_LIST, params);
		dologid = String.valueOf(object.getInt(J_DOLOGID));
		
		JSONArray array = object.getJSONObject(J_DATA).getJSONArray(J_DATA_LIST);
		for (int i = 0; i < array.length(); ++i){
			JSONObject o = (JSONObject)array.get(i);
			outcome.add(new VDiskFile(o));
		}
		
		return outcome;
	}
	
	public VDiskFile getFileById(String fid) throws ClientProtocolException, IOException, JSONException{
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		
		params.add(new BasicNameValuePair(P_TOKEN, token));
		params.add(new BasicNameValuePair(P_DOLOGID, getDologid()));
		params.add(new BasicNameValuePair(P_FILE_ID, fid));
		
		JSONObject object = HttpPostUtil.postReturnJson(URL_GET_FILE, params);
		dologid = String.valueOf(object.getInt(J_DOLOGID));
		
		return new VDiskFile(object.getJSONObject(J_DATA));
	}
	
	public VDiskFile uploadFile(File file) throws ClientProtocolException, IOException, JSONException{
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		List<NameFilePair> files = new ArrayList<NameFilePair>();
		
		params.add(new BasicNameValuePair(P_TOKEN, token));
		params.add(new BasicNameValuePair(P_DIRID, VALUE_ROOT_DIR_ID));
		params.add(new BasicNameValuePair(P_COVER, VALUE_YES));
		params.add(new BasicNameValuePair(P_DOLOGID, getDologid()));
		
		files.add(new NameFilePair(P_FILE, file));
		
		JSONObject object = HttpPostUtil.postMultiReturnJSON(URL_UPLOAD, params, files);
		dologid = String.valueOf(object.getInt(J_DOLOGID));
		
		return new VDiskFile(object.getJSONObject(J_DATA));
	}
	
	public void deleteFile(String fid) throws ClientProtocolException, IOException, JSONException{
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair(P_TOKEN, token));
		params.add(new BasicNameValuePair(P_DOLOGID, getDologid()));
		params.add(new BasicNameValuePair(P_FILE_ID, fid));
		
		JSONObject object = HttpPostUtil.postReturnJson(URL_DEL_FILE, params);
		dologid = String.valueOf(object.getInt(J_DOLOGID));
	}
	
	public void downloadFile(String urlStr, String path) throws IOException {
		URL url = new URL(urlStr);
		URLConnection con = url.openConnection();
		
		InputStream is = con.getInputStream();
		OutputStream os = new FileOutputStream(path);
		
		byte[] bs = new byte[1024];
		int len;
		
		while ((len = is.read(bs)) != -1) {
			os.write(bs, 0, len);
		}
		
		os.close();
		is.close();
	}
}
