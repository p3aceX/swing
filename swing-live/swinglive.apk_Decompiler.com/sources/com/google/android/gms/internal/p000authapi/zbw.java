package com.google.android.gms.internal.p000authapi;

import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import com.google.android.gms.common.api.internal.InterfaceC0261i;
import u0.f;
import u0.h;
import u0.i;

/* JADX INFO: loaded from: classes.dex */
public final class zbw extends zba implements IInterface {
    public zbw(IBinder iBinder) {
        super(iBinder, "com.google.android.gms.auth.api.identity.internal.ISignInService");
    }

    public final void zbc(zbm zbmVar, f fVar) {
        Parcel parcelZba = zba();
        zbc.zbd(parcelZba, zbmVar);
        zbc.zbc(parcelZba, fVar);
        zbb(1, parcelZba);
    }

    public final void zbd(zbp zbpVar, h hVar, String str) {
        Parcel parcelZba = zba();
        zbc.zbd(parcelZba, zbpVar);
        zbc.zbc(parcelZba, hVar);
        parcelZba.writeString(str);
        zbb(4, parcelZba);
    }

    public final void zbe(zbr zbrVar, i iVar) {
        Parcel parcelZba = zba();
        zbc.zbd(parcelZba, zbrVar);
        zbc.zbc(parcelZba, iVar);
        zbb(3, parcelZba);
    }

    public final void zbf(InterfaceC0261i interfaceC0261i, String str) {
        Parcel parcelZba = zba();
        zbc.zbd(parcelZba, interfaceC0261i);
        parcelZba.writeString(str);
        zbb(2, parcelZba);
    }
}
