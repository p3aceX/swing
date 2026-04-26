package w1;

import I.C0053n;
import S0.AbstractC0154a;
import W0.e;
import Z.d;
import android.content.Context;
import android.content.SharedPreferences;
import android.security.keystore.KeyGenParameterSpec;
import android.util.Base64;
import android.util.Log;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.KeyStore;
import java.security.ProviderException;
import java.security.spec.AlgorithmParameterSpec;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import k.s0;
import l3.q;
import x1.EnumC0716a;
import x1.EnumC0718c;
import y0.C0747k;

/* JADX INFO: renamed from: w1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0702a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Context f6695b;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Map f6697d;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public SharedPreferences f6698f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public q f6699g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public C0053n f6700h;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public String f6696c = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIHNlY3VyZSBzdG9yYWdlCg";
    public String e = "FlutterSecureStorage";

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public Boolean f6701i = Boolean.FALSE;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Charset f6694a = StandardCharsets.UTF_8;

    public C0702a(Context context, HashMap map) {
        this.f6697d = map;
        this.f6695b = context.getApplicationContext();
    }

    public final void a(SharedPreferences sharedPreferences, Z.b bVar) {
        try {
            for (Map.Entry<String, ?> entry : sharedPreferences.getAll().entrySet()) {
                Object value = entry.getValue();
                String key = entry.getKey();
                if ((value instanceof String) && key.contains(this.f6696c)) {
                    String strB = b((String) value);
                    Z.a aVar = (Z.a) bVar.edit();
                    aVar.putString(key, strB);
                    aVar.apply();
                    sharedPreferences.edit().remove(key).apply();
                }
            }
            SharedPreferences.Editor editorEdit = sharedPreferences.edit();
            this.f6700h.getClass();
            editorEdit.remove("FlutterSecureSAlgorithmKey");
            editorEdit.remove("FlutterSecureSAlgorithmStorage");
            editorEdit.apply();
        } catch (Exception e) {
            Log.e("SecureStorageAndroid", "Data migration failed", e);
        }
    }

    public final String b(String str) throws InvalidKeyException, InvalidAlgorithmParameterException {
        if (str == null) {
            return null;
        }
        byte[] bArrDecode = Base64.decode(str, 0);
        q qVar = this.f6699g;
        int iF = qVar.f();
        byte[] bArr = new byte[iF];
        System.arraycopy(bArrDecode, 0, bArr, 0, iF);
        AlgorithmParameterSpec algorithmParameterSpecG = qVar.g(bArr);
        int length = bArrDecode.length - qVar.f();
        byte[] bArr2 = new byte[length];
        System.arraycopy(bArrDecode, iF, bArr2, 0, length);
        Key key = (Key) qVar.f5713c;
        Cipher cipher = (Cipher) qVar.f5711a;
        cipher.init(2, key, algorithmParameterSpecG);
        return new String(cipher.doFinal(bArr2), this.f6694a);
    }

    public final void c() {
        d();
        String str = this.e;
        Context context = this.f6695b;
        SharedPreferences sharedPreferences = context.getSharedPreferences(str, 0);
        if (this.f6699g == null) {
            try {
                f(sharedPreferences);
            } catch (Exception e) {
                Log.e("SecureStorageAndroid", "StorageCipher initialization failed", e);
            }
        }
        if (!e()) {
            this.f6698f = sharedPreferences;
            return;
        }
        try {
            Z.b bVarG = g(context);
            this.f6698f = bVarG;
            a(sharedPreferences, bVarG);
        } catch (Exception e4) {
            Log.e("SecureStorageAndroid", "EncryptedSharedPreferences initialization failed", e4);
            this.f6698f = sharedPreferences;
            this.f6701i = Boolean.TRUE;
        }
    }

    public final void d() {
        if (this.f6697d.containsKey("sharedPreferencesName") && !((String) this.f6697d.get("sharedPreferencesName")).isEmpty()) {
            this.e = (String) this.f6697d.get("sharedPreferencesName");
        }
        if (!this.f6697d.containsKey("preferencesKeyPrefix") || ((String) this.f6697d.get("preferencesKeyPrefix")).isEmpty()) {
            return;
        }
        this.f6696c = (String) this.f6697d.get("preferencesKeyPrefix");
    }

    public final boolean e() {
        return !this.f6701i.booleanValue() && this.f6697d.containsKey("encryptedSharedPreferences") && this.f6697d.get("encryptedSharedPreferences").equals("true");
    }

    public final void f(SharedPreferences sharedPreferences) {
        this.f6700h = new C0053n(sharedPreferences, this.f6697d);
        boolean zE = e();
        Context context = this.f6695b;
        if (zE) {
            C0053n c0053n = this.f6700h;
            this.f6699g = ((EnumC0718c) c0053n.f707c).f6769a.c(context, ((EnumC0716a) c0053n.f706b).f6765a.b(context));
            return;
        }
        C0053n c0053n2 = this.f6700h;
        EnumC0716a enumC0716a = (EnumC0716a) c0053n2.f706b;
        EnumC0718c enumC0718c = (EnumC0718c) c0053n2.f707c;
        EnumC0716a enumC0716a2 = (EnumC0716a) c0053n2.f708d;
        EnumC0718c enumC0718c2 = (EnumC0718c) c0053n2.e;
        if (enumC0716a == enumC0716a2 && enumC0718c == enumC0718c2) {
            this.f6699g = enumC0718c2.f6769a.c(context, enumC0716a2.f6765a.b(context));
            return;
        }
        try {
            this.f6699g = enumC0718c.f6769a.c(context, enumC0716a.f6765a.b(context));
            HashMap map = new HashMap();
            for (Map.Entry<String, ?> entry : sharedPreferences.getAll().entrySet()) {
                Object value = entry.getValue();
                String key = entry.getKey();
                if ((value instanceof String) && key.contains(this.f6696c)) {
                    map.put(key, b((String) value));
                }
            }
            this.f6699g = enumC0718c2.f6769a.c(context, enumC0716a2.f6765a.b(context));
            SharedPreferences.Editor editorEdit = sharedPreferences.edit();
            for (Map.Entry entry2 : map.entrySet()) {
                editorEdit.putString((String) entry2.getKey(), Base64.encodeToString(this.f6699g.a(((String) entry2.getValue()).getBytes(this.f6694a)), 0));
            }
            editorEdit.putString("FlutterSecureSAlgorithmKey", enumC0716a2.name());
            editorEdit.putString("FlutterSecureSAlgorithmStorage", enumC0718c2.name());
            editorEdit.apply();
        } catch (Exception e) {
            Log.e("SecureStorageAndroid", "re-encryption failed", e);
            this.f6699g = enumC0718c.f6769a.c(context, ((EnumC0716a) c0053n2.f706b).f6765a.b(context));
        }
    }

    public final Z.b g(Context context) {
        C0747k c0747kC;
        C0747k c0747kC2;
        context.getApplicationContext();
        KeyGenParameterSpec keyGenParameterSpecBuild = new KeyGenParameterSpec.Builder("_androidx_security_master_key_", 3).setEncryptionPaddings("NoPadding").setBlockModes("GCM").setKeySize(256).build();
        if (!"_androidx_security_master_key_".equals(Z.c.a(keyGenParameterSpecBuild))) {
            throw new IllegalArgumentException("KeyGenParamSpec's key alias does not match provided alias (_androidx_security_master_key_ vs " + Z.c.a(keyGenParameterSpecBuild));
        }
        if (keyGenParameterSpecBuild == null) {
            throw new IllegalArgumentException("build() called before setKeyGenParameterSpec or setKeyScheme.");
        }
        Object obj = d.f2551a;
        if (keyGenParameterSpecBuild.getKeySize() != 256) {
            throw new IllegalArgumentException("invalid key size, want 256 bits got " + keyGenParameterSpecBuild.getKeySize() + " bits");
        }
        if (!Arrays.equals(keyGenParameterSpecBuild.getBlockModes(), new String[]{"GCM"})) {
            throw new IllegalArgumentException("invalid block mode, want GCM got " + Arrays.toString(keyGenParameterSpecBuild.getBlockModes()));
        }
        if (keyGenParameterSpecBuild.getPurposes() != 3) {
            throw new IllegalArgumentException("invalid purposes mode, want PURPOSE_ENCRYPT | PURPOSE_DECRYPT got " + keyGenParameterSpecBuild.getPurposes());
        }
        if (!Arrays.equals(keyGenParameterSpecBuild.getEncryptionPaddings(), new String[]{"NoPadding"})) {
            throw new IllegalArgumentException("invalid padding mode, want NoPadding got " + Arrays.toString(keyGenParameterSpecBuild.getEncryptionPaddings()));
        }
        if (keyGenParameterSpecBuild.isUserAuthenticationRequired() && keyGenParameterSpecBuild.getUserAuthenticationValidityDurationSeconds() < 1) {
            throw new IllegalArgumentException("per-operation authentication is not supported (UserAuthenticationValidityDurationSeconds must be >0)");
        }
        synchronized (d.f2551a) {
            String keystoreAlias = keyGenParameterSpecBuild.getKeystoreAlias();
            KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
            keyStore.load(null);
            if (!keyStore.containsAlias(keystoreAlias)) {
                try {
                    KeyGenerator keyGenerator = KeyGenerator.getInstance("AES", "AndroidKeyStore");
                    keyGenerator.init(keyGenParameterSpecBuild);
                    keyGenerator.generateKey();
                } catch (ProviderException e) {
                    throw new GeneralSecurityException(e.getMessage(), e);
                }
            }
        }
        String keystoreAlias2 = keyGenParameterSpecBuild.getKeystoreAlias();
        String str = this.e;
        e.a();
        AbstractC0154a.a();
        Context applicationContext = context.getApplicationContext();
        s0 s0Var = new s0();
        s0Var.f5455f = R0.b.a("AES256_SIV");
        if (applicationContext == null) {
            throw new IllegalArgumentException("need an Android context");
        }
        s0Var.f5451a = applicationContext;
        s0Var.f5452b = "__androidx_security_crypto_encrypted_prefs_key_keyset__";
        s0Var.f5453c = str;
        String strM = B1.a.m("android-keystore://", keystoreAlias2);
        if (!strM.startsWith("android-keystore://")) {
            throw new IllegalArgumentException("key URI must start with android-keystore://");
        }
        s0Var.f5454d = strM;
        X0.a aVarA = s0Var.a();
        synchronized (aVarA) {
            c0747kC = aVarA.f2382a.c();
        }
        s0 s0Var2 = new s0();
        s0Var2.f5455f = R0.b.a("AES256_GCM");
        s0Var2.f5451a = applicationContext;
        s0Var2.f5452b = "__androidx_security_crypto_encrypted_prefs_value_keyset__";
        s0Var2.f5453c = str;
        String strM2 = B1.a.m("android-keystore://", keystoreAlias2);
        if (!strM2.startsWith("android-keystore://")) {
            throw new IllegalArgumentException("key URI must start with android-keystore://");
        }
        s0Var2.f5454d = strM2;
        X0.a aVarA2 = s0Var2.a();
        synchronized (aVarA2) {
            c0747kC2 = aVarA2.f2382a.c();
        }
        return new Z.b(str, applicationContext.getSharedPreferences(str, 0), (R0.a) c0747kC2.H(R0.a.class), (R0.c) c0747kC.H(R0.c.class));
    }

    public final HashMap h() {
        c();
        Map<String, ?> all = this.f6698f.getAll();
        HashMap map = new HashMap();
        for (Map.Entry<String, ?> entry : all.entrySet()) {
            if (entry.getKey().contains(this.f6696c)) {
                String strReplaceFirst = entry.getKey().replaceFirst(this.f6696c + '_', "");
                if (e()) {
                    map.put(strReplaceFirst, (String) entry.getValue());
                } else {
                    map.put(strReplaceFirst, b((String) entry.getValue()));
                }
            }
        }
        return map;
    }

    public final void i(String str, String str2) {
        c();
        SharedPreferences.Editor editorEdit = this.f6698f.edit();
        if (e()) {
            editorEdit.putString(str, str2);
        } else {
            editorEdit.putString(str, Base64.encodeToString(this.f6699g.a(str2.getBytes(this.f6694a)), 0));
        }
        editorEdit.apply();
    }
}
