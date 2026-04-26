package com.google.android.play.core.integrity;

import android.os.Bundle;
import android.os.Parcel;
import android.os.RemoteException;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class ar extends aw {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    final /* synthetic */ long f3664a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    final /* synthetic */ TaskCompletionSource f3665b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    final /* synthetic */ ax f3666c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public ar(ax axVar, TaskCompletionSource taskCompletionSource, long j4, TaskCompletionSource taskCompletionSource2) {
        super(axVar, taskCompletionSource);
        this.f3666c = axVar;
        this.f3664a = j4;
        this.f3665b = taskCompletionSource2;
    }

    @Override // Q0.w
    public final void b() {
        if (ax.g(this.f3666c)) {
            a(new StandardIntegrityException(-2, null));
            return;
        }
        try {
            ax axVar = this.f3666c;
            Q0.n nVar = (Q0.n) axVar.f3676a.f1528n;
            Bundle bundleB = ax.b(axVar, this.f3664a);
            av avVar = new av(this.f3666c, this.f3665b);
            Q0.l lVar = (Q0.l) nVar;
            lVar.getClass();
            Parcel parcelObtain = Parcel.obtain();
            parcelObtain.writeInterfaceToken(lVar.f1513b);
            int i4 = Q0.j.f1533a;
            parcelObtain.writeInt(1);
            bundleB.writeToParcel(parcelObtain, 0);
            parcelObtain.writeStrongBinder(avVar);
            lVar.a(2, parcelObtain);
        } catch (RemoteException e) {
            this.f3666c.f3677b.a(e, "warmUpIntegrityToken(%s)", Long.valueOf(this.f3664a));
            this.f3665b.trySetException(new StandardIntegrityException(-100, e));
        }
    }
}
