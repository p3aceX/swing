package com.google.android.gms.internal.p002firebaseauthapi;

import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public class zzajj extends IOException {
    private zzakk zza;
    private boolean zzb;

    public zzajj(IOException iOException) {
        super(iOException.getMessage(), iOException);
        this.zza = null;
    }

    public static zzaji zza() {
        return new zzaji("Protocol message tag had invalid wire type.");
    }

    public static zzajj zzb() {
        return new zzajj("Protocol message end-group tag did not match expected tag.");
    }

    public static zzajj zzc() {
        return new zzajj("Protocol message contained an invalid tag (zero).");
    }

    public static zzajj zzd() {
        return new zzajj("Protocol message had invalid UTF-8.");
    }

    public static zzajj zze() {
        return new zzajj("CodedInputStream encountered a malformed varint.");
    }

    public static zzajj zzf() {
        return new zzajj("CodedInputStream encountered an embedded string or message which claimed to have negative size.");
    }

    public static zzajj zzg() {
        return new zzajj("Failed to parse the message.");
    }

    public static zzajj zzh() {
        return new zzajj("Protocol message was too large.  May be malicious.  Use CodedInputStream.setSizeLimit() to increase the size limit.");
    }

    public static zzajj zzi() {
        return new zzajj("While parsing a protocol message, the input ended unexpectedly in the middle of a field.  This could mean either that the input has been truncated or that an embedded message misreported its own length.");
    }

    public final void zzj() {
        this.zzb = true;
    }

    public final boolean zzk() {
        return this.zzb;
    }

    public final zzajj zza(zzakk zzakkVar) {
        this.zza = zzakkVar;
        return this;
    }

    public zzajj(String str) {
        super(str);
        this.zza = null;
    }
}
