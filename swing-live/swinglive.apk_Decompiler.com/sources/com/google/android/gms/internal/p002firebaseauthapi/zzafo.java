package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import android.util.Base64;
import com.google.android.gms.common.internal.F;
import java.io.UnsupportedEncodingException;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzafo {
    public static long zza(String str) {
        zzafn zzafnVarZzb = zzb(str);
        return zzafnVarZzb.zza().longValue() - zzafnVarZzb.zzb().longValue();
    }

    private static zzafn zzb(String str) {
        F.d(str);
        List<String> listZza = zzac.zza('.').zza((CharSequence) str);
        if (listZza.size() < 2) {
            throw new RuntimeException(a.m("Invalid idToken ", str));
        }
        String str2 = listZza.get(1);
        try {
            return zzafn.zza(new String(str2 == null ? null : Base64.decode(str2, 11), "UTF-8"));
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException("Unable to decode token", e);
        }
    }
}
