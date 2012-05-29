package sjtu.edu.cn.se.cloudbackup.util;


import java.math.BigInteger;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class HashUtils {
	
	public static String hmacSHA256(String key, String data) {
		try {
			Mac mac = Mac.getInstance("HmacSHA256");
			SecretKeySpec secret = new SecretKeySpec(key.getBytes(),"HmacSHA256");
			mac.init(secret);

			StringBuffer sb = new StringBuffer();
			
			byte[] digest = mac.doFinal(data.getBytes());
			BigInteger hash = new BigInteger(1, digest);
			sb.append(hash.toString(16));
			if ((sb.length() % 2) != 0) {
				return "0" + sb.toString();
			}
			return sb.toString();
		} catch (NoSuchAlgorithmException e) {
			throw new RuntimeException("Problems calculating HMAC", e);
		} catch (InvalidKeyException e) {
			throw new RuntimeException("Problems calculating HMAC", e);
		}
	}
}