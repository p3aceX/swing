package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import java.util.logging.Level;
import java.util.logging.Logger;

/* JADX INFO: loaded from: classes.dex */
public final class zzah {
    public static String zza(String str) {
        return zzy.zzb(str);
    }

    public static String zzb(String str) {
        return zzy.zzc(str);
    }

    public static boolean zzc(String str) {
        return zzy.zzd(str);
    }

    public static String zza(String str, Object... objArr) {
        int iIndexOf;
        String strValueOf = String.valueOf(str);
        int i4 = 0;
        for (int i5 = 0; i5 < objArr.length; i5++) {
            objArr[i5] = zza(objArr[i5]);
        }
        StringBuilder sb = new StringBuilder((objArr.length * 16) + strValueOf.length());
        int i6 = 0;
        while (i4 < objArr.length && (iIndexOf = strValueOf.indexOf("%s", i6)) != -1) {
            sb.append((CharSequence) strValueOf, i6, iIndexOf);
            sb.append(objArr[i4]);
            i6 = iIndexOf + 2;
            i4++;
        }
        sb.append((CharSequence) strValueOf, i6, strValueOf.length());
        if (i4 < objArr.length) {
            sb.append(" [");
            sb.append(objArr[i4]);
            for (int i7 = i4 + 1; i7 < objArr.length; i7++) {
                sb.append(", ");
                sb.append(objArr[i7]);
            }
            sb.append(']');
        }
        return sb.toString();
    }

    private static String zza(Object obj) {
        if (obj == null) {
            return "null";
        }
        try {
            return obj.toString();
        } catch (Exception e) {
            String str = obj.getClass().getName() + "@" + Integer.toHexString(System.identityHashCode(obj));
            Logger.getLogger("com.google.common.base.Strings").logp(Level.WARNING, "com.google.common.base.Strings", "lenientToString", a.m("Exception during lenientFormat for ", str), (Throwable) e);
            return "<" + str + " threw " + e.getClass().getName() + ">";
        }
    }
}
