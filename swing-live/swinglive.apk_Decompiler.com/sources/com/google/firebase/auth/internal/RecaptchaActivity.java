package com.google.firebase.auth.internal;

import G0.a;
import O.AbstractActivityC0114z;
import T.b;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcel;
import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.internal.p002firebaseauthapi.zzacg;
import com.google.android.gms.internal.p002firebaseauthapi.zzaci;
import com.google.android.gms.internal.p002firebaseauthapi.zzacl;
import com.google.android.gms.internal.p002firebaseauthapi.zzacu;
import com.google.android.gms.internal.p002firebaseauthapi.zzaec;
import com.google.android.gms.internal.p002firebaseauthapi.zzb;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.auth.FirebaseAuth;
import e1.k;
import g1.f;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.UUID;
import k1.n;
import k1.q;
import k1.r;
import k1.t;
import k1.u;
import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
public class RecaptchaActivity extends AbstractActivityC0114z implements zzaci {

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public static long f3862D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public static final q f3863E = q.f5540b;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public boolean f3864C = false;

    public final Uri.Builder k(Uri.Builder builder, Intent intent, String str, String str2) {
        String stringExtra = intent.getStringExtra("com.google.firebase.auth.KEY_API_KEY");
        String string = UUID.randomUUID().toString();
        String stringExtra2 = intent.getStringExtra("com.google.firebase.auth.internal.CLIENT_VERSION");
        String stringExtra3 = intent.getStringExtra("com.google.firebase.auth.internal.FIREBASE_APP_NAME");
        f fVarD = f.d(stringExtra3);
        FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(fVarD);
        t tVar = t.f5543a;
        Context applicationContext = getApplicationContext();
        synchronized (tVar) {
            F.d(str);
            F.d(string);
            SharedPreferences sharedPreferencesA = t.a(applicationContext, str);
            t.b(sharedPreferencesA);
            SharedPreferences.Editor editorEdit = sharedPreferencesA.edit();
            editorEdit.putString("com.google.firebase.auth.internal.EVENT_ID." + string + ".OPERATION", "com.google.firebase.auth.internal.ACTION_SHOW_RECAPTCHA");
            editorEdit.putString("com.google.firebase.auth.internal.EVENT_ID." + string + ".FIREBASE_APP_NAME", stringExtra3);
            editorEdit.apply();
        }
        String strA = u.c(getApplicationContext(), fVarD.e()).a();
        String strZza = null;
        if (TextUtils.isEmpty(strA)) {
            Log.e("RecaptchaActivity", "Could not generate an encryption key for reCAPTCHA - cancelling flow.");
            l(k.O("Failed to generate/retrieve public encryption key for reCAPTCHA flow."));
            return null;
        }
        synchronized (firebaseAuth.f3846g) {
        }
        if (TextUtils.isEmpty(null)) {
            strZza = zzacu.zza();
        }
        builder.appendQueryParameter("apiKey", stringExtra).appendQueryParameter("authType", "verifyApp").appendQueryParameter("apn", str).appendQueryParameter("hl", strZza).appendQueryParameter("eventId", string).appendQueryParameter("v", "X" + stringExtra2).appendQueryParameter("eid", "p").appendQueryParameter("appName", stringExtra3).appendQueryParameter("sha1Cert", str2).appendQueryParameter("publicKey", strA);
        return builder;
    }

    public final void l(Status status) {
        f3862D = 0L;
        this.f3864C = false;
        Intent intent = new Intent();
        HashMap map = r.f5542a;
        Parcel parcelObtain = Parcel.obtain();
        status.writeToParcel(parcelObtain, 0);
        byte[] bArrMarshall = parcelObtain.marshall();
        parcelObtain.recycle();
        intent.putExtra("com.google.firebase.auth.internal.STATUS", bArrMarshall);
        intent.setAction("com.google.firebase.auth.ACTION_RECEIVE_FIREBASE_AUTH_INTENT");
        b.a(this).b(intent);
        f3863E.f5541a.getClass();
        n.b(getSharedPreferences("com.google.firebase.auth.internal.ProcessDeathHelper", 0));
        finish();
    }

    public final void m() {
        f3862D = 0L;
        this.f3864C = false;
        Intent intent = new Intent();
        intent.putExtra("com.google.firebase.auth.internal.EXTRA_CANCELED", true);
        intent.setAction("com.google.firebase.auth.ACTION_RECEIVE_FIREBASE_AUTH_INTENT");
        b.a(this).b(intent);
        f3863E.f5541a.getClass();
        n.b(getSharedPreferences("com.google.firebase.auth.internal.ProcessDeathHelper", 0));
        finish();
    }

    @Override // O.AbstractActivityC0114z, b.AbstractActivityC0234k, q.i, android.app.Activity
    public final void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        String action = getIntent().getAction();
        if (!"com.google.firebase.auth.internal.ACTION_SHOW_RECAPTCHA".equals(action) && !"android.intent.action.VIEW".equals(action)) {
            Log.e("RecaptchaActivity", "Could not do operation - unknown action: " + action);
            m();
            return;
        }
        long jCurrentTimeMillis = System.currentTimeMillis();
        if (jCurrentTimeMillis - f3862D < 30000) {
            Log.e("RecaptchaActivity", "Could not start operation - already in progress");
            return;
        }
        f3862D = jCurrentTimeMillis;
        if (bundle != null) {
            this.f3864C = bundle.getBoolean("com.google.firebase.auth.internal.KEY_ALREADY_STARTED_RECAPTCHA_FLOW");
        }
    }

    @Override // b.AbstractActivityC0234k, android.app.Activity
    public final void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
    }

    @Override // O.AbstractActivityC0114z, android.app.Activity
    public final void onResume() {
        RecaptchaActivity recaptchaActivity;
        String str;
        super.onResume();
        if (!"android.intent.action.VIEW".equals(getIntent().getAction())) {
            if (this.f3864C) {
                m();
                return;
            }
            Intent intent = getIntent();
            String packageName = getPackageName();
            try {
                String lowerCase = a.a(a.d(this, packageName)).toLowerCase(Locale.US);
                f fVarD = f.d(intent.getStringExtra("com.google.firebase.auth.internal.FIREBASE_APP_NAME"));
                FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(fVarD);
                if (zzaec.zza(fVarD)) {
                    recaptchaActivity = this;
                    fVarD.a();
                    zza(k(Uri.parse(zzaec.zza(fVarD.f4309c.f4318a)).buildUpon(), getIntent(), packageName, lowerCase).build(), packageName, firebaseAuth.f3855p);
                } else {
                    recaptchaActivity = this;
                    new zzacg(packageName, lowerCase, intent, fVarD, recaptchaActivity).executeOnExecutor(firebaseAuth.f3858s, new Void[0]);
                }
            } catch (PackageManager.NameNotFoundException e) {
                recaptchaActivity = this;
                Log.e("RecaptchaActivity", "Could not get package signature: " + packageName + " " + String.valueOf(e));
                zzacl.zzb(this, packageName);
            }
            recaptchaActivity.f3864C = true;
            return;
        }
        Intent intent2 = getIntent();
        if (intent2.hasExtra("firebaseError")) {
            l(r.a(intent2.getStringExtra("firebaseError")));
            return;
        }
        if (!intent2.hasExtra("link") || !intent2.hasExtra("eventId")) {
            m();
            return;
        }
        String stringExtra = intent2.getStringExtra("link");
        t tVar = t.f5543a;
        Context applicationContext = getApplicationContext();
        String packageName2 = getPackageName();
        String stringExtra2 = intent2.getStringExtra("eventId");
        synchronized (tVar) {
            F.d(packageName2);
            F.d(stringExtra2);
            SharedPreferences sharedPreferencesA = t.a(applicationContext, packageName2);
            String str2 = "com.google.firebase.auth.internal.EVENT_ID." + stringExtra2 + ".OPERATION";
            str = null;
            String string = sharedPreferencesA.getString(str2, null);
            String str3 = "com.google.firebase.auth.internal.EVENT_ID." + stringExtra2 + ".FIREBASE_APP_NAME";
            String string2 = sharedPreferencesA.getString(str3, null);
            SharedPreferences.Editor editorEdit = sharedPreferencesA.edit();
            editorEdit.remove(str2);
            editorEdit.remove(str3);
            editorEdit.apply();
            if (!TextUtils.isEmpty(string)) {
                str = string2;
            }
        }
        if (TextUtils.isEmpty(str)) {
            Log.e("RecaptchaActivity", "Failed to find registration for this event - failing to prevent session injection.");
            l(k.O("Failed to find registration for this reCAPTCHA event"));
        }
        if (intent2.getBooleanExtra("encryptionEnabled", true)) {
            stringExtra = u.c(getApplicationContext(), f.d(str).e()).b(stringExtra);
        }
        String queryParameter = Uri.parse(stringExtra).getQueryParameter("recaptchaToken");
        f3862D = 0L;
        this.f3864C = false;
        Intent intent3 = new Intent();
        intent3.putExtra("com.google.firebase.auth.internal.RECAPTCHA_TOKEN", queryParameter);
        intent3.putExtra("com.google.firebase.auth.internal.OPERATION", "com.google.firebase.auth.internal.ACTION_SHOW_RECAPTCHA");
        intent3.setAction("com.google.firebase.auth.ACTION_RECEIVE_FIREBASE_AUTH_INTENT");
        b.a(this).b(intent3);
        SharedPreferences.Editor editorEdit2 = getApplicationContext().getSharedPreferences("com.google.firebase.auth.internal.ProcessDeathHelper", 0).edit();
        editorEdit2.putString("recaptchaToken", queryParameter);
        editorEdit2.putString("operation", "com.google.firebase.auth.internal.ACTION_SHOW_RECAPTCHA");
        editorEdit2.putLong("timestamp", System.currentTimeMillis());
        editorEdit2.commit();
        finish();
    }

    @Override // b.AbstractActivityC0234k, q.i, android.app.Activity
    public final void onSaveInstanceState(Bundle bundle) {
        super.onSaveInstanceState(bundle);
        bundle.putBoolean("com.google.firebase.auth.internal.KEY_ALREADY_STARTED_RECAPTCHA_FLOW", this.f3864C);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaci
    public final Uri.Builder zza(Intent intent, String str, String str2) {
        return k(new Uri.Builder().scheme("https").appendPath("__").appendPath("auth").appendPath("handler"), intent, str, str2);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaci
    public final String zza(String str) {
        return zzaec.zzb(str);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaci
    public final HttpURLConnection zza(URL url) {
        try {
            return (HttpURLConnection) zzb.zza().zza(url, "client-firebase-auth-api");
        } catch (IOException unused) {
            zzaci.zza.c("Error generating connection", new Object[0]);
            return null;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaci
    public final void zza(String str, Status status) {
        if (status == null) {
            m();
        } else {
            l(status);
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaci
    public final void zza(Uri uri, String str, InterfaceC0634a interfaceC0634a) {
        if (interfaceC0634a.get() == null) {
            Task taskForResult = Tasks.forResult(uri);
            com.google.android.gms.common.internal.r rVar = new com.google.android.gms.common.internal.r(12, false);
            rVar.f3597b = this;
            rVar.f3598c = str;
            taskForResult.addOnCompleteListener(rVar);
            return;
        }
        throw new ClassCastException();
    }
}
