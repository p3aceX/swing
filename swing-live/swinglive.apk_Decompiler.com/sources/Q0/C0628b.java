package q0;

import a.AbstractC0184a;
import android.accounts.Account;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import j1.C0454D;

/* JADX INFO: renamed from: q0.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0628b extends A0.a {
    public static final Parcelable.Creator<C0628b> CREATOR = new C0454D(6);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6246a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6247b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6248c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Account f6249d;

    public C0628b(int i4, int i5, String str, Account account) {
        this.f6246a = i4;
        this.f6247b = i5;
        this.f6248c = str;
        if (account != null || TextUtils.isEmpty(str)) {
            this.f6249d = account;
        } else {
            this.f6249d = new Account(str, "com.google");
        }
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6246a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f6247b);
        AbstractC0184a.i0(parcel, 3, this.f6248c, false);
        AbstractC0184a.h0(parcel, 4, this.f6249d, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
