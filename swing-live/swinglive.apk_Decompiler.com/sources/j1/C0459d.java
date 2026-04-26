package j1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

/* JADX INFO: renamed from: j1.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0459d extends AbstractC0458c {
    public static final Parcelable.Creator<C0459d> CREATOR = new C0454D(3);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5193a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5194b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f5195c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public String f5196d;
    public boolean e;

    public C0459d(String str, String str2, String str3, String str4, boolean z4) {
        com.google.android.gms.common.internal.F.d(str);
        this.f5193a = str;
        if (TextUtils.isEmpty(str2) && TextUtils.isEmpty(str3)) {
            throw new IllegalArgumentException("Cannot create an EmailAuthCredential without a password or emailLink.");
        }
        this.f5194b = str2;
        this.f5195c = str3;
        this.f5196d = str4;
        this.e = z4;
    }

    @Override // j1.AbstractC0458c
    public final String b() {
        return "password";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5193a, false);
        AbstractC0184a.i0(parcel, 2, this.f5194b, false);
        AbstractC0184a.i0(parcel, 3, this.f5195c, false);
        AbstractC0184a.i0(parcel, 4, this.f5196d, false);
        boolean z4 = this.e;
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(z4 ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
