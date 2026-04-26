package j1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: j1.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0460e extends AbstractC0458c {
    public static final Parcelable.Creator<C0460e> CREATOR = new C0454D(4);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5197a;

    public C0460e(String str) {
        com.google.android.gms.common.internal.F.d(str);
        this.f5197a = str;
    }

    @Override // j1.AbstractC0458c
    public final String b() {
        return "facebook.com";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5197a, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
