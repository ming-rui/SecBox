package sjtu.edu.cn.se.cloudbackup.ui;

//import java.awt.Component;

import javax.swing.ImageIcon;
//import javax.swing.JTree;
import javax.swing.tree.DefaultTreeCellRenderer;

public class FileTreeCellRenderer extends DefaultTreeCellRenderer {

	/**
	 * 
	 */
	private static final long serialVersionUID = 5980884274273876530L;

	public FileTreeCellRenderer() {
		super();
		setFileClosedIcon();
		setFileOpenIcon();
		setFileLeftIcon();
	}

	public void setFileOpenIcon() {
		setOpenIcon(new ImageIcon(getClass().getResource("images/icon_folderopen.gif")));
	}

	public void setFileClosedIcon() {
		setClosedIcon(new ImageIcon(getClass().getResource(
				"images/icon_folder.gif")));
	}

	public void setFileLeftIcon() {
        setLeafIcon(new ImageIcon(getClass().getResource("images/htmlIcon.gif")));
	}
	
}
