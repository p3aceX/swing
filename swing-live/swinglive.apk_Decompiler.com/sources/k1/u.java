package k1;

import android.content.Context;
import android.util.Base64;
import android.util.Log;
import com.google.android.gms.internal.p002firebaseauthapi.zzbj;
import com.google.android.gms.internal.p002firebaseauthapi.zzbp;
import com.google.android.gms.internal.p002firebaseauthapi.zzce;
import com.google.android.gms.internal.p002firebaseauthapi.zzkj;
import com.google.android.gms.internal.p002firebaseauthapi.zzkq;
import com.google.android.gms.internal.p002firebaseauthapi.zzlx;
import com.google.android.gms.internal.p002firebaseauthapi.zzw;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class u {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static u f5545c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5546a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final zzlx f5547b;

    public u(Context context, String str) {
        zzlx zzlxVarZza;
        this.f5546a = str;
        try {
            zzkj.zza();
            zzlx.zza zzaVarZza = new zzlx.zza().zza(context, "GenericIdpKeyset", "com.google.firebase.auth.api.crypto." + str).zza(zzkq.zza);
            zzaVarZza.zza("android-keystore://firebear_master_key_id." + str);
            zzlxVarZza = zzaVarZza.zza();
        } catch (IOException | GeneralSecurityException e) {
            Log.e("FirebearCryptoHelper", "Exception encountered during crypto setup:\n" + e.getMessage());
            zzlxVarZza = null;
        }
        this.f5547b = zzlxVarZza;
    }

    public static u c(Context context, String str) {
        u uVar = f5545c;
        if (uVar == null || !zzw.zza(uVar.f5546a, str)) {
            f5545c = new u(context, str);
        }
        return f5545c;
    }

    public final String a() {
        if (this.f5547b == null) {
            Log.e("FirebearCryptoHelper", "KeysetManager failed to initialize - unable to get Public key");
            return null;
        }
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        zzce zzceVarZza = zzbj.zza(byteArrayOutputStream);
        try {
            synchronized (this.f5547b) {
                this.f5547b.zza().zza().zza(zzceVarZza);
            }
            return Base64.encodeToString(byteArrayOutputStream.toByteArray(), 8);
        } catch (IOException | GeneralSecurityException e) {
            Log.e("FirebearCryptoHelper", "Exception encountered when attempting to get Public Key:\n" + e.getMessage());
            return null;
        }
    }

    public final String b(String str) {
        String str2;
        zzlx zzlxVar = this.f5547b;
        if (zzlxVar == null) {
            Log.e("FirebearCryptoHelper", "KeysetManager failed to initialize - unable to decrypt payload");
            return null;
        }
        try {
            synchronized (zzlxVar) {
                str2 = new String(((zzbp) this.f5547b.zza().zza(zzbp.class)).zza(Base64.decode(str, 8), null), "UTF-8");
            }
            return str2;
        } catch (UnsupportedEncodingException | GeneralSecurityException e) {
            Log.e("FirebearCryptoHelper", "Exception encountered while decrypting bytes:\n" + e.getMessage());
            return null;
        }
    }
}
