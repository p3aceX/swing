package com.google.android.gms.internal.p002firebaseauthapi;

import C0.a;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import com.google.android.gms.common.api.Status;
import java.net.HttpURLConnection;
import java.net.URL;
import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
public interface zzaci {
    public static final a zza = new a("FirebaseAuth", "GetAuthDomainTaskResponseHandler");

    Context zza();

    Uri.Builder zza(Intent intent, String str, String str2);

    String zza(String str);

    HttpURLConnection zza(URL url);

    void zza(Uri uri, String str, InterfaceC0634a interfaceC0634a);

    void zza(String str, Status status);
}
