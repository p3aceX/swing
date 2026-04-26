package com.google.android.gms.internal.p002firebaseauthapi;

import android.security.keystore.KeyGenParameterSpec;
import android.util.Log;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.util.Arrays;
import java.util.Locale;
import javax.crypto.KeyGenerator;

/* JADX INFO: loaded from: classes.dex */
public final class zzma implements zzcd {
    private static final Object zza = new Object();
    private static final String zzb = "zzma";
    private final String zzc;
    private KeyStore zzd;

    public static final class zza {
        KeyStore zza;
        private String zzb = null;

        public zza() {
            this.zza = null;
            if (!zzma.zza()) {
                throw new IllegalStateException("need Android Keystore on Android M or newer");
            }
            try {
                KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
                this.zza = keyStore;
                keyStore.load(null);
            } catch (IOException | GeneralSecurityException e) {
                throw new IllegalStateException(e);
            }
        }
    }

    public zzma() {
        this(new zza());
    }

    public static /* synthetic */ boolean zza() {
        return true;
    }

    public static boolean zzc(String str) {
        zzma zzmaVar = new zzma();
        synchronized (zza) {
            try {
                if (zzmaVar.zzd(str)) {
                    return false;
                }
                String strZza = zzxq.zza("android-keystore://", str);
                KeyGenerator keyGenerator = KeyGenerator.getInstance("AES", "AndroidKeyStore");
                keyGenerator.init(new KeyGenParameterSpec.Builder(strZza, 3).setKeySize(256).setBlockModes("GCM").setEncryptionPaddings("NoPadding").build());
                keyGenerator.generateKey();
                return true;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    private final synchronized boolean zzd(String str) {
        String strZza;
        strZza = zzxq.zza("android-keystore://", str);
        try {
        } catch (NullPointerException unused) {
            Log.w(zzb, "Keystore is temporarily unavailable, wait, reinitialize Keystore and try again.");
            try {
                try {
                    Thread.sleep((int) (Math.random() * 40.0d));
                } catch (InterruptedException unused2) {
                }
                KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
                this.zzd = keyStore;
                keyStore.load(null);
                return this.zzd.containsAlias(strZza);
            } catch (IOException e) {
                throw new GeneralSecurityException(e);
            }
        }
        return this.zzd.containsAlias(strZza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcd
    public final synchronized boolean zzb(String str) {
        return str.toLowerCase(Locale.US).startsWith("android-keystore://");
    }

    private zzma(zza zzaVar) {
        this.zzc = null;
        this.zzd = zzaVar.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcd
    public final synchronized zzbh zza(String str) {
        zzly zzlyVar;
        zzlyVar = new zzly(zzxq.zza("android-keystore://", str), this.zzd);
        byte[] bArrZza = zzov.zza(10);
        byte[] bArr = new byte[0];
        if (!Arrays.equals(bArrZza, zzlyVar.zza(zzlyVar.zzb(bArrZza, bArr), bArr))) {
            throw new KeyStoreException("cannot use Android Keystore: encryption/decryption of non-empty message and empty aad returns an incorrect result");
        }
        return zzlyVar;
    }
}
