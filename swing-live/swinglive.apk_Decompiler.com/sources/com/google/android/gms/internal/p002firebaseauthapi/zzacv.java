package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.Tasks;
import com.google.crypto.tink.shaded.protobuf.S;
import com.google.firebase.auth.FirebaseAuth;
import g1.f;
import java.net.URLConnection;
import java.util.concurrent.ExecutionException;
import p1.c;
import p1.e;

/* JADX INFO: loaded from: classes.dex */
public final class zzacv {
    private Context zza;
    private zzado zzb;
    private String zzc;
    private final f zzd;
    private boolean zze;
    private String zzf;

    public zzacv(Context context, f fVar, String str) {
        this.zze = false;
        F.g(context);
        this.zza = context;
        F.g(fVar);
        this.zzd = fVar;
        this.zzc = a.m("Android/Fallback/", str);
    }

    private static String zza(f fVar) {
        if (FirebaseAuth.getInstance(fVar).f3855p.get() == null) {
            return null;
        }
        throw new ClassCastException();
    }

    private static String zzb(f fVar) {
        e eVar = (e) FirebaseAuth.getInstance(fVar).f3856q.get();
        if (eVar != null) {
            try {
                return (String) Tasks.await(((c) eVar).a());
            } catch (InterruptedException | ExecutionException e) {
                Log.w("LocalRequestInterceptor", "Unable to get heartbeats: " + e.getMessage());
            }
        }
        return null;
    }

    public final void zza(URLConnection uRLConnection) {
        String strF;
        if (this.zze) {
            strF = S.f(this.zzc, "/FirebaseUI-Android");
        } else {
            strF = S.f(this.zzc, "/FirebaseCore-Android");
        }
        if (this.zzb == null) {
            this.zzb = new zzado(this.zza);
        }
        uRLConnection.setRequestProperty("X-Android-Package", this.zzb.zzb());
        uRLConnection.setRequestProperty("X-Android-Cert", this.zzb.zza());
        uRLConnection.setRequestProperty("Accept-Language", zzacu.zza());
        uRLConnection.setRequestProperty("X-Client-Version", strF);
        uRLConnection.setRequestProperty("X-Firebase-Locale", this.zzf);
        f fVar = this.zzd;
        fVar.a();
        uRLConnection.setRequestProperty("X-Firebase-GMPID", fVar.f4309c.f4319b);
        uRLConnection.setRequestProperty("X-Firebase-Client", zzb(this.zzd));
        String strZza = zza(this.zzd);
        if (!TextUtils.isEmpty(strZza)) {
            uRLConnection.setRequestProperty("X-Firebase-AppCheck", strZza);
        }
        this.zzf = null;
    }

    public final void zzb(String str) {
        this.zzf = str;
    }

    /* JADX WARN: 'this' call moved to the top of the method (can break code semantics) */
    public zzacv(f fVar, String str) {
        this(fVar.f4307a, fVar, str);
        fVar.a();
    }

    public final void zza(String str) {
        this.zze = !TextUtils.isEmpty(str);
    }
}
