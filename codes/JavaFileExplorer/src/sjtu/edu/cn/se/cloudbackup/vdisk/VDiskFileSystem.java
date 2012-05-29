package sjtu.edu.cn.se.cloudbackup.vdisk;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.http.client.ClientProtocolException;
import org.json.JSONException;

import sjtu.edu.cn.se.cloudbackup.util.CodingUtil;

public class VDiskFileSystem {
	private VDiskSDK sdk;
	private String name;
	private String pass;
	private Map<String, VDiskFile> files = new HashMap<String, VDiskFile>();
	
	public VDiskFileSystem(String name, String pass, String account, String password,String appkey, String secretKey){
		sdk = new VDiskSDK(account, password, appkey, secretKey);
		try {
			sdk.init();
		} 
		catch (ClientProtocolException e) {} 
		catch (IOException e) {} 
		catch (JSONException e) {}
		this.name = name;
		this.pass = pass;
	}
	
	public VDiskFileSystem(String name, String pass){
		sdk = new VDiskSDK();
		try {
			sdk.init();
		} catch (ClientProtocolException e) {
		} catch (IOException e) {
		} catch (JSONException e) {
		}
		this.name = name;
		this.pass = pass;
	}
	
	public void refresh() throws ClientProtocolException, IOException, JSONException{
		List<VDiskFile> all = sdk.listAll();
		files.clear();
		
		for (VDiskFile f : all){
			String[] fileName = f.getName().replaceAll("\\]", "").split("\\[");
			if (fileName.length < 4) continue;
			if (fileName[2].equals(name))
				files.put(CodingUtil.decodeString(pass, fileName[3]), f);
		}
	}
	
//	public void update(File file) throws IOException, JSONException{
//		if (file.isFile()) return;
//		
//		for (File f : file.listFiles()){
//			VDiskFile vFile = match(f);
//			if (vFile != null) newFile(f);
//		}
//	}
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPass() {
		return pass;
	}

	public void setPass(String pass) {
		this.pass = pass;
	}

	public List<VDiskFile> list(String path){
		List<VDiskFile> outcome = new ArrayList<VDiskFile>();
		
		for (String n : files.keySet()){
			if (n.startsWith(path)) outcome.add(files.get(n));
		}
		
		return outcome;
	}
	
	public VDiskFile newFile(File file) throws IOException, JSONException{
		byte[] data = getBytesFromFile(file);
		data = CodingUtil.encode(pass, data);

		String fName = "[SecBox][" + name + "][" + CodingUtil.encodeString(pass, file.getAbsolutePath()) + "]";
		File newFile = getFileFromBytes(data, fName);
		
		VDiskFile f = sdk.uploadFile(newFile);
		if(newFile.exists()) newFile.deleteOnExit();
		
		String[] fileName = f.getName().replaceAll("\\]", "").split("\\[");
		if (fileName[2].equals(name))
			files.put(CodingUtil.decodeString(pass, fileName[3]), f);
		
		return f;
	}
	
	public void deleteFile(File file) throws ClientProtocolException, IOException, JSONException{
		VDiskFile vFile = match(file);
		
		if (vFile != null) {
			sdk.deleteFile(vFile.getId());
			files.remove(vFile);
		}
	}
	
	public void deleteFile(VDiskFile file) throws ClientProtocolException, IOException, JSONException{
		sdk.deleteFile(file.getId());
		files.remove(file);
	}
	
	public void download(VDiskFile file) throws ClientProtocolException, IOException, JSONException{
		if (file.getS3_url() == null || file.getS3_url().length() == 0){
			file = sdk.getFileById(file.getId());
		}
		
		String[] fileName = file.getName().replaceAll("\\]", "").split("\\[");
		if (fileName[2].equals(name))
		{
			File downFile = new File(file.getName());
			sdk.downloadFile(file.getS3_url(), file.getName());
			byte[] data = getBytesFromFile(downFile);
			data = CodingUtil.decode(pass, data);
			String fName = CodingUtil.decodeString(pass, fileName[3]);
			getFileFromBytes(data, fName);
			
			downFile.deleteOnExit();
		}
	}
	
	public VDiskFile match(File file){
		if (files.containsKey(file.getAbsolutePath()))
			return files.get(file.getAbsolutePath());
		
		return null;
	}
	
	public byte[] getBytesFromFile(File f) {
		if (f == null) {
			return null;
		}
		try {
			FileInputStream stream = new FileInputStream(f);
			ByteArrayOutputStream out = new ByteArrayOutputStream(1000);
			byte[] b = new byte[1024 * 1024];
			int n;
			while ((n = stream.read(b)) != -1)
				out.write(b, 0, n);
			stream.close();
			out.close();
			return out.toByteArray();
		} catch (IOException e) {
		}
		return null;
	}

	public static File getFileFromBytes(byte[] b, String outputFile) {
		BufferedOutputStream stream = null;
		File file = null;
		try {
			file = new File(outputFile);
			if (!file.exists()) file.createNewFile();
			FileOutputStream fstream = new FileOutputStream(file);
			stream = new BufferedOutputStream(fstream);
			stream.write(b);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (stream != null) {
				try {
					stream.close();
				} catch (IOException e1) {
					e1.printStackTrace();
				}
			}
		}
		return file;
	}
	
	public static void main(String[] args){
		File f = new File("d:\\asdf.pdf");
		VDiskFileSystem vs = new VDiskFileSystem("wutong", "880903");
		try {
			vs.refresh();
		} catch (ClientProtocolException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String s = vs.match(f).getName();
		System.out.print(s);
	}
}
