package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.lang.reflect.Method;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;
import java.util.TimeZone;

/* JADX INFO: loaded from: classes.dex */
public final class zzand {
    private static final zzaly zza = (zzaly) ((zzaja) zzaly.zzc().zza(-62135596800L).zza(0).zzf());
    private static final zzaly zzb = (zzaly) ((zzaja) zzaly.zzc().zza(253402300799L).zza(999999999).zzf());
    private static final zzaly zzc = (zzaly) ((zzaja) zzaly.zzc().zza(0L).zza(0).zzf());
    private static final ThreadLocal<SimpleDateFormat> zzd = new zzanc();
    private static final Method zze = zzc("now");
    private static final Method zzf = zzc("getEpochSecond");
    private static final Method zzg = zzc("getNano");

    public static long zza(zzaly zzalyVar) {
        return zzb(zzalyVar).zzb();
    }

    private static long zzb(String str) throws ParseException {
        int iIndexOf = str.indexOf(58);
        if (iIndexOf == -1) {
            throw new ParseException("Invalid offset value: ".concat(str), 0);
        }
        try {
            return ((Long.parseLong(str.substring(0, iIndexOf)) * 60) + Long.parseLong(str.substring(iIndexOf + 1))) * 60;
        } catch (NumberFormatException e) {
            ParseException parseException = new ParseException("Invalid offset value: ".concat(str), 0);
            parseException.initCause(e);
            throw parseException;
        }
    }

    private static Method zzc(String str) {
        try {
            return Class.forName("java.time.Instant").getMethod(str, new Class[0]);
        } catch (Exception unused) {
            return null;
        }
    }

    public static zzaly zza(String str) throws ParseException {
        String strSubstring;
        int iCharAt;
        int iIndexOf = str.indexOf(84);
        if (iIndexOf == -1) {
            throw new ParseException(S.g("Failed to parse timestamp: invalid timestamp \"", str, "\""), 0);
        }
        int iIndexOf2 = str.indexOf(90, iIndexOf);
        if (iIndexOf2 == -1) {
            iIndexOf2 = str.indexOf(43, iIndexOf);
        }
        if (iIndexOf2 == -1) {
            iIndexOf2 = str.indexOf(45, iIndexOf);
        }
        if (iIndexOf2 == -1) {
            throw new ParseException("Failed to parse timestamp: missing valid timezone offset.", 0);
        }
        String strSubstring2 = str.substring(0, iIndexOf2);
        int iIndexOf3 = strSubstring2.indexOf(46);
        if (iIndexOf3 != -1) {
            String strSubstring3 = strSubstring2.substring(0, iIndexOf3);
            strSubstring = strSubstring2.substring(iIndexOf3 + 1);
            strSubstring2 = strSubstring3;
        } else {
            strSubstring = "";
        }
        long time = zzd.get().parse(strSubstring2).getTime() / 1000;
        if (strSubstring.isEmpty()) {
            iCharAt = 0;
        } else {
            iCharAt = 0;
            for (int i4 = 0; i4 < 9; i4++) {
                iCharAt *= 10;
                if (i4 < strSubstring.length()) {
                    if (strSubstring.charAt(i4) < '0' || strSubstring.charAt(i4) > '9') {
                        throw new ParseException("Invalid nanoseconds.", 0);
                    }
                    iCharAt = (strSubstring.charAt(i4) - '0') + iCharAt;
                }
            }
        }
        if (str.charAt(iIndexOf2) != 'Z') {
            long jZzb = zzb(str.substring(iIndexOf2 + 1));
            time = str.charAt(iIndexOf2) == '+' ? time - jZzb : time + jZzb;
        } else if (str.length() != iIndexOf2 + 1) {
            throw new ParseException(S.g("Failed to parse timestamp: invalid trailing data \"", str.substring(iIndexOf2), "\""), 0);
        }
        if (iCharAt <= -1000000000 || iCharAt >= 1000000000) {
            try {
                time = zzbf.zza(time, iCharAt / 1000000000);
                iCharAt %= 1000000000;
            } catch (IllegalArgumentException e) {
                ParseException parseException = new ParseException(S.g("Failed to parse timestamp ", str, " Timestamp is out of range."), 0);
                parseException.initCause(e);
                throw parseException;
            }
        }
        if (iCharAt < 0) {
            iCharAt += 1000000000;
            time = zzbf.zzb(time, 1L);
        }
        return zzb((zzaly) ((zzaja) zzaly.zzc().zza(time).zza(iCharAt).zzf()));
    }

    private static zzaly zzb(zzaly zzalyVar) {
        long jZzb = zzalyVar.zzb();
        int iZza = zzalyVar.zza();
        if (jZzb >= -62135596800L && jZzb <= 253402300799L && iZza >= 0 && iZza < 1000000000) {
            return zzalyVar;
        }
        throw new IllegalArgumentException("Timestamp is not valid. See proto definition for valid values. Seconds (" + jZzb + ") must be in range [-62,135,596,800, +253,402,300,799]. Nanos (" + iZza + ") must be in range [0, +999,999,999].");
    }

    public static /* synthetic */ SimpleDateFormat zza() {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.ENGLISH);
        GregorianCalendar gregorianCalendar = new GregorianCalendar(TimeZone.getTimeZone("UTC"));
        gregorianCalendar.setGregorianChange(new Date(Long.MIN_VALUE));
        simpleDateFormat.setCalendar(gregorianCalendar);
        return simpleDateFormat;
    }
}
