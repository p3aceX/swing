package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzakp {
    private static final char[] zza;

    static {
        char[] cArr = new char[80];
        zza = cArr;
        Arrays.fill(cArr, ' ');
    }

    public static String zza(zzakk zzakkVar, String str) {
        StringBuilder sb = new StringBuilder();
        sb.append("# ");
        sb.append(str);
        zza(zzakkVar, sb, 0);
        return sb.toString();
    }

    private static void zza(int i4, StringBuilder sb) {
        while (i4 > 0) {
            char[] cArr = zza;
            int length = i4 > cArr.length ? cArr.length : i4;
            sb.append(cArr, 0, length);
            i4 -= length;
        }
    }

    public static void zza(StringBuilder sb, int i4, String str, Object obj) {
        if (obj instanceof List) {
            Iterator it = ((List) obj).iterator();
            while (it.hasNext()) {
                zza(sb, i4, str, it.next());
            }
            return;
        }
        if (obj instanceof Map) {
            Iterator it2 = ((Map) obj).entrySet().iterator();
            while (it2.hasNext()) {
                zza(sb, i4, str, (Map.Entry) it2.next());
            }
            return;
        }
        sb.append('\n');
        zza(i4, sb);
        if (!str.isEmpty()) {
            StringBuilder sb2 = new StringBuilder();
            sb2.append(Character.toLowerCase(str.charAt(0)));
            for (int i5 = 1; i5 < str.length(); i5++) {
                char cCharAt = str.charAt(i5);
                if (Character.isUpperCase(cCharAt)) {
                    sb2.append("_");
                }
                sb2.append(Character.toLowerCase(cCharAt));
            }
            str = sb2.toString();
        }
        sb.append(str);
        if (obj instanceof String) {
            sb.append(": \"");
            sb.append(zzalx.zza(zzahm.zza((String) obj)));
            sb.append('\"');
            return;
        }
        if (obj instanceof zzahm) {
            sb.append(": \"");
            sb.append(zzalx.zza((zzahm) obj));
            sb.append('\"');
            return;
        }
        if (obj instanceof zzaja) {
            sb.append(" {");
            zza((zzaja) obj, sb, i4 + 2);
            sb.append("\n");
            zza(i4, sb);
            sb.append("}");
            return;
        }
        if (obj instanceof Map.Entry) {
            sb.append(" {");
            Map.Entry entry = (Map.Entry) obj;
            int i6 = i4 + 2;
            zza(sb, i6, "key", entry.getKey());
            zza(sb, i6, "value", entry.getValue());
            sb.append("\n");
            zza(i4, sb);
            sb.append("}");
            return;
        }
        sb.append(": ");
        sb.append(obj);
    }

    /* JADX WARN: Removed duplicated region for block: B:58:0x0160  */
    /* JADX WARN: Removed duplicated region for block: B:66:0x0188  */
    /* JADX WARN: Removed duplicated region for block: B:67:0x018b  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    private static void zza(com.google.android.gms.internal.p002firebaseauthapi.zzakk r21, java.lang.StringBuilder r22, int r23) {
        /*
            Method dump skipped, instruction units count: 574
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.internal.p002firebaseauthapi.zzakp.zza(com.google.android.gms.internal.firebase-auth-api.zzakk, java.lang.StringBuilder, int):void");
    }
}
