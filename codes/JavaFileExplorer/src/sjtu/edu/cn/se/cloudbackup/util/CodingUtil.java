package sjtu.edu.cn.se.cloudbackup.util;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.SecretKeySpec;

import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;


public class CodingUtil {
	public static byte[] encode(String key, byte[] data){
		try{
			SecretKeySpec spec = getKeySpec(convertKey(key));
		    Cipher cipher = Cipher.getInstance("AES");
		    cipher.init(Cipher.ENCRYPT_MODE, spec);
		    
		    return cipher.doFinal(data);
		}
		catch (NoSuchAlgorithmException e){ return null; }
		catch (NoSuchPaddingException e) { return null;	} 
		catch (InvalidKeyException e) { return null; } 
		catch (IllegalBlockSizeException e) { return null;} 
		catch (BadPaddingException e) { return null;}
	}
	
	public static byte[] decode(String key, byte[] data){
		try{
			SecretKeySpec spec = getKeySpec(convertKey(key));
			Cipher cipher = Cipher.getInstance("AES");
			cipher.init(Cipher.DECRYPT_MODE, spec);
	
			return cipher.doFinal(data);
		}
		catch (NoSuchAlgorithmException e){ return null; }
		catch (NoSuchPaddingException e) { return null;	} 
		catch (InvalidKeyException e) { return null; } 
		catch (IllegalBlockSizeException e) { return null;} 
		catch (BadPaddingException e) { return null;}
	}
	
	public static String encodeString(String key, String value){
		try {
			byte[] data = encode(key, value.getBytes("UTF-8"));
			
			String outcome = new BASE64Encoder().encode(data).replace("+", "-");
			outcome = outcome.replace('/', '_');
			return outcome;
		} 
		catch (UnsupportedEncodingException e) { return null;}
	}
	
	public static String decodeString(String key, String value){
		try {
			byte[] data = new BASE64Decoder().decodeBuffer(value.replace("-", "+").replace("_", "/"));
			
			return new String(decode(key, data));
		} 
		catch (IOException e) { return null;}
	}
	
	public static byte[] convertKey(String keyString){
		byte[] key = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; 
		
		try{
			byte[] pass = keyString.getBytes("UTF-8");
			
			for (int i = 0; i < pass.length; ++i)
				key[i] = pass[i];
		}catch (Exception e){ key = null; }
		
		return key;
	}
	
	public static SecretKeySpec  getKeySpec(byte[] key) {
	    return new SecretKeySpec(key,"AES");		
	}
	
	public static void main(String[] args){
		System.out.println(encodeString("mingrui", "/test/test/test"));
//		System.out.println(decodeString("mingrui", "sfApHBY0e1ap_7fNhfmgDA=="));
	}
}
