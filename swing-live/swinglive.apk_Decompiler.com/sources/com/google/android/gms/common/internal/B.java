package com.google.android.gms.common.internal;

import a.AbstractC0184a;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.Parcelable;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class B extends A0.a {
    public static final Parcelable.Creator<B> CREATOR = new O.O(14);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3509a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final IBinder f3510b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0771b f3511c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f3512d;
    public final boolean e;

    public B(int i4, IBinder iBinder, C0771b c0771b, boolean z4, boolean z5) {
        this.f3509a = i4;
        this.f3510b = iBinder;
        this.f3511c = c0771b;
        this.f3512d = z4;
        this.e = z5;
    }

    public final boolean equals(Object obj) {
        Object s4;
        if (obj == null) {
            return false;
        }
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof B)) {
            return false;
        }
        B b5 = (B) obj;
        if (!this.f3511c.equals(b5.f3511c)) {
            return false;
        }
        Object s5 = null;
        IBinder iBinder = this.f3510b;
        if (iBinder == null) {
            s4 = null;
        } else {
            int i4 = AbstractBinderC0278a.f3553a;
            IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.common.internal.IAccountAccessor");
            s4 = iInterfaceQueryLocalInterface instanceof InterfaceC0290m ? (InterfaceC0290m) iInterfaceQueryLocalInterface : new S(iBinder, "com.google.android.gms.common.internal.IAccountAccessor");
        }
        IBinder iBinder2 = b5.f3510b;
        if (iBinder2 != null) {
            int i5 = AbstractBinderC0278a.f3553a;
            IInterface iInterfaceQueryLocalInterface2 = iBinder2.queryLocalInterface("com.google.android.gms.common.internal.IAccountAccessor");
            s5 = iInterfaceQueryLocalInterface2 instanceof InterfaceC0290m ? (InterfaceC0290m) iInterfaceQueryLocalInterface2 : new S(iBinder2, "com.google.android.gms.common.internal.IAccountAccessor");
        }
        return F.j(s4, s5);
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3509a);
        IBinder iBinder = this.f3510b;
        if (iBinder != null) {
            int iM02 = AbstractC0184a.m0(2, parcel);
            parcel.writeStrongBinder(iBinder);
            AbstractC0184a.n0(iM02, parcel);
        }
        AbstractC0184a.h0(parcel, 3, this.f3511c, i4, false);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f3512d ? 1 : 0);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
