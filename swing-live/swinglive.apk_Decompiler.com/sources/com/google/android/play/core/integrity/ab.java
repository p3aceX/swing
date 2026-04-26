package com.google.android.play.core.integrity;

import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.os.RemoteException;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class ab extends Q0.w {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    final /* synthetic */ byte[] f3638a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    final /* synthetic */ Long f3639b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    final /* synthetic */ TaskCompletionSource f3640c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    final /* synthetic */ IntegrityTokenRequest f3641d;
    final /* synthetic */ ad e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public ab(ad adVar, TaskCompletionSource taskCompletionSource, byte[] bArr, Long l2, Parcelable parcelable, TaskCompletionSource taskCompletionSource2, IntegrityTokenRequest integrityTokenRequest) {
        super(taskCompletionSource);
        this.e = adVar;
        this.f3638a = bArr;
        this.f3639b = l2;
        this.f3640c = taskCompletionSource2;
        this.f3641d = integrityTokenRequest;
    }

    @Override // Q0.w
    public final void a(Exception exc) {
        if (exc instanceof Q0.d) {
            super.a(new IntegrityServiceException(-9, exc));
        } else {
            super.a(exc);
        }
    }

    @Override // Q0.w
    public final void b() {
        try {
            ad adVar = this.e;
            Q0.s sVar = (Q0.s) adVar.f3645a.f1528n;
            Bundle bundleA = ad.a(adVar, this.f3638a, this.f3639b, null);
            ac acVar = new ac(this.e, this.f3640c);
            Q0.q qVar = (Q0.q) sVar;
            qVar.getClass();
            Parcel parcelObtain = Parcel.obtain();
            parcelObtain.writeInterfaceToken(qVar.f1513b);
            int i4 = Q0.j.f1533a;
            parcelObtain.writeInt(1);
            bundleA.writeToParcel(parcelObtain, 0);
            parcelObtain.writeStrongBinder(acVar);
            qVar.a(2, parcelObtain);
        } catch (RemoteException e) {
            this.e.f3646b.a(e, "requestIntegrityToken(%s)", this.f3641d);
            this.f3640c.trySetException(new IntegrityServiceException(-100, e));
        }
    }
}
