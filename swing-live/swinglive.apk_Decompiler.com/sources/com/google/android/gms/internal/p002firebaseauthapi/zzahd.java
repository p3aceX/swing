package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzahd;
import com.google.android.gms.internal.p002firebaseauthapi.zzahf;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.IOException;
import java.io.OutputStream;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzahd<MessageType extends zzahd<MessageType, BuilderType>, BuilderType extends zzahf<MessageType, BuilderType>> implements zzakk {
    protected int zza = 0;

    public int zza(zzalc zzalcVar) {
        int iZzh = zzh();
        if (iZzh != -1) {
            return iZzh;
        }
        int iZza = zzalcVar.zza(this);
        zzb(iZza);
        return iZza;
    }

    public void zzb(int i4) {
        throw new UnsupportedOperationException();
    }

    public int zzh() {
        throw new UnsupportedOperationException();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakk
    public final zzahm zzi() {
        try {
            zzahv zzahvVarZzc = zzahm.zzc(zzk());
            zza(zzahvVarZzc.zzb());
            return zzahvVarZzc.zza();
        } catch (IOException e) {
            throw new RuntimeException(S.g("Serializing ", getClass().getName(), " to a ByteString threw an IOException (should never happen)."), e);
        }
    }

    public final byte[] zzj() {
        try {
            byte[] bArr = new byte[zzk()];
            zzaii zzaiiVarZzb = zzaii.zzb(bArr);
            zza(zzaiiVarZzb);
            zzaiiVarZzb.zzb();
            return bArr;
        } catch (IOException e) {
            throw new RuntimeException(S.g("Serializing ", getClass().getName(), " to a byte array threw an IOException (should never happen)."), e);
        }
    }

    public final void zza(OutputStream outputStream) {
        zzaii zzaiiVarZza = zzaii.zza(outputStream, zzaii.zzd(zzk()));
        zza(zzaiiVarZza);
        zzaiiVarZza.zzc();
    }
}
