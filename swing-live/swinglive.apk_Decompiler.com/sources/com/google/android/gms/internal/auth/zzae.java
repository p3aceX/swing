package com.google.android.gms.internal.auth;

import android.os.Parcel;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.b;
import com.google.android.gms.common.api.i;
import com.google.android.gms.common.api.internal.AbstractC0256d;
import com.google.android.gms.common.api.o;
import com.google.android.gms.common.api.s;
import r0.C0651d;
import r0.InterfaceC0653f;

/* JADX INFO: loaded from: classes.dex */
final class zzae extends AbstractC0256d {
    final /* synthetic */ String zza;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzae(zzal zzalVar, i iVar, o oVar, String str) {
        super(iVar, oVar);
        this.zza = str;
    }

    @Override // com.google.android.gms.common.api.internal.BasePendingResult
    public final /* synthetic */ s createFailedResult(Status status) {
        return new zzai(status, null);
    }

    @Override // com.google.android.gms.common.api.internal.AbstractC0256d
    public final void doExecute(b bVar) {
        InterfaceC0653f interfaceC0653f = (InterfaceC0653f) ((zzam) bVar).getService();
        zzad zzadVar = new zzad(this);
        String str = this.zza;
        C0651d c0651d = (C0651d) interfaceC0653f;
        Parcel parcelZza = c0651d.zza();
        zzc.zzd(parcelZza, zzadVar);
        parcelZza.writeString(str);
        c0651d.zzc(2, parcelZza);
    }

    public final /* bridge */ /* synthetic */ void setResult(Object obj) {
        setResult((s) obj);
    }
}
