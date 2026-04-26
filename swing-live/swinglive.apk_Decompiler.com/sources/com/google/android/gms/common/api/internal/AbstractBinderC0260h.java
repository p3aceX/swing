package com.google.android.gms.common.api.internal;

import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.internal.base.zab;
import com.google.android.gms.internal.base.zac;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractBinderC0260h extends zab implements InterfaceC0261i {
    public AbstractBinderC0260h() {
        super("com.google.android.gms.common.api.internal.IStatusCallback");
    }

    public static InterfaceC0261i asInterface(IBinder iBinder) {
        if (iBinder == null) {
            return null;
        }
        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.common.api.internal.IStatusCallback");
        return iInterfaceQueryLocalInterface instanceof InterfaceC0261i ? (InterfaceC0261i) iInterfaceQueryLocalInterface : new J(iBinder, "com.google.android.gms.common.api.internal.IStatusCallback");
    }

    @Override // com.google.android.gms.internal.base.zab
    public final boolean zaa(int i4, Parcel parcel, Parcel parcel2, int i5) {
        if (i4 != 1) {
            return false;
        }
        onResult((Status) zac.zaa(parcel, Status.CREATOR));
        return true;
    }
}
