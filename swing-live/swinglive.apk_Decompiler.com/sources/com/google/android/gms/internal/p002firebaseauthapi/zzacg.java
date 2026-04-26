package com.google.android.gms.internal.p002firebaseauthapi;

import C0.a;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.text.TextUtils;
import com.google.android.gms.common.internal.F;
import com.google.firebase.auth.FirebaseAuth;
import e1.k;
import g1.f;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;

/* JADX INFO: loaded from: classes.dex */
public final class zzacg extends AsyncTask<Void, Void, zzacj> {
    private static final a zza = new a("FirebaseAuth", "GetAuthDomainTask");
    private final String zzb;
    private final String zzc;
    private final WeakReference<zzaci> zzd;
    private final Uri.Builder zze;
    private final String zzf;
    private final f zzg;

    public zzacg(String str, String str2, Intent intent, f fVar, zzaci zzaciVar) {
        F.d(str);
        this.zzb = str;
        F.g(fVar);
        this.zzg = fVar;
        F.d(str2);
        F.g(intent);
        String stringExtra = intent.getStringExtra("com.google.firebase.auth.KEY_API_KEY");
        F.d(stringExtra);
        Uri.Builder builderBuildUpon = Uri.parse(zzaciVar.zza(stringExtra)).buildUpon();
        Uri.Builder builderAppendQueryParameter = builderBuildUpon.appendPath("getProjectConfig").appendQueryParameter("key", stringExtra).appendQueryParameter("androidPackageName", str);
        F.g(str2);
        builderAppendQueryParameter.appendQueryParameter("sha1Cert", str2);
        this.zzc = builderBuildUpon.build().toString();
        this.zzd = new WeakReference<>(zzaciVar);
        this.zze = zzaciVar.zza(intent, str, str2);
        this.zzf = intent.getStringExtra("com.google.firebase.auth.KEY_CUSTOM_AUTH_DOMAIN");
    }

    /* JADX INFO: Access modifiers changed from: private */
    @Override // android.os.AsyncTask
    /* JADX INFO: renamed from: zza, reason: merged with bridge method [inline-methods] */
    public final zzacj doInBackground(Void... voidArr) {
        try {
            URL url = new URL(this.zzc);
            zzaci zzaciVar = this.zzd.get();
            HttpURLConnection httpURLConnectionZza = zzaciVar.zza(url);
            httpURLConnectionZza.addRequestProperty("Content-Type", "application/json; charset=UTF-8");
            httpURLConnectionZza.setConnectTimeout(60000);
            new zzacv(zzaciVar.zza(), this.zzg, zzact.zza().zzb()).zza(httpURLConnectionZza);
            int responseCode = httpURLConnectionZza.getResponseCode();
            if (responseCode != 200) {
                String strZza = zza(httpURLConnectionZza);
                zza.c("Error getting project config. Failed with " + strZza + " " + responseCode, new Object[0]);
                return zzacj.zzb(strZza);
            }
            zzafh zzafhVar = new zzafh();
            zzafhVar.zza(new String(zza(httpURLConnectionZza.getInputStream(), 128)));
            if (!TextUtils.isEmpty(this.zzf)) {
                return !zzafhVar.zza().contains(this.zzf) ? zzacj.zzb("UNAUTHORIZED_DOMAIN") : zzacj.zza(this.zzf);
            }
            for (String str : zzafhVar.zza()) {
                if (zza(str)) {
                    return zzacj.zza(str);
                }
            }
            return null;
        } catch (zzaah e) {
            zza.c(B1.a.m("ConversionException encountered: ", e.getMessage()), new Object[0]);
            return null;
        } catch (IOException e4) {
            zza.c(B1.a.m("IOException occurred: ", e4.getMessage()), new Object[0]);
            return null;
        } catch (NullPointerException e5) {
            zza.c(B1.a.m("Null pointer encountered: ", e5.getMessage()), new Object[0]);
            return null;
        }
    }

    @Override // android.os.AsyncTask
    public final /* synthetic */ void onCancelled(zzacj zzacjVar) {
        onPostExecute((zzacj) null);
    }

    private static String zza(HttpURLConnection httpURLConnection) {
        try {
            if (httpURLConnection.getResponseCode() < 400) {
                return null;
            }
            InputStream errorStream = httpURLConnection.getErrorStream();
            if (errorStream == null) {
                return "WEB_INTERNAL_ERROR:Could not retrieve the authDomain for this project but did not receive an error response from the network request. Please try again.";
            }
            return (String) zzaco.zza(new String(zza(errorStream, 128)), String.class);
        } catch (IOException e) {
            zza.f("Error parsing error message from response body in getErrorMessageFromBody. ".concat(String.valueOf(e)), new Object[0]);
            return null;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    @Override // android.os.AsyncTask
    /* JADX INFO: renamed from: zza, reason: merged with bridge method [inline-methods] */
    public final void onPostExecute(zzacj zzacjVar) {
        String strZza;
        String strZzb;
        Uri.Builder builder;
        zzaci zzaciVar = this.zzd.get();
        if (zzacjVar != null) {
            strZza = zzacjVar.zza();
            strZzb = zzacjVar.zzb();
        } else {
            strZza = null;
            strZzb = null;
        }
        if (zzaciVar == null) {
            zza.c("An error has occurred: the handler reference has returned null.", new Object[0]);
        } else if (!TextUtils.isEmpty(strZza) && (builder = this.zze) != null) {
            builder.authority(strZza);
            zzaciVar.zza(this.zze.build(), this.zzb, FirebaseAuth.getInstance(this.zzg).f3855p);
        } else {
            zzaciVar.zza(this.zzb, k.O(strZzb));
        }
    }

    private static boolean zza(String str) {
        try {
            String host = new URI("https://" + str).getHost();
            if (host != null) {
                if (host.endsWith("firebaseapp.com")) {
                    return true;
                }
                if (host.endsWith("web.app")) {
                    return true;
                }
            }
        } catch (URISyntaxException e) {
            zza.c("Error parsing URL for auth domain check: " + str + ". " + e.getMessage(), new Object[0]);
        }
        return false;
    }

    private static byte[] zza(InputStream inputStream, int i4) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        try {
            byte[] bArr = new byte[128];
            while (true) {
                int i5 = inputStream.read(bArr);
                if (i5 != -1) {
                    byteArrayOutputStream.write(bArr, 0, i5);
                } else {
                    byte[] byteArray = byteArrayOutputStream.toByteArray();
                    byteArrayOutputStream.close();
                    return byteArray;
                }
            }
        } catch (Throwable th) {
            byteArrayOutputStream.close();
            throw th;
        }
    }
}
