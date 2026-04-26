package com.google.android.gms.internal.p002firebaseauthapi;

import android.net.Uri;
import android.text.TextUtils;
import com.google.android.gms.common.internal.F;
import j1.C0455E;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzafb {
    private String zza;
    private String zzb;
    private boolean zzc;
    private String zzd;
    private String zze;
    private zzafu zzf;
    private String zzg;
    private String zzh;
    private long zzi;
    private long zzj;
    private boolean zzk;
    private C0455E zzl;
    private List<zzafq> zzm;
    private zzaq<zzafp> zzn;

    public zzafb() {
        this.zzf = new zzafu();
        this.zzn = zzaq.zzh();
    }

    public final long zza() {
        return this.zzi;
    }

    public final long zzb() {
        return this.zzj;
    }

    public final Uri zzc() {
        if (TextUtils.isEmpty(this.zze)) {
            return null;
        }
        return Uri.parse(this.zze);
    }

    public final zzaq<zzafp> zzd() {
        return this.zzn;
    }

    public final C0455E zze() {
        return this.zzl;
    }

    public final zzafu zzf() {
        return this.zzf;
    }

    public final String zzg() {
        return this.zzd;
    }

    public final String zzh() {
        return this.zzb;
    }

    public final String zzi() {
        return this.zza;
    }

    public final String zzj() {
        return this.zzh;
    }

    public final List<zzafq> zzk() {
        return this.zzm;
    }

    public final List<zzafr> zzl() {
        return this.zzf.zza();
    }

    public final boolean zzm() {
        return this.zzc;
    }

    public final boolean zzn() {
        return this.zzk;
    }

    public final zzafb zza(C0455E c0455e) {
        this.zzl = c0455e;
        return this;
    }

    public final zzafb zzb(String str) {
        this.zzb = str;
        return this;
    }

    public final zzafb zzd(String str) {
        this.zze = str;
        return this;
    }

    public final zzafb zza(String str) {
        this.zzd = str;
        return this;
    }

    public final zzafb zzc(String str) {
        F.d(str);
        this.zzg = str;
        return this;
    }

    public zzafb(String str, String str2, boolean z4, String str3, String str4, zzafu zzafuVar, String str5, String str6, long j4, long j5, boolean z5, C0455E c0455e, List<zzafq> list, zzaq<zzafp> zzaqVar) {
        zzafu zzafuVar2;
        this.zza = str;
        this.zzb = str2;
        this.zzc = z4;
        this.zzd = str3;
        this.zze = str4;
        if (zzafuVar == null) {
            zzafuVar2 = new zzafu();
        } else {
            List<zzafr> listZza = zzafuVar.zza();
            zzafu zzafuVar3 = new zzafu();
            if (listZza != null) {
                zzafuVar3.zza().addAll(listZza);
            }
            zzafuVar2 = zzafuVar3;
        }
        this.zzf = zzafuVar2;
        this.zzg = str5;
        this.zzh = str6;
        this.zzi = j4;
        this.zzj = j5;
        this.zzk = false;
        this.zzl = null;
        this.zzm = list == null ? new ArrayList<>() : list;
        this.zzn = zzaqVar;
    }

    public final zzafb zza(boolean z4) {
        this.zzk = z4;
        return this;
    }

    public final zzafb zza(List<zzafr> list) {
        F.g(list);
        zzafu zzafuVar = new zzafu();
        this.zzf = zzafuVar;
        zzafuVar.zza().addAll(list);
        return this;
    }
}
