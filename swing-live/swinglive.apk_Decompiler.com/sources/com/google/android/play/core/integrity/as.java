package com.google.android.play.core.integrity;

import android.os.Bundle;
import android.os.Parcel;
import android.os.RemoteException;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class as extends aw {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    final /* synthetic */ String f3667a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    final /* synthetic */ long f3668b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    final /* synthetic */ long f3669c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    final /* synthetic */ TaskCompletionSource f3670d;
    final /* synthetic */ ax e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public as(ax axVar, TaskCompletionSource taskCompletionSource, String str, long j4, long j5, TaskCompletionSource taskCompletionSource2) {
        super(axVar, taskCompletionSource);
        this.e = axVar;
        this.f3667a = str;
        this.f3668b = j4;
        this.f3669c = j5;
        this.f3670d = taskCompletionSource2;
    }

    @Override // Q0.w
    public final void b() {
        if (ax.g(this.e)) {
            a(new StandardIntegrityException(-2, null));
            return;
        }
        try {
            ax axVar = this.e;
            Q0.n nVar = (Q0.n) axVar.f3676a.f1528n;
            Bundle bundleA = ax.a(axVar, this.f3667a, this.f3668b, this.f3669c);
            au auVar = new au(this.e, this.f3670d);
            Q0.l lVar = (Q0.l) nVar;
            lVar.getClass();
            Parcel parcelObtain = Parcel.obtain();
            parcelObtain.writeInterfaceToken(lVar.f1513b);
            int i4 = Q0.j.f1533a;
            parcelObtain.writeInt(1);
            bundleA.writeToParcel(parcelObtain, 0);
            parcelObtain.writeStrongBinder(auVar);
            lVar.a(3, parcelObtain);
        } catch (RemoteException e) {
            this.e.f3677b.a(e, "requestExpressIntegrityToken(%s, %s)", this.f3667a, Long.valueOf(this.f3668b));
            this.f3670d.trySetException(new StandardIntegrityException(-100, e));
        }
    }
}
