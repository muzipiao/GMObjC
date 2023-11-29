// import org.bouncycastle.asn1.x9.ECNamedCurveTable;
import org.bouncycastle.crypto.AsymmetricCipherKeyPair;
import org.bouncycastle.crypto.agreement.ECDHBasicAgreement;
import org.bouncycastle.crypto.params.ECPublicKeyParameters;
import org.bouncycastle.crypto.params.ParametersWithID;
import org.bouncycastle.jce.ECNamedCurveTable;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.jce.spec.ECNamedCurveParameterSpec;
import org.bouncycastle.crypto.util.PublicKeyFactory;
import org.bouncycastle.crypto.util.PrivateKeyFactory;
import org.bouncycastle.crypto.engines.SM2Engine;
import org.bouncycastle.crypto.params.ECDomainParameters;
import org.bouncycastle.crypto.params.ECKeyGenerationParameters;
import org.bouncycastle.crypto.params.ECPrivateKeyParameters;
import org.bouncycastle.crypto.generators.ECKeyPairGenerator;

import javax.crypto.Cipher;
import java.math.BigInteger;
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
      System.out.println("加密后的密文: " + new String(ciphertext));

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
      Security.addProvider(new BouncyCastleProvider());

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

  // 带 ID 的 ECDH
  public static void testECDHWithID() {
    try {
      // 创建随机数生成器
      SecureRandom random = new SecureRandom();

      // 定义SM2的参数
      // ECDomainParameters ecParams = org.bouncycastle.asn1.x9.ECNamedCurveTable.getByNameX9("GostR3410-2001-CryptoPro-A");
      // ECNamedCurveTable.getByName("sm2p256v1").getInstance();ECNamedCurveTable
      ECDomainParameters ecParams = ECNamedCurveTable.getParameterSpec("sm2p256v1").getParameters();
      
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

      // 模拟Alice发送公钥给Bob
      ECPublicKeyParameters alicePublicKey = (ECPublicKeyParameters) aliceKeyPair.getPublic();

      // 模拟Bob接收到Alice的公钥
      ECPublicKeyParameters receivedAlicePublicKey = (ECPublicKeyParameters) aliceKeyPair.getPublic();

      // Bob 加入Alice的标识信息
      byte[] bobID = "Bob's ID".getBytes(); // Bob的标识信息
      ParametersWithID receivedAlicePublicKeyWithID = new ParametersWithID(receivedAlicePublicKey, bobID);

      // Bob 计算共享密钥
      ECDHBasicAgreement agreementBob = new ECDHBasicAgreement();
      agreementBob.init(((ECPrivateKeyParameters) bobKeyPair.getPrivate()));
      BigInteger sharedKeyBobBigInt = agreementBob.calculateAgreement(receivedAlicePublicKeyWithID);

      // 将BigInteger转换为字节数组
      byte[] sharedKeyBob = sharedKeyBobBigInt.toByteArray();

      // 模拟Bob发送公钥给Alice
      ECPublicKeyParameters bobPublicKey = (ECPublicKeyParameters) bobKeyPair.getPublic();

      // 模拟Alice接收到Bob的公钥
      ECPublicKeyParameters receivedBobPublicKey = (ECPublicKeyParameters) bobKeyPair.getPublic();

      // Alice 加入Bob的标识信息
      byte[] aliceID = "Alice's ID".getBytes(); // Alice的标识信息
      ParametersWithID receivedBobPublicKeyWithID = new ParametersWithID(receivedBobPublicKey, aliceID);

      // Alice 计算共享密钥
      ECDHBasicAgreement agreementAlice = new ECDHBasicAgreement();
      agreementAlice.init(((ECPrivateKeyParameters) aliceKeyPair.getPrivate()));
      BigInteger sharedKeyAliceBigInt = agreementAlice.calculateAgreement(receivedBobPublicKeyWithID);

      // 将BigInteger转换为字节数组
      byte[] sharedKeyAlice = sharedKeyAliceBigInt.toByteArray();

      // 验证共享密钥是否一致
      boolean keysMatch = java.util.Arrays.equals(sharedKeyBob, sharedKeyAlice);
      System.out.println("共享密钥是否一致: " + keysMatch);

    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
