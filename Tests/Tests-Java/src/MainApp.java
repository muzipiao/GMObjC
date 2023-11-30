
// import org.bouncycastle.asn1.x9.ECNamedCurveTable;
import org.bouncycastle.asn1.gm.GMNamedCurves;
import org.bouncycastle.asn1.x9.X9ECParameters;
import org.bouncycastle.crypto.AsymmetricCipherKeyPair;
import org.bouncycastle.crypto.agreement.ECDHBasicAgreement;
import org.bouncycastle.crypto.params.ECPublicKeyParameters;
import org.bouncycastle.crypto.params.ParametersWithID;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.crypto.params.ECDomainParameters;
import org.bouncycastle.crypto.params.ECKeyGenerationParameters;
import org.bouncycastle.crypto.params.ECPrivateKeyParameters;
import org.bouncycastle.crypto.generators.ECKeyPairGenerator;

import javax.crypto.Cipher;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.Security;
import javax.crypto.KeyAgreement;
import java.security.SecureRandom;

public class MainApp {
  public static void main(String[] args) {
    Security.addProvider(new BouncyCastleProvider());
    System.out.println("Hello World!");
    testSM2();
    testECDH();
    testSM2ECDH();
    testSM2ECDHWithID();
  }

  public static String encodeHexString(byte[] data) {
    StringBuilder sb = new StringBuilder();
    for (byte b : data) {
      sb.append(String.format("%02x", b));
    }
    return sb.toString();
  }

  // 测试 SM2 加解密
  public static void testSM2() {
    try {
      Security.addProvider(new BouncyCastleProvider());

      // 生成SM2密钥对
      KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("EC", "BC");
      keyPairGenerator.initialize(256); // SM2使用的是256位密钥长度
      KeyPair keyPair = keyPairGenerator.generateKeyPair();

      // 获得SM2加密算法实例
      Cipher encryptCipher = Cipher.getInstance("SM2", "BC");
      encryptCipher.init(Cipher.ENCRYPT_MODE, keyPair.getPublic());

      // 待加密的明文
      byte[] plaintext = "Hello, SM2!".getBytes();

      // 进行加密
      byte[] ciphertext = encryptCipher.doFinal(plaintext);

      // 输出加密后的密文
      String cipherString = encodeHexString(ciphertext);
      System.out.println("加密后的密文: " + cipherString);

      // 解密
      Cipher decryptCipher = Cipher.getInstance("SM2", "BC");
      decryptCipher.init(Cipher.DECRYPT_MODE, keyPair.getPrivate());

      byte[] decryptedText = decryptCipher.doFinal(ciphertext);

      // 输出解密后的明文
      System.out.println("解密后的明文: " + new String(decryptedText));
    } catch (NoSuchAlgorithmException | NoSuchProviderException e) {
      e.printStackTrace();
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }

  // 测试 ECDH
  public static void testECDH() {
    try {
      // 创建第一个密钥对
      KeyPairGenerator keyPairGenerator1 = KeyPairGenerator.getInstance("EC", "BC");
      keyPairGenerator1.initialize(256); // 使用256位密钥长度
      KeyPair keyPair1 = keyPairGenerator1.generateKeyPair();

      // 创建第二个密钥对
      KeyPairGenerator keyPairGenerator2 = KeyPairGenerator.getInstance("EC", "BC");
      keyPairGenerator2.initialize(256); // 使用256位密钥长度
      KeyPair keyPair2 = keyPairGenerator2.generateKeyPair();

      // 使用第一个密钥对的私钥和第二个密钥对的公钥进行密钥协商
      KeyAgreement keyAgreement1 = KeyAgreement.getInstance("ECDH", "BC");
      keyAgreement1.init(keyPair1.getPrivate());
      keyAgreement1.doPhase(keyPair2.getPublic(), true);

      // 使用第二个密钥对的私钥和第一个密钥对的公钥进行密钥协商
      KeyAgreement keyAgreement2 = KeyAgreement.getInstance("ECDH", "BC");
      keyAgreement2.init(keyPair2.getPrivate());
      keyAgreement2.doPhase(keyPair1.getPublic(), true);

      // 生成共享的密钥
      byte[] sharedSecret1 = keyAgreement1.generateSecret();
      byte[] sharedSecret2 = keyAgreement2.generateSecret();

      // 检查两个共享密钥是否相同（用于验证）
      if (java.util.Arrays.equals(sharedSecret1, sharedSecret2)) {
        System.out.println("密钥交换成功，共享的密钥: " + java.util.Base64.getEncoder().encodeToString(sharedSecret1));
      } else {
        System.out.println("密钥交换失败");
      }

    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  // 测试 ECDH
  public static void testSM2ECDH() {
    try {
      SecureRandom random = new SecureRandom();
      // 定义SM2的参数
      X9ECParameters x9ECParameters = GMNamedCurves.getByName("sm2p256v1");
      ECDomainParameters ecParams = new ECDomainParameters(x9ECParameters.getCurve(), x9ECParameters.getG(),
          x9ECParameters.getN());

      // 创建第一个密钥对
      ECKeyPairGenerator keyPairGenerator1 = new ECKeyPairGenerator();
      ECKeyGenerationParameters keyGenParams1 = new ECKeyGenerationParameters(ecParams, random);
      keyPairGenerator1.init(keyGenParams1);
      AsymmetricCipherKeyPair keyPair1 = keyPairGenerator1.generateKeyPair();

      // 创建第二个密钥对
      ECKeyPairGenerator keyPairGenerator2 = new ECKeyPairGenerator();
      ECKeyGenerationParameters keyGenParams2 = new ECKeyGenerationParameters(ecParams, random);
      keyPairGenerator2.init(keyGenParams2);
      AsymmetricCipherKeyPair keyPair2 = keyPairGenerator2.generateKeyPair();

      // 使用第一个密钥对的私钥和第二个密钥对的公钥进行密钥协商
      ECDHBasicAgreement keyAgreement1 = new ECDHBasicAgreement();
      keyAgreement1.init(((ECPrivateKeyParameters) keyPair1.getPrivate()));
      byte[] sharedSecret1 = keyAgreement1.calculateAgreement((ECPublicKeyParameters) keyPair2.getPublic())
          .toByteArray();

      // 使用第二个密钥对的私钥和第一个密钥对的公钥进行密钥协商
      ECDHBasicAgreement keyAgreement2 = new ECDHBasicAgreement();
      keyAgreement2.init(((ECPrivateKeyParameters) keyPair2.getPrivate()));
      byte[] sharedSecret2 = keyAgreement2.calculateAgreement((ECPublicKeyParameters) keyPair1.getPublic())
          .toByteArray();

      // 检查两个共享密钥是否相同（用于验证）
      if (java.util.Arrays.equals(sharedSecret1, sharedSecret2)) {
        System.out.println("SM2密钥交换成功，共享的密钥: " + java.util.Base64.getEncoder().encodeToString(sharedSecret1));
      } else {
        System.out.println("SM2密钥交换失败");
      }

    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  // 带 ID 的 ECDH
  public static void testSM2ECDHWithID() {
    try {
      // 创建随机数生成器
      SecureRandom random = new SecureRandom();

      // 定义SM2的参数
      X9ECParameters x9ECParameters = GMNamedCurves.getByName("sm2p256v1");
      ECDomainParameters ecParams = new ECDomainParameters(x9ECParameters.getCurve(), x9ECParameters.getG(),
          x9ECParameters.getN());

      // 生成Alice的密钥对
      ECKeyPairGenerator aliceKeyPairGenerator = new ECKeyPairGenerator();
      ECKeyGenerationParameters aliceKeyGenParams = new ECKeyGenerationParameters(ecParams, random);
      aliceKeyPairGenerator.init(aliceKeyGenParams);
      AsymmetricCipherKeyPair aliceKeyPair = aliceKeyPairGenerator.generateKeyPair();

      // 生成Bob的密钥对
      ECKeyPairGenerator bobKeyPairGenerator = new ECKeyPairGenerator();
      ECKeyGenerationParameters bobKeyGenParams = new ECKeyGenerationParameters(ecParams, random);
      bobKeyPairGenerator.init(bobKeyGenParams);
      AsymmetricCipherKeyPair bobKeyPair = bobKeyPairGenerator.generateKeyPair();

      // 模拟Bob接收到Alice的公钥
      ECPublicKeyParameters receivedAlicePublicKey = (ECPublicKeyParameters) aliceKeyPair.getPublic();
      // Bob 加入Alice的标识信息
      byte[] aliceID = "Alice's ID".getBytes(); // Alice的标识信息
      ParametersWithID receivedAlicePublicKeyWithID = new ParametersWithID(receivedAlicePublicKey, aliceID);
      // Bob 计算共享密钥
      ECDHBasicAgreement agreementBob = new ECDHBasicAgreement();
      agreementBob.init(((ECPrivateKeyParameters) bobKeyPair.getPrivate()));
      byte[] sharedKeyBob = agreementBob.calculateAgreement(receivedAlicePublicKeyWithID.getParameters()).toByteArray();

      // 模拟Alice接收到Bob的公钥
      ECPublicKeyParameters receivedBobPublicKey = (ECPublicKeyParameters) bobKeyPair.getPublic();
      // Alice 加入Bob的标识信息
      byte[] bobID = "Bob's ID".getBytes(); // Bob的标识信息
      ParametersWithID receivedBobPublicKeyWithID = new ParametersWithID(receivedBobPublicKey, bobID);
      // Alice 计算共享密钥
      ECDHBasicAgreement agreementAlice = new ECDHBasicAgreement();
      agreementAlice.init(((ECPrivateKeyParameters) aliceKeyPair.getPrivate()));
      byte[] sharedKeyAlice = agreementAlice.calculateAgreement(receivedBobPublicKeyWithID.getParameters())
          .toByteArray();

      // 检查两个共享密钥是否相同（用于验证）
      if (java.util.Arrays.equals(sharedKeyBob, sharedKeyAlice)) {
        System.out.println("带 ID 的SM2密钥交换成功，共享的密钥: " + java.util.Base64.getEncoder().encodeToString(sharedKeyBob));
      } else {
        System.out.println("带 ID 的SM2密钥交换失败");
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
