package com.google.android.gms.common.internal;

import android.os.IBinder;
import android.os.Parcel;

/* JADX INFO: loaded from: classes.dex */
public final class E implements InterfaceC0292o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final IBinder f3518a;

    public E(IBinder iBinder) {
        this.f3518a = iBinder;
    }

    public final void a(H h4, C0287j c0287j) {
        Parcel parcelObtain = Parcel.obtain();
        Parcel parcelObtain2 = Parcel.obtain();
        try {
            parcelObtain.writeInterfaceToken("com.google.android.gms.common.internal.IGmsServiceBroker");
            parcelObtain.writeStrongBinder(h4.asBinder());
            parcelObtain.writeInt(1);
            O.O.a(c0287j, parcelObtain, 0);
            this.f3518a.transact(46, parcelObtain, parcelObtain2, 0);
            parcelObtain2.readException();
        } finally {
            parcelObtain2.recycle();
            parcelObtain.recycle();
        }
    }

    @Override // android.os.IInterface
    public final IBinder asBinder() {
        return this.f3518a;
    }
}
