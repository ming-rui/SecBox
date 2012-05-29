package sjtu.edu.cn.se.cloudbackup.ui;

import javax.swing.SwingUtilities;
import java.awt.BorderLayout;
import javax.swing.JPanel;
import javax.swing.JFrame;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Image;
import java.awt.Toolkit;
import javax.swing.JSplitPane;
import javax.swing.JTree;
import java.awt.Font;

import javax.swing.JMenuBar;
import javax.swing.JMenu;
import javax.swing.JMenuItem;
import javax.swing.JScrollPane;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import java.awt.FlowLayout;
import javax.swing.JLabel;
import javax.swing.JTextField;
import javax.swing.JTextArea;
import javax.swing.tree.DefaultMutableTreeNode;


import java.awt.event.KeyEvent;

public class GUIFrame extends JFrame implements IDisplayable{

	private static final long serialVersionUID = 1L;

	private JPanel jContentPane = null;

	private JSplitPane splitPane = null;

	private JTree fileTree = null;

	private FileMouseListener mouseListener = null;

	private ExpandListener expandListener = null;

	private JScrollPane treeScroll = null;

	private JMenuBar myMenuBar = null;

	private JMenu fileMenu = null;

	private JMenuItem exit = null;

	private JPanel rightPane = null;

	private JPanel cmdPane = null;

	private JLabel jLabel = null;

	private JTextField cmdText = null;

	private JTextArea echoArea = null;

	private JMenuItem restart = null;

	private JScrollPane areaScroll = null;

	private DefaultMutableTreeNode root = null;

	private Command cmd = null;

	/**
	 * This method initializes splitPane
	 * 
	 * @return javax.swing.JSplitPane
	 */
	private JSplitPane getSplitPane() {
		if (splitPane == null) {
			splitPane = new JSplitPane();
			splitPane.setDividerLocation(150);// 设置分格位置;
			splitPane.setDividerSize(5);// 设置分格条的宽度;
			splitPane.setFont(new Font("Dialog", Font.PLAIN, 14));
			splitPane.setToolTipText("文件系统界面");
			splitPane.setRightComponent(getRightPane());
			splitPane.setLeftComponent(getFileTree());// 设置右边的组件;
		}
		return splitPane;
	}

	/**
	 * This method initializes fileTree
	 * 
	 * @return javax.swing.JTree
	 */
	private JScrollPane getFileTree() {
		if (fileTree == null) {
			root = new DefaultMutableTreeNode("我的电脑");
			fileTree = new JTree(root);
			// 设置tree显示形式;
			FileTreeCellRenderer treeCell = new FileTreeCellRenderer();
			fileTree.setCellRenderer(treeCell);
			mouseListener = new FileMouseListener();// 添加树的监听器;
			fileTree.addMouseListener(mouseListener);
			expandListener = new ExpandListener(this);
			fileTree.addTreeWillExpandListener(expandListener);
			treeScroll = new JScrollPane();
			treeScroll.setViewportView(fileTree);
		}
		return treeScroll;
	}

	/**
	 * This method initializes myMenuBar
	 * 
	 * @return javax.swing.JMenuBar
	 */
	private JMenuBar getMyMenuBar() {
		if (myMenuBar == null) {
			myMenuBar = new JMenuBar();
			myMenuBar.setPreferredSize(new Dimension(13, 25));
			myMenuBar.add(getFileMenu());
		}
		return myMenuBar;
	}

	/**
	 * This method initializes fileMenu
	 * 
	 * @return javax.swing.JMenu
	 */
	private JMenu getFileMenu() {
		if (fileMenu == null) {
			fileMenu = new JMenu("文件");
			fileMenu.setFont(new Font("DialogInput", Font.BOLD, 12));
			fileMenu.add(getExit());
			fileMenu.add(getRestart());
			exit.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					if (e.getSource() == exit) {
						System.exit(0);
						System.out.println("退出");
					}
				}
			});
			restart.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					echoArea.setText("");
					echoArea.append(cmd.getPath()+"\n");
				}
			});

		}
		return fileMenu;
	}

	/**
	 * This method initializes exit
	 * 
	 * @return javax.swing.JMenuItem
	 */
	private JMenuItem getExit() {
		if (exit == null) {
			exit = new JMenuItem("退出");
		}
		return exit;
	}

	/**
	 * This method initializes rightPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getRightPane() {
		if (rightPane == null) {
			rightPane = new JPanel();
			rightPane.setLayout(new BorderLayout());
			rightPane.add(getCmdPane(), BorderLayout.NORTH);
			rightPane.add(getEchoArea(), BorderLayout.CENTER);
		}
		return rightPane;
	}

	/**
	 * This method initializes cmdPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getCmdPane() {
		if (cmdPane == null) {
			jLabel = new JLabel();
			jLabel.setText("命 令 行:");
			jLabel.setFont(new Font("Dialog", Font.BOLD, 14));
			jLabel.setDisplayedMnemonic(KeyEvent.VK_UNDEFINED);
			cmdPane = new JPanel();
			cmdPane.setLayout(new FlowLayout());
			cmdPane.setPreferredSize(new Dimension(0, 30));
			cmdPane.add(jLabel, null);
			cmdPane.add(getCmdText(), null);
		}
		return cmdPane;
	}

	/**
	 * This method initializes cmdText
	 * 
	 * @return javax.swing.JTextField
	 */
	private JTextField getCmdText() {
		if (cmdText == null) {
			cmdText = new JTextField();
			cmdText.setColumns(25);
			// 添加键盘监听事件;
			cmdText.addKeyListener(new java.awt.event.KeyAdapter() {
				public void keyTyped(java.awt.event.KeyEvent e) {

				}

				public void keyPressed(java.awt.event.KeyEvent e) {
					if (e.getKeyCode() == 10) {
						// 对文本进行处理;
						cmd.operate(cmdText.getText().trim());
					}
				}
			});
		}
		return cmdText;
	}

	/**
	 * This method initializes echoArea 操作结果显示;
	 * 
	 * @return javax.swing.JTextArea
	 */
	private JScrollPane getEchoArea() {
		if (echoArea == null) {
			echoArea = new JTextArea();
			echoArea.setEditable(false);
			areaScroll = new JScrollPane();
			areaScroll.setViewportView(echoArea);
		}
		// return echoArea;
		return areaScroll;
	}

	/**
	 * This method initializes restart
	 * 
	 * @return javax.swing.JMenuItem
	 */
	private JMenuItem getRestart() {
		if (restart == null) {
			restart = new JMenuItem("刷新");
		}
		return restart;
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				GUIFrame thisClass = new GUIFrame();
				thisClass.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
				thisClass.setVisible(true);
			}
		});
	}

	/**
	 * This is the default constructor
	 */
	public GUIFrame() {
		super();
		// 设置外观感觉;
		String laf = UIManager.getSystemLookAndFeelClassName();
		System.out.println(laf);
		try {
			UIManager.setLookAndFeel(laf);
		} catch (UnsupportedLookAndFeelException exc) {
			System.err.println("Warning: UnsupportedLookAndFeel: " + laf);
		} catch (Exception exc) {
			System.err.println("Error loading " + laf + ": " + exc);
		}
		initialize();
	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setSize(537, 382);
		this.setJMenuBar(getMyMenuBar());
		this.setForeground(new Color(110, 178, 198));
		this.setContentPane(getJContentPane());
		setFrameIcon();
		this.setTitle("云备份");
		setFrameCenter();
		// 对命令进行处理的类;
		cmd = new Command(this);
		addChildren(cmd.ListDisks(), root);
		fileTree.expandRow(0);
		restart.doClick();
		// addChildren()
	}
	/*
	 * 设置窗口的图标;
	 */
	private void setFrameIcon(){
		Toolkit tool=this.getToolkit();
		Image frameIcon=(Image) tool.getImage(getClass().getResource("images/netdisk.gif"));
		this.setIconImage(frameIcon);
	}
    /*
     * 使窗体居中显示;
     */
	public void setFrameCenter(){
		Toolkit tool=Toolkit.getDefaultToolkit();
		Dimension di=tool.getScreenSize();
		int x=(int)(di.getWidth()-this.getWidth())/2;
		int y=(int)(di.getHeight()-this.getHeight())/2;
		this.setLocation(x, y);
	}
	/**
	 * This method initializes jContentPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getJContentPane() {
		if (jContentPane == null) {
			jContentPane = new JPanel();
			jContentPane.setLayout(new BorderLayout());
			jContentPane.add(getSplitPane(), BorderLayout.CENTER);
		}
		return jContentPane;
	}

	// 在回显框显示结果;
	public void display(final String str) {
		new Thread(new Runnable(){
			@Override
			public void run() {
				echoArea.append(str + "\n");
				echoArea.setCaretPosition(echoArea.getText().length());
			}
		}).start();
		
		cmdText.setText("");
	}

	/*
	 * 往node节点下添加一个子节点obj;
	 */
	public void addChild(Object obj, DefaultMutableTreeNode node) {
		if (obj != null && node != null) {
			DefaultMutableTreeNode temp = new DefaultMutableTreeNode(obj);
			if (node.getAllowsChildren())
				node.add(temp);
			if (!((String) obj).equals("A:\\") & ((String) obj).length() <= 3)// 防止读取A软驱,会出现异常;用于初始用的;
				addChildren(cmd.listAll((String) obj), temp);
		}
	}

	/*
	 * 在node节点下添加数组children;
	 */
	public void addChildren(String[] children, DefaultMutableTreeNode node) {
		if (children != null && node != null) {
			for (int i = 0; i < children.length; i++) {
				addChild(children[i], node);
			}
		}
	}

	/*
	 * 对树的节点进行预提取;
	 */
	public void addPrefetchChildren(String path, DefaultMutableTreeNode node) {
		addChildren(cmd.listDirectory(path), node);
	}
} // @jve:decl-index=0:visual-constraint="10,10"
