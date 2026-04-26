package com.google.android.recaptcha.internal;

import Q3.D;
import Q3.F;
import android.webkit.WebView;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzcd {
    private final WebView zza;
    private final D zzb;

    public zzcd(WebView webView, D d5) {
        this.zza = webView;
        this.zzb = d5;
    }

    public final void zzb(String str, String... strArr) {
        F.s(this.zzb, null, new zzcc((String[]) Arrays.copyOf(strArr, strArr.length), this, str, null), 3);
    }
}
