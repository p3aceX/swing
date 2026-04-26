package com.google.android.gms.internal.p002firebaseauthapi;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

/* JADX INFO: loaded from: classes.dex */
public final class zzbk implements zzcb {
    private final InputStream zza;

    private zzbk(InputStream inputStream) {
        this.zza = inputStream;
    }

    public static zzcb zza(byte[] bArr) {
        return new zzbk(new ByteArrayInputStream(bArr));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcb
    public final zzvh zzb() throws IOException {
        try {
            return zzvh.zza(this.zza, zzaip.zza());
        } finally {
            this.zza.close();
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcb
    public final zzty zza() throws IOException {
        try {
            return zzty.zza(this.zza, zzaip.zza());
        } finally {
            this.zza.close();
        }
    }
}
