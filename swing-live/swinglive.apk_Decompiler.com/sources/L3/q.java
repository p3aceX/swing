package l3;

import Q3.C0151x;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Base64;
import android.util.Log;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.KeyStore;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.cert.Certificate;
import java.security.spec.AlgorithmParameterSpec;
import java.util.Comparator;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public class q implements T3.d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f5711a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f5712b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f5713c;

    public q() {
        final C0151x c0151x = new C0151x(7);
        final int i4 = 0;
        this.f5711a = new PriorityBlockingQueue(400, new Comparator() { // from class: y1.g
            @Override // java.util.Comparator
            public final int compare(Object obj, Object obj2) {
                switch (i4) {
                }
                return ((Number) ((C0151x) c0151x).invoke(obj, obj2)).intValue();
            }
        });
        final C0151x c0151x2 = new C0151x(8);
        final int i5 = 1;
        this.f5712b = new PriorityBlockingQueue(200, new Comparator() { // from class: y1.g
            @Override // java.util.Comparator
            public final int compare(Object obj, Object obj2) {
                switch (i5) {
                }
                return ((Number) ((C0151x) c0151x2).invoke(obj, obj2)).intValue();
            }
        });
        this.f5713c = new AtomicBoolean(false);
    }

    public byte[] a(byte[] bArr) throws BadPaddingException, IllegalBlockSizeException, InvalidKeyException, InvalidAlgorithmParameterException {
        int iF = f();
        byte[] bArr2 = new byte[iF];
        ((SecureRandom) this.f5712b).nextBytes(bArr2);
        AlgorithmParameterSpec algorithmParameterSpecG = g(bArr2);
        Key key = (Key) this.f5713c;
        Cipher cipher = (Cipher) this.f5711a;
        cipher.init(1, key, algorithmParameterSpecG);
        byte[] bArrDoFinal = cipher.doFinal(bArr);
        byte[] bArr3 = new byte[bArrDoFinal.length + iF];
        System.arraycopy(bArr2, 0, bArr3, 0, iF);
        System.arraycopy(bArrDoFinal, 0, bArr3, iF, bArrDoFinal.length);
        return bArr3;
    }

    @Override // T3.d
    public Object b(T3.e eVar, InterfaceC0762c interfaceC0762c) {
        Object objB = ((T3.d) this.f5711a).b(new T3.l(eVar, (L.d) this.f5712b, (K) this.f5713c), interfaceC0762c);
        return objB == EnumC0789a.f6999a ? objB : w3.i.f6729a;
    }

    public String c() {
        return "VGhpcyBpcyB0aGUga2V5IGZvciBhIHNlY3VyZSBzdG9yYWdlIEFFUyBLZXkK";
    }

    public Cipher e() {
        return Cipher.getInstance("AES/CBC/PKCS7Padding");
    }

    public int f() {
        return 16;
    }

    public AlgorithmParameterSpec g(byte[] bArr) {
        return new IvParameterSpec(bArr);
    }

    public q(Context context, com.google.android.gms.common.internal.r rVar) throws Exception {
        this.f5712b = new SecureRandom();
        String strC = c();
        SharedPreferences sharedPreferences = context.getSharedPreferences("FlutterSecureKeyStorage", 0);
        SharedPreferences.Editor editorEdit = sharedPreferences.edit();
        String string = sharedPreferences.getString(strC, null);
        this.f5711a = e();
        if (string != null) {
            try {
                this.f5713c = rVar.G(Base64.decode(string, 0));
                return;
            } catch (Exception e) {
                Log.e("StorageCipher18Impl", "unwrap key failed", e);
            }
        }
        byte[] bArr = new byte[16];
        ((SecureRandom) this.f5712b).nextBytes(bArr);
        SecretKeySpec secretKeySpec = new SecretKeySpec(bArr, "AES");
        this.f5713c = secretKeySpec;
        rVar.getClass();
        KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
        keyStore.load(null);
        String str = (String) rVar.f3597b;
        Certificate certificate = keyStore.getCertificate(str);
        if (certificate != null) {
            PublicKey publicKey = certificate.getPublicKey();
            if (publicKey != null) {
                Cipher cipherZ = rVar.z();
                cipherZ.init(3, publicKey, rVar.y());
                editorEdit.putString(strC, Base64.encodeToString(cipherZ.wrap(secretKeySpec), 0));
                editorEdit.apply();
                return;
            }
            throw new Exception(B1.a.m("No key found under alias: ", str));
        }
        throw new Exception(B1.a.m("No certificate found under alias: ", str));
    }

    public q(T3.d dVar, L.d dVar2, K k4) {
        this.f5711a = dVar;
        this.f5712b = dVar2;
        this.f5713c = k4;
    }
}
