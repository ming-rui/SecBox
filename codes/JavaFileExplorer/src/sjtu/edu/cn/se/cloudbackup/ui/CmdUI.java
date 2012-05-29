package sjtu.edu.cn.se.cloudbackup.ui;

import java.util.Scanner;

public class CmdUI implements IDisplayable{

	@Override
	public void display(String msg) {
		System.out.println(msg);
	}
	
	public static void main(String[] args){
		Command cmd = new Command(new CmdUI());
		System.out.println("C:>");
		while (true){
			Scanner scanner = new Scanner(System.in);
			String oprate = scanner.nextLine();
			cmd.operate(oprate);
			if (oprate == "exit") break;
		}
	}
}
