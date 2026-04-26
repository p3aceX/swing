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
final class zzac extends AbstractC0256d {
    final /* synthetic */ boolean zza;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzac(zzal zzalVar, i iVar, o oVar, boolean z4) {
        super(iVar, oVar);
        this.zza = z4;
    }

    @Override // com.google.android.gms.common.api.internal.BasePendingResult
    public final s createFailedResult(Status status) {
        return new zzaj(status);
    }

    @Override // com.google.android.gms.common.api.internal.AbstractC0256d
    public final void doExecute(b bVar) {
        InterfaceC0653f interfaceC0653f = (InterfaceC0653f) ((zzam) bVar).getService();
        boolean z4 = this.zza;
        C0651d c0651d = (C0651d) interfaceC0653f;
        Parcel parcelZza = c0651d.zza();
        int i4 = zzc.zza;
        parcelZza.writeInt(z4 ? 1 : 0);
        c0651d.zzc(1, parcelZza);
        setResult(new zzaj(Status.f3372f));
    }

    public final /* bridge */ /* synthetic */ void setResult(Object obj) {
        setResult((s) obj);
    }
}
