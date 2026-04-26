package com.google.android.gms.common.internal;

import android.accounts.Account;
import android.os.Binder;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.Parcelable;
import android.os.RemoteException;
import android.util.Log;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.internal.common.zzc;
import z0.C0773d;

/* JADX INFO: renamed from: com.google.android.gms.common.internal.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0287j extends A0.a {
    public static final Parcelable.Creator<C0287j> CREATOR = new O.O(18);

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public static final Scope[] f3568u = new Scope[0];
    public static final C0773d[] v = new C0773d[0];

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3569a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f3570b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f3571c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public String f3572d;
    public IBinder e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Scope[] f3573f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public Bundle f3574m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public Account f3575n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public C0773d[] f3576o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public C0773d[] f3577p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final boolean f3578q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final int f3579r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public boolean f3580s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final String f3581t;

    public C0287j(int i4, int i5, int i6, String str, IBinder iBinder, Scope[] scopeArr, Bundle bundle, Account account, C0773d[] c0773dArr, C0773d[] c0773dArr2, boolean z4, int i7, boolean z5, String str2) {
        Scope[] scopeArr2 = scopeArr == null ? f3568u : scopeArr;
        Bundle bundle2 = bundle == null ? new Bundle() : bundle;
        C0773d[] c0773dArr3 = v;
        C0773d[] c0773dArr4 = c0773dArr == null ? c0773dArr3 : c0773dArr;
        c0773dArr3 = c0773dArr2 != null ? c0773dArr2 : c0773dArr3;
        this.f3569a = i4;
        this.f3570b = i5;
        this.f3571c = i6;
        if ("com.google.android.gms".equals(str)) {
            this.f3572d = "com.google.android.gms";
        } else {
            this.f3572d = str;
        }
        if (i4 < 2) {
            Account account2 = null;
            if (iBinder != null) {
                int i8 = AbstractBinderC0278a.f3553a;
                IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.common.internal.IAccountAccessor");
                InterfaceC0290m s4 = iInterfaceQueryLocalInterface instanceof InterfaceC0290m ? (InterfaceC0290m) iInterfaceQueryLocalInterface : new S(iBinder, "com.google.android.gms.common.internal.IAccountAccessor");
                if (s4 != null) {
                    long jClearCallingIdentity = Binder.clearCallingIdentity();
                    try {
                        try {
                            S s5 = (S) s4;
                            Parcel parcelZzB = s5.zzB(2, s5.zza());
                            Account account3 = (Account) zzc.zza(parcelZzB, Account.CREATOR);
                            parcelZzB.recycle();
                            Binder.restoreCallingIdentity(jClearCallingIdentity);
                            account2 = account3;
                        } catch (RemoteException unused) {
                            Log.w("AccountAccessor", "Remote account accessor probably died");
                            Binder.restoreCallingIdentity(jClearCallingIdentity);
                        }
                    } catch (Throwable th) {
                        Binder.restoreCallingIdentity(jClearCallingIdentity);
                        throw th;
                    }
                }
            }
            this.f3575n = account2;
        } else {
            this.e = iBinder;
            this.f3575n = account;
        }
        this.f3573f = scopeArr2;
        this.f3574m = bundle2;
        this.f3576o = c0773dArr4;
        this.f3577p = c0773dArr3;
        this.f3578q = z4;
        this.f3579r = i7;
        this.f3580s = z5;
        this.f3581t = str2;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        O.O.a(this, parcel, i4);
    }
}
