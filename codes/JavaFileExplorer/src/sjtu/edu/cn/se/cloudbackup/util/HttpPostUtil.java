package sjtu.edu.cn.se.cloudbackup.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

public class HttpPostUtil {
	public static HttpResponse post(String url,List<NameValuePair> params) throws ClientProtocolException, IOException{
		HttpClient httpClient = new DefaultHttpClient();
		HttpPost httppost = new HttpPost(url);
		httppost.setEntity(new UrlEncodedFormEntity(params));
		
		return httpClient.execute(httppost);
	}
	
	public static JSONObject postReturnJson(String url, List<NameValuePair> params) throws ClientProtocolException, IOException, JSONException{
		HttpResponse response = post(url, params);
		
		BufferedReader reader = new BufferedReader(new InputStreamReader(response.getEntity().getContent(), "UTF-8"));
		String json = reader.readLine();
		
		JSONObject outcome = new JSONObject(json);
		return outcome;
	}
	
	public static HttpResponse postMulti(String url, List<NameValuePair> params, List<NameFilePair> files) throws ClientProtocolException, IOException{
		HttpPost httppost = new HttpPost(url);
		HttpClient httpClient = new DefaultHttpClient();
		MultipartEntity reqEntity = new MultipartEntity();
        
		for (NameValuePair n : params)
			reqEntity.addPart(n.getName(), new StringBody(n.getValue()));

		for (NameFilePair f : files)
			reqEntity.addPart(f.getName(), new FileBody(f.getFile()));
		
		httppost.setEntity(reqEntity);
		HttpResponse response = httpClient.execute(httppost);
		
		return response;
	}
	
	public static JSONObject postMultiReturnJSON(String url, List<NameValuePair> params, List<NameFilePair> files) throws UnsupportedEncodingException, IllegalStateException, IOException, JSONException{
		HttpResponse response = postMulti(url, params, files);
		
		BufferedReader reader = new BufferedReader(new InputStreamReader(response.getEntity().getContent(), "UTF-8"));
		String json = reader.readLine();
		
		JSONObject outcome = new JSONObject(json);
		return outcome;
	}
	
	public static class NameFilePair{
		private String name;
		private File file;
		
		public NameFilePair(String name, File file){
			this.name = name;
			this.file = file;
		}

		public String getName() {
			return name;
		}

		public void setName(String name) {
			this.name = name;
		}

		public File getFile() {
			return file;
		}

		public void setFile(File file) {
			this.file = file;
		}
	}
	
}
