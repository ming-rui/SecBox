package sjtu.edu.cn.se.cloudbackup.ui;

import java.util.Enumeration;

import javax.swing.event.TreeExpansionEvent;
import javax.swing.event.TreeWillExpandListener;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.TreePath;

public class ExpandListener implements TreeWillExpandListener {
	/*
	 * 树展开及收缩监听;
	 */
	private GUIFrame mainFrame = null;

	public ExpandListener(GUIFrame mainFrame) {
		this.mainFrame = mainFrame;
	}

	public void treeWillExpand(TreeExpansionEvent event) {
		// 对节点的路径进行转化,由[c:\, cattong, kdk]->c:\cattong\kdk;
		String path = toFilePath(event.getPath().toString());
		TreePath treePath = event.getPath();
		DefaultMutableTreeNode node = (DefaultMutableTreeNode) treePath
				.getLastPathComponent();
		//System.out.println("所展开节点的路径:" + path);
		//System.out.println("当前展开节点的深度:" + node.getDepth());
		if (node.getDepth() < 2) {
			Enumeration children = node.children();
			String filePath = "";
			while (children.hasMoreElements()) {
				DefaultMutableTreeNode temp = (DefaultMutableTreeNode) children
						.nextElement();
				filePath = "";
				filePath = path;
				if (!filePath.endsWith("\\"))
					filePath += "\\";
				filePath += temp.toString();
				// System.out.println("temp=" +filePath);
				mainFrame.addPrefetchChildren(filePath, temp);
			}
		}

	}

	public void treeWillCollapse(TreeExpansionEvent event) {

	}

	/*
	 * 对路径路径进行连接;(已经获得了所有的整个路径,需要量转化)
	 */
	public String toFilePath(String str) {
		// 先去掉头尾的[];
		String pa = str.substring(1, str.length() - 1);
		String[] temp = pa.split(", ");
		String path = "";
		for (int i = 1; i < temp.length; i++) {
			if (!path.endsWith("\\") && !path.equals(""))//不为空是为去根节点;
				path += "\\";
			path += temp[i];
		}
		return path;
	}

}
