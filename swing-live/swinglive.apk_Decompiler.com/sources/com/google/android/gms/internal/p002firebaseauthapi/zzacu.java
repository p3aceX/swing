package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public final class zzacu {
    public static String zza() {
        Locale locale = Locale.getDefault();
        StringBuilder sb = new StringBuilder();
        zza(sb, locale);
        Locale locale2 = Locale.US;
        if (!locale.equals(locale2)) {
            if (sb.length() > 0) {
                sb.append(", ");
            }
            zza(sb, locale2);
        }
        return sb.toString();
    }

    private static void zza(StringBuilder sb, Locale locale) {
        String language = locale.getLanguage();
        if (language != null) {
            sb.append(language);
            String country = locale.getCountry();
            if (country != null) {
                sb.append("-");
                sb.append(country);
            }
        }
    }
}
