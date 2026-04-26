package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzaei extends zzafx {
    private String zza;
    private String zzb;
    private String zzc;
    private zzaex zzd;
    private String zze;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzafx
    public final zzafx zza(String str) {
        if (str == null) {
            throw new NullPointerException("Null idToken");
        }
        this.zze = str;
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzafx
    public final zzafx zzb(String str) {
        if (str == null) {
            throw new NullPointerException("Null providerId");
        }
        this.zza = str;
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzafx
    public final zzafx zzc(String str) {
        this.zzb = str;
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzafx
    public final zzafx zzd(String str) {
        if (str == null) {
            throw new NullPointerException("Null token");
        }
        this.zzc = str;
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzafx
    public final zzafx zza(zzaex zzaexVar) {
        if (zzaexVar != null) {
            this.zzd = zzaexVar;
            return this;
        }
        throw new NullPointerException("Null tokenType");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzafx
    public final zzafy zza() {
        String str;
        zzaex zzaexVar;
        String str2;
        String str3 = this.zza;
        if (str3 != null && (str = this.zzc) != null && (zzaexVar = this.zzd) != null && (str2 = this.zze) != null) {
            return new zzaef(str3, this.zzb, str, zzaexVar, str2);
        }
        StringBuilder sb = new StringBuilder();
        if (this.zza == null) {
            sb.append(" providerId");
        }
        if (this.zzc == null) {
            sb.append(" token");
        }
        if (this.zzd == null) {
            sb.append(" tokenType");
        }
        if (this.zze == null) {
            sb.append(" idToken");
        }
        throw new IllegalStateException("Missing required properties:".concat(String.valueOf(sb)));
    }
}
