package sjtu.edu.cn.se.cloudbackup.ui;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.http.client.ClientProtocolException;
import org.json.JSONException;

import sjtu.edu.cn.se.cloudbackup.vdisk.VDiskFile;
import sjtu.edu.cn.se.cloudbackup.vdisk.VDiskFileSystem;


public class Command {
	private String currentPath;
	private VDiskFileSystem fSystem;

	private IDisplayable mainFrame = null;

	private final String cmd[] = { "cd", "dir", "md", "rd", "edit", "del",
			"exit", "update", "update -cloud", "update -client", "del -cloud" };

	private final int cmdInt[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 };

	Command(IDisplayable mainFrame) {
		currentPath = "C:";
		this.mainFrame = mainFrame;
		this.fSystem = new VDiskFileSystem("wutong", "mumubaba");
	}

	/**
	 * 函数运行入口;
	 * 
	 * public static void main(String[] args) {
	 * 
	 * Command cmd = new Command(); System.out.println("当前的所有盘符:");
	 * cmd.ListDisks(); System.out.print(cmd.getPath()); // 读取用户的命令和数据; while
	 * (true) { byte[] b = new byte[50]; try { System.in.read(b);
	 * cmd.operate(new String(b).trim()); } catch (IOException e) {
	 * e.printStackTrace(); } }
	 *  }
	 */
	/*
	 * 显示系统中的所有盘符;
	 */
	public String[] ListDisks() {
		File roots[] = File.listRoots();// 根盘符;
		String disks[] = new String[roots.length];
		for (int i = 0; i < roots.length; i++) {
			disks[i] = roots[i].toString();
		}
		return disks;
	}

	public String[] separate(String operation) {
		String[] str = operation.split(" ");// 按分号分割;
		//主要解决文件夹或文件中含有空格的情况;
		if(str.length>2){
			String[] tempStr=new String[2];
			tempStr[0]=str[0];
			tempStr[1]=str[1];
			for(int i=2;i<str.length;i++)
				tempStr[1]+=" "+str[i];
			return tempStr;
		}
		return str;
	}

	/*
	 * 根据参数operation执行相应的操作;
	 */
	public void operate(String operation) {
		String[] str = separate(operation);
		// System.out.println(str.length);
		String mycmd = "";
		// mycmd对应的整数代号;
		int mycmdInt = 0;
		String path = "";
		if (str.length == 1) {
			mycmd = str[0];
			if (mycmd.indexOf(":") != -1) {// 如果是直接盘符转换;执行些操作;
				File newFile = new File(mycmd);
				if (newFile.exists()) {
					currentPath = mycmd;
					// System.out.print(getPath());
					mainFrame.display(getPath());
					return;
				}
			}
		}
		if (str.length >= 2) {
			mycmd = str[0];
			path = str[1];
		}
		// 选择执行命令;
		// ///System.out.println(mycmd+"\\"+path);
		for (int i = 0; i < cmd.length; i++) {
			if (mycmd.equalsIgnoreCase(cmd[i])) {
				mycmdInt = cmdInt[i];
			}
		}
		switch (mycmdInt) {
		case 1:
			cd(currentPath, path);
			break;
		case 2:
			dir(currentPath);
			break;
		case 3:
			md(path);
			break;
		case 4:
			rd(path);
			break;
		case 5:
			edit(path);
			break;
		case 6:
			if(path.startsWith("-cloud")) delCloud(path.replace("-cloud", "").trim());
			else del(path);
			break;
		case 7:
			exit();
			break;
		case 8:
			if(path.startsWith("-cloud")) updateCloud();
			else if(path.startsWith("-client")) updateClient();
			else update();
			break;
		default:
			mainFrame.display("无效的命令!");
		}
		mainFrame.display(getPath());
	}

	/*
	 * 获得当前所在目录;
	 */
	public String getPath() {
		return currentPath + ">";
	}

	/*
	 * 获得路径path下的文件;
	 */
	public String[] listAll(String path) {
		
		try {
			File f = new File(path);
			File[] files;
			if (f.isDirectory()) {
				files = f.listFiles();
				mainFrame.display("共有" + files.length + "个文件");
				for (int i = 0; i < files.length; i++)
					mainFrame.display("    " + files[i].getName() + "\t\t\t" + new Date(files[i].lastModified()).toGMTString());
				return f.list();
			} else if (f.isFile()) {
				mainFrame.display("这是一个文件");
				return null;
			} else {
				//System.out.println(path);
				return null;
			}
		} catch (Exception e) {
			return null;
		}
	}
    public String[] listDirectory(String path){
    	File f = new File(path);
		String[] fileName;
		if (f.isDirectory()) {
			fileName = f.list();
			//for (int i = 0; i < fileName.length; i++)
				//System.out.println("/"+fileName[i]);
			return fileName;
		} else {
			//System.out.println(path+"是文件");
			return null;
		}
    }
	/*
	 * 判断这个路径是否正确;
	 */
	public boolean isRightPath(String path) {
		File file = new File(path);
		if (file.isDirectory() || file.isFile())
			return true;
		else
			return false;
	}

	/*
	 * 进行cd操作;cd<目录名> 功能:进入下一个目录;
	 */
	public void cd(String path, String file) {
		String[] paths = path.split("\\\\");
		List<String> pList = new ArrayList<String>();
		for (String s : paths)
			pList.add(s);
		
		boolean back = false;
		while(file.startsWith("..\\")){
			back = true;
			if (pList.size() < 2) {
				mainFrame.display("没有找到这个文件夹");
				return;
			}
			
			file = file.substring(3);
			pList = pList.subList(0, pList.size() - 1);
		}
		if (paths.length > 0){
			path = "";
			for (String s : pList){
				path += s + "\\";
			}
		}else path += "\\";
		
		String temp = path + file;
		if (!isRightPath(temp)) {
			mainFrame.display("没有找到这个文件夹");
		} else {
			if (!file.equals(""))
				currentPath = temp;//+= "\\" + file;
			else if (back){
				currentPath = temp;
			}
		}
	}

	/*
	 * 进行dir操作;dir [<目录名>] 功能: 显示目录下的所有文件;
	 */
	public void dir(String path) {
		if (path != null)
			listAll(path);
	}

	/*
	 * 进行md操作;md <目录名> 功能: 创建新目录
	 */
	public void md(String directory) {
		if (!currentPath.equals("")) {
			String temp = currentPath + "\\" + directory;
			File newFile = new File(temp);
			if (!newFile.exists()) {
				try {
					if (newFile.isDirectory() == false) {
						newFile.mkdirs();
						mainFrame.display("文件夹创建成功!");
					} else {
						mainFrame.display("文件夹创建出错!");
					}
				} catch (Exception e) {
					mainFrame.display("出错信息:" + e.getMessage());
				}
			} else {
				mainFrame.display("文件夹已经存在");
			}
		}
	}

	/*
	 * 进行rd操作;rd <目录名> 功能: 删除目录;
	 */
	public void rd(String directory) {
		if (!currentPath.equals("")) {
			String temp = currentPath + "\\" + directory;
			File file = new File(temp);
			if (file.exists()) {
				if (file.delete()) {
					mainFrame.display("文件夹删除成功!");
				} else {
					mainFrame.display("文件夹删除操作出错!");
				}
			} else {
				mainFrame.display("文件夹不存在");
			}
		}
	}

	/*
	 * 进行edit操作:edit <文件名> 功能: 新建文件
	 */
	public void edit(String file) {
		if (!currentPath.equals("")) {
			String temp = currentPath + "\\" + file;
			File newFile = new File(temp);
			if (newFile.exists()) {
				mainFrame.display("文件已经存在!");
			} else {
				try {
					newFile.createNewFile();
					mainFrame.display("文件创建成功!");
				} catch (Exception e) {
					mainFrame.display("文件创建失败:" + e.getMessage());
				}
			}
		}
	}

	/*
	 * 进行del操作;del <文件名> 功能:删除文件;
	 */
	public void del(String file) {
		if (!file.equals("")) {
			String temp = currentPath + "\\" + file;
			File dfile = new File(temp);
			if (dfile.exists()) {
				if (dfile.delete()) {
					mainFrame.display("文件删除成功!");
				} else {
					mainFrame.display("文件删除操作出错!");
				}
			} else {
				mainFrame.display("文件不存在");
			}
		}
	}

	public void delCloud(String file){
		try {
			fSystem.refresh();
			
			if (!file.equals("")) {
				String temp = currentPath + "\\" + file;
				File dfile = new File(temp);
				if (dfile.exists()) {
					if (dfile.delete()) {
						fSystem.deleteFile(dfile);
						fSystem.refresh();
						mainFrame.display("文件删除成功!");
					} else {
						mainFrame.display("文件删除操作出错!");
					}
				} else {
					mainFrame.display("文件不存在");
				}
			}
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
	}
	
	/*
	 * 进行exit操作; 功能:退出文件系统;
	 */
	public void exit() {
		mainFrame.display("退出系统");
		System.exit(1);
	}
	
	public void update(){
		try {
			fSystem.refresh();
			File director = new File(currentPath);
			List<VDiskFile> list = fSystem.list(currentPath);
			for (final File f : director.listFiles()){
				VDiskFile vf = fSystem.match(f);
				
				if (vf == null){
					mainFrame.display("上传文件 " + f.getName() + " 。。。");
					fSystem.newFile(f);
				}
//				else {
//					if(Long.parseLong(vf.getlTime()) - (f.lastModified() / 1000) > 10000){
//						System.out.println(vf.getlTime() + "," + f.lastModified() + "d");
//						System.out.print(Long.parseLong(vf.getlTime()) + "," + f.lastModified() / 1000);
//						mainFrame.display("下载文件 " + f.getName() + " 。。。");
//						fSystem.download(vf);
//					}
//					else if (Long.parseLong(vf.getlTime()) - (f.lastModified() / 1000) < -10000){
//						System.out.println(vf.getlTime() + "," + f.lastModified() + "u");
//						mainFrame.display("上传文件 " + f.getName() + " 。。。");
//						fSystem.newFile(f);
//					}
//				}
				
				if (vf != null){
					for (VDiskFile tf : list){
						if (tf.getId() == vf.getId()) tf.setDirId("tf");
					}
				}
			}
			
			for (VDiskFile tf : list){
				if (tf.getDirId() == "tf") continue;
				mainFrame.display("下载文件   " + tf.getName(this.fSystem.getPass()));
				fSystem.download(tf);
			}
			
			mainFrame.display("同步完成");
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}
	
	public void updateCloud(){
		try {
			fSystem.refresh();
		} catch (ClientProtocolException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (JSONException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		File p = new File(currentPath);
		
		for (File f : p.listFiles()){
			mainFrame.display("删除文件  " + f.getName() + "。。。");
			if (f.exists()) f.delete();
		}
		
		for (VDiskFile f : fSystem.list(currentPath)){
			try {
				fSystem.download(f);
				mainFrame.display("下载文件  " + f.getName() + "。。。");
			} 
			catch (ClientProtocolException e) {} 
			catch (IOException e) {} 
			catch (JSONException e) {}
		}
		
		mainFrame.display("同步完成");
	}
	
	public void updateClient(){
		try {
			fSystem.refresh();
		} catch (ClientProtocolException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (JSONException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		File p = new File(currentPath);
		
		for (VDiskFile f : fSystem.list(currentPath)){
			try {
				mainFrame.display("删除文件  " + f.getName() + "。。。");
				fSystem.deleteFile(f);
			} 
			catch (ClientProtocolException e) {} 
			catch (IOException e) {} 
			catch (JSONException e) {}
		}
		
		for (File f : p.listFiles()){
			mainFrame.display("上传文件  " + f.getName() + "。。。");
			try {
				fSystem.newFile(f);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		mainFrame.display("同步完成");
		
	}
}
