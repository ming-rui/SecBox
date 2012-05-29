package sjtu.edu.cn.se.cloudbackup.ui;

import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JTree;
import javax.swing.tree.TreePath;

public class FileMouseListener extends MouseAdapter{
	public void mousePressed(MouseEvent e) {

	}

	public void mouseRleased(MouseEvent e) {
	}

	public void mouseEntered(MouseEvent e) {
	}

	public void mouseExited(MouseEvent e) {
	}

	public void mouseClicked(MouseEvent e) {
		
		JTree tree = (JTree) e.getSource();
		//int selRow = tree.getRowForLocation(e.getX(), e.getY());
        TreePath selPath = tree.getPathForLocation(e.getX(), e.getY());
        if(tree.isExpanded(selPath))
        	tree.collapsePath(selPath);
        else
        	tree.expandPath(selPath);
        /*if(selRow != -1) {
            if(e.getClickCount() == 1) { 
                System.out.println(toFilePath(selPath.toString()));
            }else if(e.getClickCount()==2){
            	
            }
        }*/
	}
	/*
	 * 对路径路径进行连接;(已经获得了所有的整个路径,需要量转化)
	 */
    public String toFilePath(String str){
    	//先去掉头尾的[];
    	String pa=str.substring(1, str.length()-1);
    	String[] temp=pa.split(", ");
    	String path="";
    	for(int i=1;i<temp.length;i++){
    		path+=temp[i];
    	}
    	return path;
    }
   
   
}
