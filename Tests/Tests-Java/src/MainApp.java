
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.crypto.AsymmetricCipherKeyPair;
import org.bouncycastle.crypto.engines.SM2Engine;
import org.bouncycastle.crypto.params.ECPrivateKeyParameters;
import org.bouncycastle.crypto.params.ECPublicKeyParameters;
import org.bouncycastle.jcajce.provider.asymmetric.ec.GMCipherSpi.SM2;
import java.security.Security;
import java.math.BigInteger;

public class MainApp {
  public static void main(String[] args) {
    Security.addProvider(new BouncyCastleProvider());
    System.out.println("Hello World!");
  }

  // 测试 SM2 加解密
  public void testSM2() {
    // SM2 sm2 = SM2.Instance();
    SM2 sm2 = new SM2();
    SM2Engine sm2Engine = new SM2Engine();

    // PrivateKey privateKey = sm2.generateKeyPair().getPrivate();
    // PublicKey publicKey = sm2.generateKeyPair().getPublic();

    // byte[] source = "Hello SM2".getBytes();
    // byte[] encryptData = sm2.encrypt(publicKey, source);
    // byte[] decryptData = sm2.decrypt(privateKey, encryptData);

    // String plainText = new String(decryptData);
    // System.out.println(plainText);
  }
}
