package com.google.android.gms.common.internal;

import android.os.Bundle;
import android.os.IBinder;
import android.os.Parcel;
import android.util.Log;
import com.google.android.gms.internal.common.zzb;
import com.google.android.gms.internal.common.zzc;

/* JADX INFO: loaded from: classes.dex */
public final class H extends zzb {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0283f f3523a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f3524b;

    public H(AbstractC0283f abstractC0283f, int i4) {
        super("com.google.android.gms.common.internal.IGmsCallbacks");
        this.f3523a = abstractC0283f;
        this.f3524b = i4;
    }

    @Override // com.google.android.gms.internal.common.zzb
    public final boolean zza(int i4, Parcel parcel, Parcel parcel2, int i5) {
        int i6 = this.f3524b;
        if (i4 == 1) {
            int i7 = parcel.readInt();
            IBinder strongBinder = parcel.readStrongBinder();
            Bundle bundle = (Bundle) zzc.zza(parcel, Bundle.CREATOR);
            zzc.zzb(parcel);
            F.h(this.f3523a, "onPostInitComplete can be called only once per call to getRemoteService");
            this.f3523a.onPostInitHandler(i7, strongBinder, bundle, i6);
            this.f3523a = null;
        } else if (i4 == 2) {
            parcel.readInt();
            zzc.zzb(parcel);
            Log.wtf("GmsClient", "received deprecated onAccountValidationComplete callback, ignoring", new Exception());
        } else {
            if (i4 != 3) {
                return false;
            }
            int i8 = parcel.readInt();
            IBinder strongBinder2 = parcel.readStrongBinder();
            L l2 = (L) zzc.zza(parcel, L.CREATOR);
            zzc.zzb(parcel);
            AbstractC0283f abstractC0283f = this.f3523a;
            F.h(abstractC0283f, "onPostInitCompleteWithConnectionInfo can be called only once per call togetRemoteService");
            F.g(l2);
            AbstractC0283f.zzj(abstractC0283f, l2);
            Bundle bundle2 = l2.f3530a;
            F.h(this.f3523a, "onPostInitComplete can be called only once per call to getRemoteService");
            this.f3523a.onPostInitHandler(i8, strongBinder2, bundle2, i6);
            this.f3523a = null;
        }
        parcel2.writeNoException();
        return true;
    }
}
