package com.google.android.gms.internal.p002firebaseauthapi;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.internal.RecaptchaActivity;
import g1.f;

/* JADX INFO: loaded from: classes.dex */
public final class zzadq {
    private final FirebaseAuth zza;
    private final Activity zzb;

    public zzadq(FirebaseAuth firebaseAuth, Activity activity) {
        this.zza = firebaseAuth;
        this.zzb = activity;
    }

    public final void zza() {
        String str;
        String str2;
        Intent intent = new Intent("com.google.firebase.auth.internal.ACTION_SHOW_RECAPTCHA");
        intent.setClass(this.zzb, RecaptchaActivity.class);
        intent.setPackage(this.zzb.getPackageName());
        f fVar = this.zza.f3841a;
        fVar.a();
        intent.putExtra("com.google.firebase.auth.KEY_API_KEY", fVar.f4309c.f4318a);
        FirebaseAuth firebaseAuth = this.zza;
        synchronized (firebaseAuth.f3847h) {
            str = firebaseAuth.f3848i;
        }
        if (!TextUtils.isEmpty(str)) {
            FirebaseAuth firebaseAuth2 = this.zza;
            synchronized (firebaseAuth2.f3847h) {
                str2 = firebaseAuth2.f3848i;
            }
            intent.putExtra("com.google.firebase.auth.KEY_TENANT_ID", str2);
        }
        intent.putExtra("com.google.firebase.auth.internal.CLIENT_VERSION", zzact.zza().zzb());
        f fVar2 = this.zza.f3841a;
        fVar2.a();
        intent.putExtra("com.google.firebase.auth.internal.FIREBASE_APP_NAME", fVar2.f4308b);
        this.zza.getClass();
        intent.putExtra("com.google.firebase.auth.KEY_CUSTOM_AUTH_DOMAIN", (String) null);
        this.zzb.startActivity(intent);
    }
}
