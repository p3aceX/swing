package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import java.nio.charset.Charset;

/* JADX INFO: loaded from: classes.dex */
class zzahw extends zzahx {
    protected final byte[] zzb;

    public zzahw(byte[] bArr) {
        bArr.getClass();
        this.zzb = bArr;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof zzahm) || zzb() != ((zzahm) obj).zzb()) {
            return false;
        }
        if (zzb() == 0) {
            return true;
        }
        if (!(obj instanceof zzahw)) {
            return obj.equals(this);
        }
        zzahw zzahwVar = (zzahw) obj;
        int iZza = zza();
        int iZza2 = zzahwVar.zza();
        if (iZza == 0 || iZza2 == 0 || iZza == iZza2) {
            return zza(zzahwVar, 0, zzb());
        }
        return false;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public byte zza(int i4) {
        return this.zzb[i4];
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public byte zzb(int i4) {
        return this.zzb[i4];
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final zzaib zzc() {
        return zzaib.zza(this.zzb, zzh(), zzb(), true);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final boolean zzf() {
        int iZzh = zzh();
        return zzaml.zzc(this.zzb, iZzh, zzb() + iZzh);
    }

    public int zzh() {
        return 0;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final zzahm zza(int i4, int i5) {
        int iZza = zzahm.zza(0, i5, zzb());
        return iZza == 0 ? zzahm.zza : new zzahq(this.zzb, zzh(), iZza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final int zzb(int i4, int i5, int i6) {
        return zzajc.zza(i4, this.zzb, zzh(), i6);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public int zzb() {
        return this.zzb.length;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final String zza(Charset charset) {
        return new String(this.zzb, zzh(), zzb(), charset);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public void zza(byte[] bArr, int i4, int i5, int i6) {
        System.arraycopy(this.zzb, 0, bArr, 0, i6);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final void zza(zzahn zzahnVar) {
        zzahnVar.zza(this.zzb, zzh(), zzb());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahx
    public final boolean zza(zzahm zzahmVar, int i4, int i5) {
        if (i5 <= zzahmVar.zzb()) {
            if (i5 <= zzahmVar.zzb()) {
                if (zzahmVar instanceof zzahw) {
                    zzahw zzahwVar = (zzahw) zzahmVar;
                    byte[] bArr = this.zzb;
                    byte[] bArr2 = zzahwVar.zzb;
                    int iZzh = zzh() + i5;
                    int iZzh2 = zzh();
                    int iZzh3 = zzahwVar.zzh();
                    while (iZzh2 < iZzh) {
                        if (bArr[iZzh2] != bArr2[iZzh3]) {
                            return false;
                        }
                        iZzh2++;
                        iZzh3++;
                    }
                    return true;
                }
                return zzahmVar.zza(0, i5).equals(zza(0, i5));
            }
            throw new IllegalArgumentException(a.k("Ran off end of other: 0, ", i5, zzahmVar.zzb(), ", "));
        }
        throw new IllegalArgumentException("Length too large: " + i5 + zzb());
    }
}
